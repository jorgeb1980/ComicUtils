# Launched in a parent directory, tries to open with 7zip every rar or zip file present,
#   decompresses them to a child directory and erases them, and then launches zipcomics.ps1 
#   on the child directory in order to pack them again

$dir = get-location
$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -Parent)

. "$scriptDir\utils.ps1"

function repackFiles {
    param( [string]$extension, [string]$dir)
    $tempDir = temporaryDirectory

    Write-Output "Looking for files ending in $extension in $dir ..."
    $files = Get-ChildItem -Path $dir -Filter $('*'+$extension)
    # Decompress them and delete the original
    foreach ($f in $files) {
        $file = $f.name
        $isDir = isDirectory -file $f.fullname
        if (-Not $isDir) {            
            # Descomprimirlo en un directorio
            $target = ($tempDir + [IO.Path]::DirectorySeparatorChar + $file.replace($extension, ""))
            Write-Output "Decompressing $file to $target ..."
            $ret = callProcess -executable "7z" -directory $dir -arguments $("e `"$file`" `"-o$target`" `* -r") -useShellExecute $false
            if ($ret -ne 0) {
                Write-Output ("[ERROR] 7z returned: " + $ret)
            }    
            else {
                # Remove the original file
                Remove-Item $file
            }
        }
        else {
            Write-Output "Ignoring $file -> it is a directory"
        }
    }
    # Repack the directory
    zipcomics -sourceDir $tempDir -targetDir $dir

    Remove-Item -Path $tempDir -Recurse -Force
}

repackFiles -extension '.cbz' -dir $dir.Path
repackFiles -extension '.cbr' -dir $dir.Path