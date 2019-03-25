# Utility functions
function isDirectory {
    param( [string]$file)

    return Test-Path -Path $file -PathType 'Container'
}

function callProcess {
    param([string]$executable,[string]$arguments)

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $executable
    $pinfo.Arguments = $arguments
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $ret = $p.ExitCode
    return $ret
}
