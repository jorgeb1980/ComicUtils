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

function checkDependencies {
    $checkJava = check -executable "java" -arguments "--version"
    $check7z = check -executable "7z" -arguments "--help"
    if (!$checkJava) {
        Write-Host("Cannot find java in path")
    }
    if (!$check7z) {
        Write-Host("Cannot find 7z in path")
    }
    if (!$check7z -or !$checkJava) {
        Exit -1
    }
}

function check {
    param([string]$executable,[string]$arguments)

    $checked = $true
    try {
        $code = callProcess -executable $executable -arguments $arguments -useShellExecute $false
        if ($code -ne 0) {
            Write-Host("$executable $arguments -> $code")
            $checked = $false
        }
    }
    catch {
        $checked = $false
    }
    return $checked
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
    if ($directory -ne $null){
        $pinfo.WorkingDirectory = $directory
    }
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $ret = $p.ExitCode
    return $ret
}

# Launched on a parent directory, lists every child directory, compresses its
#   content to a zip file and renames it as cbz

Add-Type -assembly "system.io.compression.filesystem"
function zipcomics {
    param([string]$sourceDir, [string]$targetDir)

    $source = Get-ChildItem -Path $sourceDir -Directory
    $totalZipFiles = $source.Length
    $currentZipFile = 0
    Foreach ($s in $source) {
        padWithZeroes -directory ($sourceDir + [IO.Path]::DirectorySeparatorChar + $s)
        $noBrackets = removeBrackets($s.name)
        $destination = Join-path -path $targetDir -ChildPath "$($noBrackets).cbz"
        Write-Progress -Activity "Zipping files..." `
            -Status ("Zipping -> $destination ($($currentZipFile + 1)/$totalZipFiles)")  `
            -PercentComplete (100 * $currentZipFile++ / $totalZipFiles)
        [io.compression.zipfile]::CreateFromDirectory($s.fullname, $destination)
    }
}

# Returns the full path of a temporary directory
function temporaryDirectory {
    $tempfile = [System.IO.Path]::GetTempFileName();
    remove-item $tempfile;
    (new-item -type directory -path $tempfile).fullName
}

function removeBrackets {
    param([string]$str)
    return ($str -replace '\s*\[.*\]\s*','').Trim()
}

# Credit to https://stackoverflow.com/questions/28436651/replacing-last-occurrence-of-substring-in-string
function replaceLastSubstring {
    param(
        [string]$str,
        [string]$substr,
        [string]$newstr
    )

    return $str.Remove(($lastIndex = $str.LastIndexOf($substr)),$substr.Length).Insert($lastIndex,$newstr)
}

function padWithZeroes {
    param([string]$directory)

    $totalImages = ( Get-ChildItem $directory | Measure-Object ).Count
    if ($totalImages -gt 9) {
        # How many zeroes?  
        $zeroes = calculateZeroes -totalFiles $totalImages
        $images = Get-ChildItem -Path $directory -Filter $('*.jpg')
        
        foreach ($image in $images) {      
            # Get the number
            $found = $image -match '(\d+)\.\D+$'
            if ($found) {
                $number = $matches[1]
                $paddedNumber = $number.PadLeft($zeroes,"0")
                $newFile = replaceLastSubstring -str $image -substr $number -newstr $paddedNumber
                Rename-Item -Path $image.fullname -NewName ($directory + [IO.Path]::DirectorySeparatorChar + $newFile)
            }
        }
    }
}