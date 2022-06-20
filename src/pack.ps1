# Launched in a parent directory, it launches zipcomics
#   on every child directory in order to pack them together into cbz files

$dir = get-location
$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -Parent)

. "$scriptDir\utils.ps1"
checkDependencies

zipcomics -sourceDir $dir -targetDir $dir

# Remove packed directories
$directories = Get-ChildItem -Path $dir -Directory

foreach ($d in $directories) {
    Remove-Item $d -Recurse -Force
}
