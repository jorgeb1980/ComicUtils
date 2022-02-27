# Launched in a parent directory, tries to open with 7zip every rar or zip file present,
#   decompresses them to a child directory and erases them, and then launches zipcomics.ps1 
#   on the child directory in order to pack them again

$dir = get-location
$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -Parent)

. "$scriptDir\utils.ps1"
checkDependencies

function repackFiles {
    param( [string]$extension, [string]$dir)
    $tempDir = temporaryDirectory

    $initialFiles = Get-ChildItem -Path $dir -Filter $('*'+$extension)
    # Remove directories
    $files = @()
    foreach ($if in $initialFiles) {
        $isDir = isDirectory -file $if.fullname
        if (-Not $isDir) {      
            $files += $if
        }
    }
    $totalFiles = $files.Length
    $currentFile = 0
    # Decompress them and delete the original
    foreach ($f in $files) {
        Write-Progress -Activity "Unpacking comics..." `
            -Status ("Unpacking $($f.name) ($($currentFile + 1)/$totalFiles)") `
            -PercentComplete (100 * $currentFile++ / $totalFiles)
        $file = $f.name
        # Decompress it into target temporary directory
        $target = ($tempDir + [IO.Path]::DirectorySeparatorChar + $file.replace($extension, ""))
        $ret = callProcess -executable "7z" -directory $dir -arguments $("e `"$file`" `"-o$target`" `* -r") -useShellExecute $false
        if ($ret -ne 0) {
            Write-Host ("[ERROR] 7z returned: $ret for file $($f.name)")
        }    
        else {
            # Remove the original file
            Remove-Item -LiteralPath $file
        }
        
    }
    # Repack the directory
    zipcomics -sourceDir $tempDir -targetDir $dir

    Remove-Item -Path $tempDir -Recurse -Force
}

repackFiles -extension '.cbz' -dir $dir.Path
repackFiles -extension '.cbr' -dir $dir.Path