# Utility functions
function isDirectory {
    param( [string]$file)

    return Test-Path -Path $file -PathType 'Container'
}

function callProcess {
    param([string]$executable,[string]$directory,[string]$arguments)

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $executable
    $pinfo.Arguments = $arguments
    #$pinfo.RedirectStandardError = $true
    #$pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $true
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
