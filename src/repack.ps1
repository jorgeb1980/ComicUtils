# Launched in a parent directory, tries to open with 7zip every rar or zip file present,
#   decompresses them to a child directory and erases them, and then launches zipcomics.ps1 
#   on the child directory in order to pack them again

$dir = get-location

. .\utils.ps1

function repackFiles {
    param( [string]$extension, [string]$dir)

    Write-Output "Looking for files ending in $extension in $dir ..."
    $files = Get-ChildItem -Path $dir -Filter $('*'+$extension)
    # Decompress them and delete the original
    foreach ($f in $files) {
        $file = $f.fullname
        $isDir = isDirectory -file $file
        if (-Not $isDir) {            
            # Descomprimirlo en un directorio
            $target = $file.replace($extension, "")
            Write-Output "Decompressing $file to $target ..."
            $ret = callProcess -executable "7z" -arguments $("e `"$file`" `"-o$target`" `* -r")
            if ($ret -ne 0) {
                Write-Output "Ignoring $file since 7zip looks not to like the file..."
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
    & "$PSScriptRoot\zipcomics.ps1"
}

repackFiles -extension '.cbz' -dir $dir.Path
repackFiles -extension '.cbr' -dir $dir.Path