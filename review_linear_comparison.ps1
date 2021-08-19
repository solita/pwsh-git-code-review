[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]
    $ticketNumber)

& ./review_stats.ps1 $ticketNumber

# Initiate variables with dot sourcing helper script
. ./scripts/review_helper.ps1

$compareHashString = ($firstCommitHash+"^.."+$lastCommitHash)
git difftool --no-prompt --dir-diff --tool=meld $compareHashString