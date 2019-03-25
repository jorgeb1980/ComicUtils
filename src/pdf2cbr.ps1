# Launched over a parent directory: 
#   + lists every pdf file present in the directory
#   + for each one of them, creates a child directory with the same name without extension,
#       and copies the pdf inside
#   + extracts every image in that file inside the child directory using apache pdfbox
#   + erases the pdf
#   + once every pdf is extracted into a directory, runs zipcomics.ps1 inside it in order to
#       generate a cbz with the comic

$dir = get-location
$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -Parent)

. "$scriptDir\utils.ps1"

Write-Output "Looking for pdf files in $dir ..."
$files = Get-ChildItem -Path $dir -Filter $('*.pdf')

# Create the children directory and copy the pdf there
foreach ($f in $files) {
    $newDir = $dir.path + "\" + $f.name.substring(0, $f.name.LastIndexOf('.'))
    # Circumvent known issue with Remove-Item...
    deleteDirectory($newDir)
    New-Item -ItemType directory -Path ($newDir)
    Copy-Item -Path $f.fullname -Destination $newDir
    # Call java inside the directory
    $command = "-jar `"$scriptDir\..\lib\pdfbox-app-2.0.14.jar`" PDFToImage `"" + $f.name + "`""
    Write-Output "Converting $f..."
    callProcess -executable "javaw" -directory $newDir -arguments $command
    Remove-Item -Path ($newDir + "\" + $f.name)
}

# Repack everything
& "$PSScriptRoot\zipcomics.ps1"