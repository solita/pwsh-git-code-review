[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]
    $ticketNumber)

# Initiate variables with dot sourcing helper script
. ./scripts/review_helper.ps1

$gitBaseUrl = Get-Content "data/gitbaseurl.txt"

$changes | ForEach-Object {
    $hash = ($_.Substring(0,$gitHashLength))
    $message = ($_.Substring($gitHashLength+1))
    $commitUrl = $gitBaseUrl + $hash
    ("$commitUrl - $message")
}