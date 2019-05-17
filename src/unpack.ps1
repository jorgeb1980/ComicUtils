# Unpacks every zip file inside a directory

$dir = get-location
 
$extension = '.zip';
$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -Parent)

. "$scriptDir\utils.ps1"

Write-Output "Looking for files ending in $extension in $dir ..."
$files = Get-ChildItem -Path $dir -Filter $('*'+$extension)
# Decompress them and delete the original
foreach ($f in $files) {
    $file = $f.name
    $isDir = isDirectory -file $f.fullname
    if (-Not $isDir) {            
        # Decompress it into target temporary directory
        $target = ($dir.Path + [IO.Path]::DirectorySeparatorChar + $file.replace($extension, ""))
        Write-Output "Decompressing $file to $target ..."
        $ret = callProcess -executable "7z" -directory $dir -arguments $("e `"$file`" `"-o$target`" `* -r") -useShellExecute $false
        if ($ret -ne 0) {
            Write-Output ("[ERROR] 7z returned: " + $ret)
        }    
        else {
            # Remove the original file
            $fullName = $dir.Path + [IO.Path]::DirectorySeparatorChar + $file;
            Write-Output "Removing $fullName ..."
            Remove-Item -LiteralPath ($dir.Path + [IO.Path]::DirectorySeparatorChar + $file) -Force -Recurse
        }
    }
    else {
        Write-Output "Ignoring $file -> it is a directory"
    }
}
