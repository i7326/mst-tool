﻿# This script / function will help you build an msi package using the WiX Toolset.
# It contains functions for the following:
# 1. Create folder structure of source code for XML file using heat.exe.
# 2. Create basic XML template file for building the msi.
# 3. Programatically Run Light and Candle and output the msi.

# Function "wrapper" for heat.
function Build-HeatXML() {
    param (
    [Parameter(mandatory=$true)][string]$HarvestInput, # This should be the actual Harvest Type object, aka your source. ( Directory | File | Project | Website | Perf | Reg )
    [Parameter(mandatory=$true)][ValidateSet("dir","file","project","website","perf","reg")][string]$HarvestType, # This is the type of harvest you will perform.
    [Parameter(mandatory=$true)][string]$HeatOpts, # This should be a string of your heat options. Ex: "-cg -template fragment -sfrag -gg"
    [Parameter(mandatory=$false)][string]$OutFileName, # You can set this to whatever file name you would like. It will append .wsx to the end of the file name.
    [Parameter(mandatory=$false)][string]$OutDir
    )
    
    try {
        $CurrentDir = $OutDir
        # Run the heat command on the directory with the command arguments.
        switch ($HarvestType) {
            "dir" {
                # Harvest a Directory
                if ($OutFileName) { heat dir $HarvestInput $HeatOpts -out "$CurrentDir\$OutFileName.wxs" }
                else { heat dir $HarvestInput $HeatOpts -out directory.wxs }
            }
            "file" {
                # Harvest a File
                if ($OutFileName) { heat file $HarvestInput $HeatOpts -out $OutFileName.wxs }
                else { heat file $HarvestInput $HeatOpts -out file.wxs }
            }
            "project" {
                # Harvest a Visual Studio Project
                if ($OutFileName) { heat project $HarvestInput $HeatOpts -out $OutFileName.wxs }
                else { heat project $HarvestInput $HeatOpts -out project.wxs }
            }
            "website" {
                # Harvest a Website
                if ($OutFileName) { heat website $HarvestInput $HeatOpts -out $OutFileName.wxs } 
                else { heat website $HarvestInput $HeatOpts -out website.wxs }
            }
            "perf" {
                # Harvest Performance Counters
                if ($OutFileName) { heat perf $HarvestInput $HeatOpts -out $OutFileName.wxs }
                else { heat perf $HarvestInput $HeatOpts -out perf.wxs }
            }
            "reg" {
                # Harvest a Registry File
                if ($OutFileName) { heat reg registry.reg $HeatOpts -out $OutFileName.wxs }
                else { heat reg registry.reg $HeatOpts -out reg.wxs }
            }
        }
    }

    catch {
        Write-Warning $_
    }
}

# Function for building the WiX XML file.
function Build-TemplateXML() {
  param (
    [Parameter(mandatory=$true)][string]$Path,
    [Parameter(mandatory=$true)][string]$AppName,
    [Parameter(mandatory=$true)][string]$AppVersion,
    [Parameter(mandatory=$true)][string]$AppManufacturer,
    [Parameter(mandatory=$false)][string]$InstallScope = 'perMachine',
    [Parameter(mandatory=$true)][string]$HeatFile
  )
  try {
    # Get the information from the heat file.
    $SourceFiles = Get-Content($HeatFile)

    # Create a new XMLTextWriter object to start building the XML
    $XmlWriter = New-Object System.XMl.XmlTextWriter($Path,$Null)

    # choose a pretty formatting:
    $XmlWriter.Formatting = 'Indented'

    # write the header
    $XmlWriter.WriteStartDocument()
    # $XmlWriter.WriteAttributeString('encoding', 'UTF-8')

    # Create "Wix" Element and its xmlns
    $XmlWriter.WriteStartElement('Wix')
    $XmlWriter.WriteAttributeString('xmlns', 'http://schemas.microsoft.com/wix/2006.wi')

    # Create "Product" Element and Setup Attributes
    $UpgradeCode = [System.GUID]::NewGuid().ToString() # Generate GUID for $UpgradeCode
    $XmlWriter.WriteStartElement('Product')
    $XmlWriter.WriteAttributeString('Id', '*')
    $XmlWriter.WriteAttributeString('Name', $AppName)
    $XmlWriter.WriteAttributeString('Language', '1033')
    $XmlWriter.WriteAttributeString('Version', $AppVersion)
    $XmlWriter.WriteAttributeString('Manufacturer', $AppManufacturer)
    $XmlWriter.WriteAttributeString('UpgradeCode', $UpgradeCode)

    # Create "Package" Element and Setup Attributes.
    $XmlWriter.WriteStartElement('Package')
    $XmlWriter.WriteAttributeString('InstallerVersion', '200')
    $XmlWriter.WriteAttributeString('Compressed', 'yes')
    $XmlWriter.WriteAttributeString('InstallScope', $InstallScope)
    $XmlWriter.WriteEndElement() # Close Package

    # Create "MajorUpgrade" Element and Set Attribute.
    $XmlWriter.WriteStartElement('MajorUpgrade')
    $XmlWriter.WriteAttributeString('DowngradeErrorMessage', ('A newer version of ' + $AppName + ' is already installed.'))
    $XmlWriter.WriteEndElement() # Close MajorUpgrade

    # Create "MediaTemplate" Element
    $XmlWriter.WriteStartElement('MediaTemplate')
    $XmlWriter.WriteEndElement() # Close MediaTemplate

    # Create "Feature" Element and Setup Attributes
    $XmlWriter.WriteStartElement('Feature')
    $XmlWriter.WriteAttributeString('Id', 'ProductFeature')
    $XmlWriter.WriteAttributeString('Title', $AppName)
    $XmlWriter.WriteAttributeString('Level', '1')

    # Create "ComponentGroupRef" Element and Setup Attributes
    $XmlWriter.WriteStartElement('ComponentGroupRef')
    $XmlWriter.WriteAttributeString('Id', 'ProductComponents')
    $XmlWriter.WriteEndElement() # Close ComponentRefGroup
    $XmlWriter.WriteEndElement() # Close Feature
    $XmlWriter.WriteEndElement() # Close Product

    # Create "Fragment" Element for "Directory" and Setup Attributes.
    $XmlWriter.WriteStartElement('Fragment')
    $XmlWriter.WriteStartElement('Directory')
    $XmlWriter.WriteAttributeString('Id', 'TARGETDIR')
    $XmlWriter.WriteAttributeString('Name', 'SourceDir')
    $XmlWriter.WriteStartElement('Directory')
    $XmlWriter.WriteAttributeString('Id', 'ProgramFilesFolder')
    $XmlWriter.WriteStartElement('Directory')
    $XmlWriter.WriteAttributeString('Id', 'INSTALLFOLDER')
    $XmlWriter.WriteAttributeString('Name', $AppName)
    $XmlWriter.WriteEndElement() # Close INSTALLFOLDER Directory
    $XmlWriter.WriteEndElement() # Close ProgramFilesFolder Directory
    $XmlWriter.WriteEndElement() # Close TARGETDIR Directory
    $XmlWriter.WriteEndElement() # Close Fragment

    # Create "Fragment" Element for "ComponentGroup" with Components / Files and Setup Attributes.
    $XmlWriter.WriteStartElement('Fragment')
    $XmlWriter.WriteStartElement('ComponentGroup')
    $XmlWriter.WriteAttributeString('Id', 'ProductComponents')
    $XmlWriter.WriteAttributeString('Directory', 'INSTALLFOLDER')
    $XmlWriter.WriteStartElement('Component')
    $XmlWriter.WriteAttributeString('Id', 'ProductComponent')
    $XmlWriter.WriteComment("This is where your file list from heat will go.")

    # This is where your files will go!
    
    $XmlWriter.WriteEndElement() # Close Component
    $XmlWriter.WriteEndElement() # Close ComponentGroup
    $XmlWriter.WriteEndElement() # Close Fragment
    $XmlWriter.WriteEndElement() # Close Wix

    # finalize the document:
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()
    #notepad $Path # Uncomment this if you want to automatically open the newly created xml in notepad 

  }

  catch {
    Write-Warning $_
  }
}

# Function to run both Candle.exe and Light.exe
function Build-MSI() {
    param (
        [Parameter(mandatory=$true)][string]$FileName # This should be the file name of your .wxs file.
    )
    try {
        # First Run Candle.exe (This is the WiX compiler.)
        candle $FileName.wsx
        # Then Run Light.exe (This is the WiX Linker which generates the final installer.)
        light $FileName.wixobj
    }

    catch {
        Write-Warning $_
    }
}

# Function to put it all together!
function Posh-MSI() {
    try {
        $HarvestType = "dir"
        $HarvestInput = "C:\Users\935055\Downloads\XCOPY"
        $HeatOpts = "-gg -cg PwC_Files -template fragement"
        $OutFileName = "dir"
        $OutDir = "C:\Users\935055\Downloads"
      
        Build-HeatXML -HarvestType $HarvestType -HarvestInput $HarvestInput -HeatOpts $HeatOpts -OutDir $OutDir -OutFileName $OutFileName 

        # Ask for information for the basic template xml file.
        $HeatFile = "$OutDir\$OutFileName.wxs"
        $AppName = "sample"
        $Path = $OutDir
        $AppVersion = "1.0"
        $AppManufacturer = "PwC"
        $FileName = "final"
        Build-TemplateXML -Path "$Path\$FileName.wsx" -AppName $AppName -AppVersion $AppVersion -AppManufacturer $AppManufacturer -HeatFile $HeatFile
        Write-Host ("Building the " + $FileName + ".msi.")
        Build-MSI -FileName $FileName
        $CurrentDir = pwd
        Write-Host ("You should find your final " + $FileName + ".msi in the " + $CurrentDir + " directory.")
    }
    catch {
        Write-Warning $_
    }
}

Posh-MSI