$gitHashLength = 40
$ticketPrefix = Get-Content "$PSScriptRoot/../data/ticketprefix.txt"
$grepString = "^"+$ticketPrefix+"-"+$ticketNumber+":"
$changes = git log --pretty=oneline --grep="$grepString"
# Reverse changes list to be chronological or exit if no changes
if($changes) { [array]::Reverse($changes) } else { exit 0 }
# Get the information about first and last commit hash
$firstCommit = $changes | Select-Object -First 1
$firstCommitHash = $firstCommit.Substring(0,$gitHashLength)
Write-Verbose "First commit hash was $firstCommitHash"
$lastCommit = $changes | Select-Object -Last 1
$lastCommitHash = $lastCommit.Substring(0,$gitHashLength)
Write-Verbose "Last commit hash was $lastCommitHash"