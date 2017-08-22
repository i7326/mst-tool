[CmdletBinding()]
Param (
	[Parameter(Mandatory=$true)]
	[string]$Path,
	[Parameter(Mandatory=$true)]
	[string]$PackageName,
	[Parameter(Mandatory=$false)]
	[ValidateNotNullorEmpty()]
	[boolean]$ContinueOnError = $true
)
[string]$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
[int32]$OpenReadMode = 0
[int32]$OpenWriteMode = 2
[int32]$msiSuppressApplyTransformErrors = 63

Try {
[string]$FinalPath = (New-Item "$((Get-Item $Path -ErrorAction Stop).Directory)\P1.00" -type directory -force).FullName
} Catch { 
}
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
$TempMSIPath = "$((New-Item -ItemType Directory -Path "$env:Temp\MST-Tool\$PackageName" -Force).FullName)\$((Get-Item $Path -ErrorAction Stop).Name)"

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

Try{
	[__comobject]$Database = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($Path, $OpenReadMode)
}
catch{
	$ScriptError = "Access denied : $Path"
}

Try {
    [__comobject]$TempDatabase = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($TempMSIPath, 2)
    [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Feature WHERE Feature='PwC_Branding_Registry'")
    $null = &$InvokeMethod -Object $View -MethodName 'Execute' | Out-Null
    [__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    If (-Not $Record) {
		[__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Feature (Feature,Feature_Parent,Title,Description,Display,Level,Directory_,Attributes) VALUES ('PwC_Branding_Registry','','PwC Branding Registry','Adds PwC branding to the package','0','1','PROGRAMFILESFOLDER','16')")
	    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
	    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)

        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Component (Component,ComponentId,Directory_,Attributes,Condition,KeyPath) VALUES ('PwC_Branding_Registry','{$(([GUID]::NewGuid()).ToString().ToUpper())}','ProgramFilesFolder','4','','Branding.1')")
	    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
	    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)

        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO FeatureComponents (Feature_,Component_) VALUES ('PwC_Branding_Registry','PwC_Branding_Registry')")
	    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
	    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)

        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Registry")
        $null = &$InvokeMethod -Object $View -MethodName 'Execute'
        $i = 1
        $Registries.GetEnumerator() | ForEach-Object {
            $regName = "Branding.$i"
            $record = &$InvokeMethod -Object $Installer -MethodName 'CreateRecord' -ArgumentList @(6)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(1,$regName)
            $null = &$SetProperty -Object $record -PropertyName 'IntegerData' -ArgumentList @(2,2)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(3,"SOFTWARE\PwC\SW\[PwCPackageName]")
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(4,$_.Key)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(5,$_.Value )
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(6,"PwC_Branding_Registry")
	        $null = &$InvokeMethod -Object $View -MethodName 'Modify' -ArgumentList @(1,$record)
            $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($record)
            $i++
        }
        $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
        
    }
} Catch {
    $ScriptError = "Error Adding Branding Registry"
}

Try {
[scriptblock]$InsertProperty = {
	Param (
		[string]$PropertyName,
		[string]$PropertyValue
	)
    [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Property WHERE Property='$PropertyName'")
    $null = &$InvokeMethod -Object $View -MethodName 'Execute' | Out-Null
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
} Catch {}
$Properties.GetEnumerator() | ForEach-Object { &$InsertProperty -PropertyName $_.Key -PropertyValue $_.Value }
Copy-Item $Path -Destination "$FinalPath\$($PackageName -Replace "_$($PropertyList[4])").msi" -Force -ErrorAction SilentlyContinue
$null = &$InvokeMethod -Object $TempDatabase -MethodName 'GenerateTransform' -ArgumentList @($Database,"$FinalPath\$($PackageName).mst")
$null = &$InvokeMethod -Object $TempDatabase -MethodName 'CreateTransformSummaryInfo' -ArgumentList @($Database,"$FinalPath\$PackageName.mst", 0, 1)
Try{
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($TempDatabase)
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Database)
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Installer)
} Catch { }
Remove-Item (Get-Item $TempMSIPath).Directory -Force -Recurse -ErrorAction SilentlyContinue
Write-Output("$FinalPath\$PackageName.mst" | ConvertTo-Json -Compress)
