[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]
    $ticketNumber)

# Initiate variables with dot sourcing helper script
. ./scripts/review_helper.ps1

if($null -ne (git status --porcelain)) {
    Write-Host "You have currently changes. This will mess up them. Exiting." -ForegroundColor Red
    exit 0
}

$startBranch = ("start-review-"+$ticketNumber)
$implBranch = ("impl-review-"+$ticketNumber)
$commitBeforeChanges = ($firstCommitHash + "~1")
git branch $startBranch $commitBeforeChanges
git checkout -b $implBranch $commitBeforeChanges

$changes | ForEach-Object {
    $hash = ($_.Substring(0,$gitHashLength))
    Write-Verbose "Apply hash: $hash"
    git cherry-pick $hash --strategy=recursive
}

git difftool --no-prompt --dir-diff --tool=meld ($startBranch+".."+$implBranch)
git checkout main
git branch -D $implBranch
git branch -d $startBranch