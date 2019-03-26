# Launched on a directory: 
#   + lists every pdf file present in the directory
#   + if there are PDF files, creates a temporary directory
#   + for each one of them, creates a child directory inside the temporary with the same name without extension,
#       and copies the pdf inside
#   + extracts every image in that file inside the child directory using apache pdfbox
#   + erases the pdf
#   + once every pdf is extracted into a directory, runs zipcomics.ps1 inside the temporary in order to
#       generate a cbz with the comic
#   + copies back the cbz files to the original directory, along the original PDFs


$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -Parent)

. "$scriptDir\utils.ps1"

$dir = get-location
$tempDir = temporaryDirectory

Write-Output "Looking for pdf files in $dir ..."
$files = Get-ChildItem -Path $dir -Filter $('*.pdf')

if ($files.Length -gt 0) {
    # Create the children directory and copy the pdf there
    foreach ($f in $files) {
        $newDir = ($tempDir + "\" + $f.name.substring(0, $f.name.LastIndexOf('.')))
        New-Item -ItemType directory -Path ($newDir)
        Copy-Item -Path $f.fullname -Destination $newDir
        # Call java inside the directory
        $command = "-jar `"$scriptDir\..\lib\pdfbox-app-2.0.14.jar`" PDFToImage `"" + $f.name + "`""
        Write-Output "Converting $f..."
        $ret = callProcess -executable "javaw" -directory $newDir -arguments $command
        if ($ret -ne 0) {
            Write-Output "Found some problem while extracting images from " + $f.name
        }
    }

    # Repack everything
    zipcomics -sourceDir $tempDir -targetDir $dir

    # Copy files back
    cp $tempDir/*.cbz $dir

    Remove-Item -Path $tempDir -Recurse -Force
}