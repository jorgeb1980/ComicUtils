# Launched on a directory: 
#   + lists every pdf file present in the directory
#   + if there are PDF files, creates a temporary directory
#   + for each one of them, creates a child directory inside the temporary with the same name without extension,
#       and copies the pdf inside
#   + extracts every image in that file inside the child directory using apache pdfbox
#   + once every pdf is extracted into a directory, runs zipcomics.ps1 inside the temporary in order to
#       generate a cbz with the comic
#   + copies back the cbz files to the original directory, along the original PDFs


$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -Parent)

. "$scriptDir\utils.ps1"
checkDependencies

$dir = get-location
$tempDir = temporaryDirectory

$files = Get-ChildItem -Path $dir -Filter $('*.pdf')

if ($files.Length -gt 0) {
    $totalFiles = $files.Length
    $currentFile = 0

    # Create the children directory and copy the pdf there
    foreach ($f in $files) {
        Write-Progress -Activity "Extracting images from PDF..." `
            -Status ("Extracting -> $($f.name) ($($currentFile + 1)/$totalFiles)") `
            -PercentComplete (100 * $currentFile++ / $totalFiles)
        $nameNoBrackets = $(removeBrackets($f.name))
        $prefix = $nameNoBrackets.substring(0, $nameNoBrackets.LastIndexOf('.'))
        $newDir = ($tempDir + [IO.Path]::DirectorySeparatorChar + $prefix)
        New-Item -ItemType directory -Path ($newDir) | Out-Null
        # Remove brackets on the way there
        $destination = $newDir + [IO.Path]::DirectorySeparatorChar + $nameNoBrackets
        Copy-Item -LiteralPath $f.fullname -Destination $destination
        # Call java inside the directory - extract all the images with PDFBox
        $command = ("-jar `"$scriptDir" + [IO.Path]::DirectorySeparatorChar + ".." + [IO.Path]::DirectorySeparatorChar + "lib" + [IO.Path]::DirectorySeparatorChar + "pdfbox-app-2.0.14.jar`" PDFToImage `"" + $nameNoBrackets + "`"");
        $ret = callProcess -executable "java" -directory $newDir -arguments $command -useShellExecute $false
        if ($ret -ne 0) {
            Write-Output ("[ERROR] Java returned $ret while extracting images from $($f.name)")
        }
        else {
            # Remove the PDF file
            Remove-Item -LiteralPath ($newDir + [IO.Path]::DirectorySeparatorChar + $nameNoBrackets) -Force
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
            padWithZeroes -directory $newDir
            # Remove the original PDF file
            Remove-Item -LiteralPath $f.FullName -Force
        }
    }

    # Repack everything
    zipcomics -sourceDir $tempDir -targetDir $dir

    Remove-Item -Path $tempDir -Recurse -Force
}
