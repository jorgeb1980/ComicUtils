# Launched over a parent directory: 
#   + lists every pdf file present in the directory
#   + for each one of them, creates a child directory with the same name without extension,
#       and copies the pdf inside
#   + extracts every image in that file inside the child directory using apache pdfbox
#   + erases the pdf
#   + once every pdf is extracted into a directory, runs zipcomics.ps1 inside it in order to
#       generate a cbz with the comic

$dir = get-location

. .\utils.ps1

Write-Output "Looking for pdf files in $dir ..."
$files = Get-ChildItem -Path $dir -Filter $('*.pdf')

# Create the children directory and copy the pdf there
foreach ($f in $files) {
    $new_dir = $dir.path + "\" + $f.name.substring(0, $f.name.LastIndexOf('.'))
    Remove-Item $new_dir -Recurse -ErrorAction Ignore
    # Remove the directory if it exists
    New-Item -ItemType directory -Path ($new_dir)
}