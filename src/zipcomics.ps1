# Launched on a parent directory, lists every child directory, compresses its
#   content to a zip file and renames it as cbz

Add-Type -assembly "system.io.compression.filesystem"

$dir = get-location
$source = Get-ChildItem -Path $dir -Directory
Foreach ($s in $source) {
    Write-Output $s
    $destination = Join-path -path $dir -ChildPath "$($s.name).zip"
    Write-Output "Compressing $destination ..."
    [io.compression.zipfile]::CreateFromDirectory($s.fullname, $destination)
}

Write-Output "Renaming to .cbz ..."

Get-ChildItem $dir\*.zip | rename-item -newname { [io.path]::ChangeExtension($_.name, "cbz") }