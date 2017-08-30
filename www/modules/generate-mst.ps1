[CmdletBinding()]
Param (
	[Parameter(Mandatory=$true)]
	[string]$Path,
	[Parameter(Mandatory=$true)]
	[string]$PackageName,
    [Parameter(Mandatory=$true)]
	[string]$Temp,
	[Parameter(Mandatory=$false)]
	[boolean]$ActiveSetup = $false,
    [Parameter(Mandatory=$false)]
	[boolean]$Exclude = $false
)
[int32]$OpenReadMode = 0
[int32]$OpenWriteMode = 2
[int32]$msiSuppressApplyTransformErrors = 63
[psobject]$ErrorObject = New-Object -TypeName PSObject

Try {
[string]$FinalPath = (New-Item "$((Get-Item $Path -ErrorAction SilentlyContinue).Directory)\P1.00" -type directory -force).FullName
} Catch {  }
[string[]] $PropertyList = $PackageName.split('_')
[hashtable] $Properties = if(-Not $Exclude){@{
	PwCPackageName = $PackageName
	PwCLang = $PropertyList[3]
	PwCRelease = $PropertyList[4]
	ARPCOMMENTS = $PackageName
    ARPNOMODIFY = 1
    REBOOT = "ReallySuppress"
    REBOOTPROMPT = "S"
    REINSTALLMODE = "vomus"
    ROOTDRIVE = "C:\"
    MSIRESTARTMANAGERCONTROL = "Disable"
}}else{@{
ARPNOMODIFY = 1
    REBOOT = "ReallySuppress"
    REBOOTPROMPT = "S"
    REINSTALLMODE = "vomus"
    ROOTDRIVE = "C:\"
    MSIRESTARTMANAGERCONTROL = "Disable"
}}

[hashtable] $Registries = @{
	Time = "[Time]"
	Date = "[Date]"
	PwCRelease = "[PwCRelease]"
	PwCLang = "[PwCLang]"
    Manufacturer = "[Manufacturer]"
    ProductVersion = "[ProductVersion]"
    PwCPackageName = "[PwCPackageName]"
    ProductCode = "[ProductCode]"
    ProductName = "[ProductName]"
}

$ValidationReg = @"
Registry	Component_	N			Component	1	Identifier		Foreign key into the Component table referencing component that controls the installing of the registry value.
Registry	Key	N					RegPath		The key for the registry value.
Registry	Name	Y					Formatted		The registry value name.
Registry	Registry	N					Identifier		Primary key, non-localized token.
Registry	Root	N	-1	3					The predefined root key for the registry value, one of rrkEnum.
Registry	Value	Y					Formatted		The registry value.
"@

Try {
$TempMSIPath = "$((New-Item -ItemType Directory -Path "$Temp\$PackageName" -Force).FullName)\$((Get-Item $Path -ErrorAction SilentlyContinue).Name)"
} Catch { }

Function Exit-script {
    param(
	    [string]$ErrorOutput
    )
    Try{
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($TempDatabase)
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Database)
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Installer)
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Record)
    } Catch { }
    Throw $ErrorOutput
    Exit 0
}

Try{
	Copy-Item -Path $Path -Destination $TempMSIPath -Force -ErrorAction SilentlyContinue
}
catch [Exception]{
	$ScriptError = $_.Exception.Message
    Exit-script -ErrorOutput $ScriptError
}

Try{
	[__comobject]$Installer = New-Object -ComObject WindowsInstaller.Installer -ErrorAction Stop
}
catch [Exception]{
	$ScriptError = $_.Exception.Message
    Exit-script -ErrorOutput $ScriptError
}

[scriptblock]$InvokeMethod = {
	Param (
		[__comobject]$Object,
		[string]$MethodName,
		[object[]]$ArgumentList
	)
	$Object.GetType().InvokeMember($MethodName, [System.Reflection.BindingFlags]::InvokeMethod, $null, $Object, $ArgumentList, $null, $null, $null)
}

[scriptblock]$SetProperty = {
			Param (
				[__comobject]$Object,
				[string]$PropertyName,
				[object[]]$ArgumentList
			)
			$Object.GetType().InvokeMember($PropertyName, [System.Reflection.BindingFlags]::SetProperty, $null, $Object, $ArgumentList, $null, $null, $null)
}

[scriptblock]$GetProperty = {
			Param (
				[__comobject]$Object,
				[string]$PropertyName,
				[object[]]$ArgumentList
			)
			$Object.GetType().InvokeMember($PropertyName, [System.Reflection.BindingFlags]::GetProperty, $null, $Object, $ArgumentList, $null, $null, $null)
}

[scriptblock]$QuerytoDB = {
			Param (
                [__comobject]$Database,
				[string]$Query
			)
			[__comobject]$View = &$InvokeMethod -Object $Database -MethodName 'OpenView' -ArgumentList @($Query)
	        $null = &$InvokeMethod -Object $View -MethodName 'Execute'
	        $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
}

[scriptblock]$InsertintoDBReg = {
			Param (
                [__comobject]$Object,
				[string]$Registry,
                [int32]$Root,
                [string]$Path,
                [string]$Name,
                [string]$Value,
                [string]$Component
			)
			$record = &$InvokeMethod -Object $Installer -MethodName 'CreateRecord' -ArgumentList @(6)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(1,$Registry)
            $null = &$SetProperty -Object $record -PropertyName 'IntegerData' -ArgumentList @(2,$Root)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(3,$Path)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(4,$Name)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(5,$Value)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(6,$Component)
	        $null = &$InvokeMethod -Object $Object -MethodName 'Modify' -ArgumentList @(1,$record)
            $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($record)
}

Try{
	[__comobject]$Database = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($Path, $OpenReadMode)
}
catch{
	$ScriptError = "Access denied : $Path"
    Exit-script -ErrorOutput $ScriptError
}
Try {
    [__comobject]$TempDatabase = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($TempMSIPath, 2)
}
Catch {
    $ScriptError = "Error Opening Temporary Database"
    Exit-script -ErrorOutput $ScriptError
}
Try {
    [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Feature WHERE Feature='PwC_Branding_Registry'")
    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
    [__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    If (-Not $Record -and -Not $Exclude) {
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Feature (Feature,Feature_Parent,Title,Description,Display,Level,Directory_,Attributes) VALUES ('PwC_Branding_Registry','','PwC Branding Registry','Adds PwC branding to the package','0','1','INSTALLDIR','16')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Component (Component,ComponentId,Directory_,Attributes,Condition,KeyPath) VALUES ('PwC_Branding_Registry','{$(([GUID]::NewGuid()).ToString().ToUpper())}','TARGETDIR','4','','Branding.1')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO FeatureComponents (Feature_,Component_) VALUES ('PwC_Branding_Registry','PwC_Branding_Registry')"
        if((&$GetProperty -Object $TempDatabase -PropertyName 'TablePersistent' -ArgumentList @("Registry")) -ne 1) {           
           $null = &$InvokeMethod -Object $TempDatabase -MethodName 'Import' -ArgumentList @($Temp,"Registry.idt")
           $null = &$InvokeMethod -Object $TempDatabase -MethodName 'Export' -ArgumentList @("_Validation",$Temp,"_Validation.idt")
           Add-Content "$Temp\_Validation.idt" "$ValidationReg" | Out-Null
           $null = &$InvokeMethod -Object $TempDatabase -MethodName 'Import' -ArgumentList @($Temp,"_Validation.idt")
        }
        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Registry")
        $null = &$InvokeMethod -Object $View -MethodName 'Execute'
        $i = 1
        $Registries.GetEnumerator() | ForEach-Object {
            $regName = "Branding.$i"
            $null = &$InsertintoDBReg  -Object $View -Registry $regName -Root 2 -Path "SOFTWARE\PwC\SW\[PwCPackageName]" -Name $_.Key -Value $_.Value -Component "PwC_Branding_Registry"
            $i++
        }
        Try {
            $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
            $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
            $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Record)
        } Catch{

        }
    }
} Catch {
    $ScriptError = "Error Adding Branding Registry"
    Exit-script -ErrorOutput $ScriptError
}
Try {
    if($ActiveSetup) {
        [__comobject]$SummaryInfo = &$GetProperty -Object $TempDatabase -PropertyName 'SummaryInformation'
        [string]$Template = &$GetProperty -Object $SummaryInfo -PropertyName 'Property' -ArgumentList @(7)
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($SummaryInfo)
        $componentAttribute = if ($Template -match "64") {260} else {4}
        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Directory WHERE Directory='LocalAppDataFolder'")
        $null = &$InvokeMethod -Object $View -MethodName 'Execute'
        [__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
        $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
        If (-Not $Record) {
            $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Directory (Directory,Directory_Parent,DefaultDir) VALUES ('LocalAppDataFolder','TARGETDIR','.:APPLIC~1|Application Data')"  
        }
        Try {
            $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Record)
        } Catch{ }
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Feature (Feature,Feature_Parent,Title,Description,Display,Level,Directory_,Attributes) VALUES ('PwC_Active_Setup','','PwC Active Setup','Adds Active Setup Entry to the package','0','1','INSTALLDIR','16')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Component (Component,ComponentId,Directory_,Attributes,Condition,KeyPath) VALUES ('PwC_Active_Setup_HKLM','{$(([GUID]::NewGuid()).ToString().ToUpper())}','TARGETDIR',$componentAttribute,'','ActiveSetupHKLM.1')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Component (Component,ComponentId,Directory_,Attributes,Condition,KeyPath) VALUES ('PwC_Active_Setup_HKCU','{$(([GUID]::NewGuid()).ToString().ToUpper())}','LocalAppDataFolder',$componentAttribute,'','ActiveSetupHKCU.1')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO FeatureComponents (Feature_,Component_) VALUES ('PwC_Active_Setup','PwC_Active_Setup_HKLM')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO FeatureComponents (Feature_,Component_) VALUES ('PwC_Active_Setup','PwC_Active_Setup_HKCU')"
        if($Exclude) {
           if((&$GetProperty -Object $TempDatabase -PropertyName 'TablePersistent' -ArgumentList @("Registry")) -ne 1) {           
              $null = &$InvokeMethod -Object $TempDatabase -MethodName 'Import' -ArgumentList @($Temp,"Registry.idt")
              $null = &$InvokeMethod -Object $TempDatabase -MethodName 'Export' -ArgumentList @("_Validation",$Temp,"_Validation.idt")
              Add-Content "$Temp\_Validation.idt" "$ValidationReg" | Out-Null
              $null = &$InvokeMethod -Object $TempDatabase -MethodName 'Import' -ArgumentList @($Temp,"_Validation.idt")
          }
        }
        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Registry")
        $null = &$InvokeMethod -Object $View -MethodName 'Execute'
        $null = &$InsertintoDBReg -Object $View -Registry "ActiveSetupHKCU.1" -Root 1 -Path "Software\Microsoft\Active Setup\Installed Components\[ProductCode]" -Name "Version" -Value "1,0,0" -Component "PwC_Active_Setup_HKCU"
        $null = &$InsertintoDBReg -Object $View -Registry "ActiveSetupHKLM.1" -Root 2 -Path "SOFTWARE\Microsoft\Active Setup\Installed Components\[ProductCode]" -Name "Version" -Value "1,0,0" -Component "PwC_Active_Setup_HKLM"
        $null = &$InsertintoDBReg -Object $View -Registry "ActiveSetupHKLM.2" -Root 2 -Path "SOFTWARE\Microsoft\Active Setup\Installed Components\[ProductCode]" -Name "StubPath" -Value "msiexec /foups [ProductCode] /l*v [WindowsFolder]Logs" -Component "PwC_Active_Setup_HKLM"
        $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    }
} Catch { 
    $ScriptError = "Error Adding ActiveSetup"
    Exit-script -ErrorOutput $ScriptError
}
Try {
[scriptblock]$InsertProperty = {
	Param (
		[string]$PropertyName,
		[string]$PropertyValue
	)
    [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Property WHERE Property='$PropertyName'")
    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
    [__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    If ($Record) {
		[__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("UPDATE Property SET Value='$PropertyValue' WHERE Property='$PropertyName'")
	} Else {
		[__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Property (Property, Value) VALUES ('$PropertyName','$PropertyValue')")
	}
	$null = &$InvokeMethod -Object $View -MethodName 'Execute'
	$null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    }
} Catch { 
    $ScriptError = "Error Adding Properties."
    Exit-script -ErrorOutput $ScriptError
}
$Properties.GetEnumerator() | ForEach-Object { &$InsertProperty -PropertyName $_.Key -PropertyValue $_.Value }

Try {
    Copy-Item $Path -Destination "$FinalPath\$($PackageName -Replace "_$($PropertyList[4])").msi"   -ErrorAction Stop -Force
} Catch [Exception]{
    $ScriptError = $_.Exception.Message
    Exit-script -ErrorOutput $ScriptError
}
Try {
    $null = &$InvokeMethod -Object $TempDatabase -MethodName 'GenerateTransform' -ArgumentList @($Database,"$FinalPath\$($PackageName).mst")
    $null = &$InvokeMethod -Object $TempDatabase -MethodName 'CreateTransformSummaryInfo' -ArgumentList @($Database,"$FinalPath\$PackageName.mst", 0, 1)
} Catch {
   $ScriptError = "Error Generating MST. Please check if a previously created MST is open."
   Exit-script -ErrorOutput $ScriptError
}
Try{
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($TempDatabase)
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Database)
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Installer)
} Catch { }
Try {
    Remove-Item (Get-Item $TempMSIPath).Directory -Force -Recurse -ErrorAction SilentlyContinue
} Catch { }

Write-Output("$FinalPath\$PackageName.mst" | ConvertTo-Json -Compress)