# Unpacks every file inside a directory into a new child directory with the same name
#   as the original compressed file
# Optional parameter: extension
# Examples:
#   unpack.ps1
#       Would unpack every .zip file in the directory
#   unpack.ps1 -extension rar
#       Would unpack every .rar file in the directory 
#   unpack.ps1 -extension cbz
#       Would unpack every .cbz file in the directory 

param([string]$extension='zip') 

$dir = get-location

$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -Parent)

. "$scriptDir\utils.ps1"

# Make sure the extension starts with .
if (-Not $extension.StartsWith(".")) {
    $extension = '.' + $extension
}

$files = Get-ChildItem -Path $dir -Filter $('*'+$extension)
# Decompress them and delete the original
$totalFiles = $files.Length
$currentFile = 0
foreach ($f in $files) {
    Write-Progress -Activity "Unzipping files..." `
        -Status ("Unzipping -> $($f.name) ($($currentFile + 1)/$totalFiles)")  `
        -PercentComplete (100 * $currentFile++ / $totalFiles)
    $file = $f.name
    # Decompress it into target temporary directory
    $target = ($dir.Path + [IO.Path]::DirectorySeparatorChar + $file.replace($extension, ""))
    $ret = callProcess -executable "7z" -directory $dir -arguments $("e `"$file`" `"-o$target`" `* -r") -useShellExecute $false
    if ($ret -ne 0) {
        Write-Output ("[ERROR] 7z returned: $ret for file $($f.name)")
    }    
    else {
        # Remove the original file
        Remove-Item -LiteralPath ($dir.Path + [IO.Path]::DirectorySeparatorChar + $file) -Force -Recurse
    }
}
