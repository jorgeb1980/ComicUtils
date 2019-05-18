# ComicUtils
Set of powershell scripts useful for managing a comics collection

## Requirements

We need the following software (Linux instructions for Debian-like distros, please look for equivalents with your favorite package manager):

### Powershell 5

Tested with version:

```
$PSVersionTable.PSVersion

Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      17134  590
```

Get it for:
+ Windows: https://docs.microsoft.com/powershell/scripting/install/installing-windows-powershell
+ Linux: https://docs.microsoft.com/es-es/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6
+ MacOS: brew cask install powershell

### Java 8

Tested with version:

```
java -version
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
```

Get it for:
+ Windows: https://adoptopenjdk.net/
+ Linux: sudo apt-get install openjdk-8-jre-headless
+ MacOS: brew cask install caskroom/versions/java8


### 7z 18.05

Tested with version:

```
7z -version

7-Zip 18.05 (x64) : Copyright (c) 1999-2018 Igor Pavlov : 2018-04-30
```

Get it for:
+ Windows: https://www.7-zip.org/download.html
+ Linux: sudo apt install p7zip
    (maybe additional packages will be necessary, like p7zip-rar in certain distros)
+ MacOS: brew install p7zip

## Scripts

+ *repack.ps1* - will repack any .cbz and .cbr file in cwd into a .cbz comic packed with DEFLATE.  This is compatible with most of the older readers I use, like CDisplay.
+ *pdf2cbz.ps1* - will convert every PDF in cwd into a .cbz comic packed with DEFLATE.
+ *unpack.ps1* - will extract the content of all the comics in cwd into a directory with the same name.  Optional *-extension* parameter.

## Adittional information

For more information please see:

https://en.wikipedia.org/wiki/DEFLATE
https://www.7-zip.org/faq.html
https://pdfbox.apache.org/index.html