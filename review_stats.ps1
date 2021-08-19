[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]
    $ticketNumber)

# Initiate variables with dot sourcing helper script
. ./scripts/review_helper.ps1

# Tuple type for changes
$tupleType = [ValueTuple[string, int, int]]
# Dictionary for change tracking
$changeList = New-Object 'System.Collections.Generic.Dictionary[string,[ValueTuple[string, int, int]]]'
# Loop all the git hashes and map them to changeList dictionary
$changes | ForEach-Object {
    $changeHash = ($_.Substring(0,$gitHashLength))
    $changeHashString = $changeHash+"^.."+$changeHash
    Write-Verbose "Getting stats for: $changeHashString"
    # Get both numerical stats and letter stats for this specific commit
    $diffString = git diff --numstat $changeHashString 
    $fileStatusString = git diff --name-status $changeHashString 

    # Solve first numeric stats
    $diffString | ForEach-Object {
        # Split the <n> <n> <filename> by tabs
        $diffArr = $_.split("`t",[System.StringSplitOptions]::RemoveEmptyEntries)
        # Get the file name from third array slot
        $fileKey = $diffArr[2].Trim()
        # Parse additions and deletions from file
        $insertions = $Null
        $deletions = $Null
        $isNumericInsertion = [Double]::TryParse($diffArr[0],[ref]$insertions)
        $isNumericDeletion = [Double]::TryParse($diffArr[1],[ref]$deletions)
        Write-Verbose ("File: " + $fileKey + " Insertions: " + $insertions + " Deletions: " + $deletions)
        if(-not($isNumericInsertion)) { $insertions = 0 }
        if(-not($isNumericDeletion)) { $deletions = 0 }
        # Check if the file exists already in changelist
        if(-not($changeList[$fileKey])) {
            # New file, create without knowing if it was Add, Delete, Modification or something else like rename
            Write-Verbose "File not found $fileKey"
            $changeList.Add($fileKey, $tupleType::new("?",$insertions,$deletions))
        } else {
            # Existing file, sum additions and deletions for existing record
            Write-Verbose "File found $fileKey"
            $tempTuple = $changeList[$fileKey]
            $tempTuple.Item2 += $insertions
            $tempTuple.Item3 += $deletions
            $changeList[$fileKey] = $tempTuple
        }
    }

    # Solve file letter type
    $fileStatusString | ForEach-Object {
        # Split the <string> <filename> by tabs
        $fileStatusArr = $_.split("`t",[System.StringSplitOptions]::RemoveEmptyEntries)
        # Get the file status A, M, D etc
        $fileStatus = $fileStatusArr[0].Trim()
        # Get the file key itself
        $fileKey = $fileStatusArr[1].Trim()
        Write-Verbose ("Status: " + $fileStatus + " File: " + $fileKey + " Existing file status: " + $changeList[$fileKey].Item1)
        # Update the filestatus for newer
        $existingStatus = $changeList[$fileKey].Item1
        if($existingStatus -eq "?" -or $fileStatus -eq "A" -or $fileStatus -eq "D") {
            Write-Verbose "Replacing file status $fileKey from $existingStatus to $fileStatus "
            $tempTuple = $changeList[$fileKey]
            $tempTuple.Item1 = $fileStatus
            $changeList[$fileKey] = $tempTuple
        } else {
            Write-Verbose "Keeping old status for $fileKey as $existingStatus"
        }
    }
}

# Loop through change dictionary and print out the changes
$changeList.Keys | ForEach-Object {
    $printString = ($changeList[$_].Item1 + " " + $_)
    $addString = " +"+$changeList[$_].Item2
    $removeString = " -"+$changeList[$_].Item3
    # Choose color for first letter, yellow as default
    $letterColor = [ConsoleColor]::Yellow
    if($changeList[$_].Item1 -eq "A") {
        $letterColor = [ConsoleColor]::Green
    }
    elseif($changeList[$_].Item1 -eq "D") {
        $letterColor = [ConsoleColor]::Red
    }

    # Print each potential output color with corresponding color
    Write-Host $printString -NoNewline -ForegroundColor $letterColor
    Write-Host $addString -NoNewline -ForegroundColor Green
    Write-Host $removeString -ForegroundColor Red
}