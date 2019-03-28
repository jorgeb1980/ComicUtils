### ComicUtils
Set of powershell scripts useful for managing a comics collection

## Requirements

We need the following software:

+ Tested with Powershell version 5

$PSVersionTable.PSVersion

Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      17134  590

+ Tested with Java 8

java -version
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)

+ Tested with 7z 18.05

7z -version

7-Zip 18.05 (x64) : Copyright (c) 1999-2018 Igor Pavlov : 2018-04-30

## Scripts

+ repack.ps1 - will repack any .cbz and .cbr file in cwd into a .cbz packed with DEFLATE.  This is compatible with most of the older readers I use.
+ pdf2cbz.ps1 - will convert every PDF in cwd to a set of images using Apache PDFBox, and pack them into a .cbz packed with DEFLATE.