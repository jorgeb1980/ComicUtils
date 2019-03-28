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
        $prefix = $f.name.substring(0, $f.name.LastIndexOf('.'))
        $newDir = ($tempDir + [IO.Path]::DirectorySeparatorChar + $prefix)
        $suffix = ".jpg"
        New-Item -ItemType directory -Path ($newDir)
        Copy-Item -Path $f.fullname -Destination $newDir
        # Call java inside the directory - extract all the images with PDFBox
        $command = ("-jar `"$scriptDir"+[IO.Path]::DirectorySeparatorChar+".."+[IO.Path]::DirectorySeparatorChar+"lib"+[IO.Path]::DirectorySeparatorChar+"pdfbox-app-2.0.14.jar`" PDFToImage `"" + $f.name + "`"");
        Write-Output "Converting $f..."
        $ret = callProcess -executable "java" -directory $newDir -arguments $command -useShellExecute $false
        if ($ret -ne 0) {
            Write-Output ("[ERROR] Java returned $ret while extracting images from " + $f.name)
        }
        else {
            # Remove the PDF file
            Remove-Item -Path ($newDir + [IO.Path]::DirectorySeparatorChar + $f.name)  -Force
            # This library names the images like this:
            # XXX1.jpg
            # XXX2.jpg
            # ...
            # XXX9.jpg
            # XXX10.jpg
            # XXX11.jpg
            #
            # Which results in older readers ordering pages like this:
            # XXX1.jpg
            # XXX10.jpg
            # XXX11.jpg
            # XXX12.jpg
            # ...
            # XXX19.jpg
            # XXX2.jpg
            # XXX20.jpg
            # XXX21.jpg
            # ...
            # 
            # We should detect this and rename the files, filling at left with as
            #   many zeroes as necessary depending on the total files
            $totalFiles = ( Get-ChildItem $newDir | Measure-Object ).Count
            if ($totalFiles -gt 9) {
                # How many zeroes?  
                $zeroes = calculateZeroes -totalFiles $totalFiles
                $images = Get-ChildItem -Path $newDir -Filter $('*.jpg')
                foreach ($image in $images) {
                    # Get the number
                    $number = $image.name.replace($prefix, "").replace($suffix, "")
                    $paddedNumber = $number.PadLeft($zeroes,"0")
                    $newFile = $prefix + $paddedNumber + $suffix
                    Rename-Item -Path $image.fullname -NewName ($newDir + [IO.Path]::DirectorySeparatorChar + $newFile)
                }
            }
        }
    }

    # Repack everything
    zipcomics -sourceDir $tempDir -targetDir $dir

    Remove-Item -Path $tempDir -Recurse -Force
}