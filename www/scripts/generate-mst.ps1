[CmdletBinding()]
Param (
	[Parameter(Mandatory=$true)]
	[string]$Path,
	[Parameter(Mandatory=$true)]
	[string]$PackageName,
	[Parameter(Mandatory=$false)]
	[boolean]$ActiveSetup = $false
)
[string]$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
[int32]$OpenReadMode = 0
[int32]$OpenWriteMode = 2
[int32]$msiSuppressApplyTransformErrors = 63

Try {
[string]$FinalPath = (New-Item "$((Get-Item $Path -ErrorAction SilentlyContinue).Directory)\P1.00" -type directory -force).FullName
} Catch {  }
[string[]] $PropertyList = $PackageName.split('_')
[hashtable] $Properties = @{
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
}
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

Try {
$TempMSIPath = "$((New-Item -ItemType Directory -Path "$env:Temp\MST-Tool\$PackageName" -Force).FullName)\$((Get-Item $Path -ErrorAction SilentlyContinue).Name)"
} Catch { }

Function Exit-script {
    param(
	    [string]$ErrorOutput
    )

}

Try{
	Copy-Item -Path $Path -Destination $TempMSIPath -Force -ErrorAction SilentlyContinue
}
catch [Exception]{
	$ScriptError = $_.Exception.Message
}

Try{
	[__comobject]$Installer = New-Object -ComObject WindowsInstaller.Installer -ErrorAction Stop
}
catch [Exception]{
	$ScriptError = $_.Exception.Message
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
}
Try {
    [__comobject]$TempDatabase = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($TempMSIPath, 2)
}
Catch {
    $ScriptError = "Error Opening Temporary Database"
}
Try {
    [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Feature WHERE Feature='PwC_Branding_Registry'")
    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
    [__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    If (-Not $Record) {
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Feature (Feature,Feature_Parent,Title,Description,Display,Level,Directory_,Attributes) VALUES ('PwC_Branding_Registry','','PwC Branding Registry','Adds PwC branding to the package','0','1','PROGRAMFILESFOLDER','16')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Component (Component,ComponentId,Directory_,Attributes,Condition,KeyPath) VALUES ('PwC_Branding_Registry','{$(([GUID]::NewGuid()).ToString().ToUpper())}','ProgramFilesFolder','4','','Branding.1')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO FeatureComponents (Feature_,Component_) VALUES ('PwC_Branding_Registry','PwC_Branding_Registry')"
        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Registry")
        $null = &$InvokeMethod -Object $View -MethodName 'Execute'
        $i = 1
        $Registries.GetEnumerator() | ForEach-Object {
            $regName = "Branding.$i"
            $null = &$InsertintoDBReg  -Object $View -Registry $regName -Root 2 -Path "SOFTWARE\PwC\SW\[PwCPackageName]" -Name $_.Key -Value $_.Value -Component "PwC_Branding_Registry"
            $i++
        }
        $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    }
} Catch {
    $ScriptError = "Error Adding Branding Registry"
}
Try {
    if($ActiveSetup) {
        [__comobject]$SummaryInfo = &$GetProperty -Object $TempDatabase -PropertyName 'SummaryInformation'
        [string]$Template = &$GetProperty -Object $SummaryInfo -PropertyName 'Property' -ArgumentList @(7)
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($SummaryInfo)
        $componentAttribute = if ($Template -match "64") {260} else {4}
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Feature (Feature,Feature_Parent,Title,Description,Display,Level,Directory_,Attributes) VALUES ('PwC_Active_Setup','','PwC Active Setup','Adds Active Setup Entry to the package','0','1','PROGRAMFILESFOLDER','16')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Component (Component,ComponentId,Directory_,Attributes,Condition,KeyPath) VALUES ('PwC_Active_Setup_HKLM','{$(([GUID]::NewGuid()).ToString().ToUpper())}','ProgramFilesFolder',$componentAttribute,'','ActiveSetupHKLM.1')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO Component (Component,ComponentId,Directory_,Attributes,Condition,KeyPath) VALUES ('PwC_Active_Setup_HKCU','{$(([GUID]::NewGuid()).ToString().ToUpper())}','AppDataFolder',$componentAttribute,'','ActiveSetupHKCU.1')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO FeatureComponents (Feature_,Component_) VALUES ('PwC_Active_Setup','PwC_Active_Setup_HKLM')"
        $null = &$QuerytoDB -Database $TempDatabase -Query "INSERT INTO FeatureComponents (Feature_,Component_) VALUES ('PwC_Active_Setup','PwC_Active_Setup_HKCU')"
        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Registry")
        $null = &$InvokeMethod -Object $View -MethodName 'Execute'
        $null = &$InsertintoDBReg -Object $View -Registry "ActiveSetupHKCU.1" -Root 1 -Path "Software\Microsoft\Active Setup\Installed Components\[ProductCode]" -Name "Version" -Value "1,0,0" -Component "PwC_Active_Setup_HKCU"
        $null = &$InsertintoDBReg -Object $View -Registry "ActiveSetupHKLM.1" -Root 2 -Path "SOFTWARE\Microsoft\Active Setup\Installed Components\[ProductCode]" -Name "Version" -Value "1,0,0" -Component "PwC_Active_Setup_HKLM"
        $null = &$InsertintoDBReg -Object $View -Registry "ActiveSetupHKLM.2" -Root 1 -Path "SOFTWARE\Microsoft\Active Setup\Installed Components\[ProductCode]" -Name "StubPath" -Value "msiexec /foups [ProductCode] /l*v [WindowsFolder]Logs" -Component "PwC_Active_Setup_HKLM"
        $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    }
} Catch { 
    $ScriptError = "Error Adding ActiveSetup"
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
}
$Properties.GetEnumerator() | ForEach-Object { &$InsertProperty -PropertyName $_.Key -PropertyValue $_.Value }
Try {
    Copy-Item $Path -Destination "$FinalPath\$($PackageName -Replace "_$($PropertyList[4])").msi" -Force -ErrorAction SilentlyContinue
} Catch [Exception]{
    $ScriptError = $_.Exception.Message
}
Try {
    $null = &$InvokeMethod -Object $TempDatabase -MethodName 'GenerateTransform' -ArgumentList @($Database,"$FinalPath\$($PackageName).mst")
    $null = &$InvokeMethod -Object $TempDatabase -MethodName 'CreateTransformSummaryInfo' -ArgumentList @($Database,"$FinalPath\$PackageName.mst", 0, 1)
} Catch {
   $ScriptError = "Error Generating MST. Please check if a previously created MST is open." 
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