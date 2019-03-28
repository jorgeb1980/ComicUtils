# Utility functions
function isDirectory {
    param( [string]$file)

    return Test-Path -Path $file -PathType 'Container'
}

function calculateZeroes {
    param([int]$totalFiles)

    $asAString = [string] $totalFiles
    $asAString.Length
}

function callProcess {
    param([string]$executable,[string]$directory,[string]$arguments,[boolean]$useShellExecute)

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $executable
    $pinfo.Arguments = $arguments
    $pinfo.UseShellExecute = $useShellExecute
    if (!$useShellExecute) {
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
    }
    $pinfo.WorkingDirectory = $directory
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $ret = $p.ExitCode
    return $ret
}

# Horrible hack, but no way to properly delete the directory if not - always happens to 
#   try to create it before it is properly deleted
function deleteDirectory {
    param([string]$fileDir)

    if (Test-Path($fileDir)) {
        $keepOn = $TRUE;
        remove-item $fileDir -Recurse -Force -ErrorAction Stop
        While ( $keepOn ){
            Try{
                # It will crash with an exception if the directory is still locked
                Test-Path($fileDir)  | Out-Null           
                $keepOn = $FALSE
            }
            catch{
                Write-Verbose "File locked, trying again in 1"
                Start-Sleep -seconds 1
            }
        }
    }
}

# Launched on a parent directory, lists every child directory, compresses its
#   content to a zip file and renames it as cbz

Add-Type -assembly "system.io.compression.filesystem"
function zipcomics {
    param([string]$sourceDir, [string]$targetDir)

    $source = Get-ChildItem -Path $sourceDir -Directory
    Foreach ($s in $source) {
        Write-Output $s
        $destination = Join-path -path $targetDir -ChildPath "$($s.name).cbz"
        Write-Output "Compressing into $destination ..."
        [io.compression.zipfile]::CreateFromDirectory($s.fullname, $destination)
    }
}

# Returns the full path of a temporary directory
function temporaryDirectory {
    $tempfile = [System.IO.Path]::GetTempFileName();
    remove-item $tempfile;
    (new-item -type directory -path $tempfile).fullName
}