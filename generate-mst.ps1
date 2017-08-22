[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[string]$Path="\\vd005131\Users\935055\Documents\Packaging\workdir\Google Drive plug-in\1.7.24.0\P1.00\Files\Google_DrivePlugin_1.7.24.0_EN.msi",
	[Parameter(Mandatory=$false)]
	[string]$PackageName="Google_Driveplugin_1.7.24.0_EN_01",
	[Parameter(Mandatory=$false)]
	[ValidateNotNullorEmpty()]
	[boolean]$ContinueOnError = $true
)
[string]$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
[int32]$OpenReadMode = 0
[int32]$OpenWriteMode = 2
[int32]$msiSuppressApplyTransformErrors = 63
[string]$Table = 'Property'
[string]$TemplateMST = "$((get-item $ScriptDir).parent.FullName)\template\Branding.mst"
[string]$FinalPath = (New-Item "$((Get-Item $Path).Directory)\P1.00" -type directory -force).FullName
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
$TempMSIPath = "$((New-Item -ItemType Directory -Path "$env:Temp\MST-Tool\$PackageName" -Force).FullName)\$((Get-Item $Path).Name)"
try{
	Copy-Item -Path $Path -Destination $TempMSIPath -Force -ErrorAction SilentlyContinue
}
catch [Exception]{
	$ScriptError = $_.Exception.Message
}
try{
	[__comobject]$Installer = New-Object -ComObject WindowsInstaller.Installer -ErrorAction 'Stop'
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
try{
	[__comobject]$Database = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($Path, $OpenReadMode)
}
catch{
	$ScriptError = "Access denied : $Path"
}
[__comobject]$TempDatabase = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($TempMSIPath, 2)


    [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("SELECT * FROM Feature WHERE Feature='PwC_Branding_Registry'")
    $null = &$InvokeMethod -Object $View -MethodName 'Execute' | Out-Null
    [__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
    If (-Not $Record) {
    echo "running"
		[__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Feature (Feature,Feature_Parent,Title,Description,Display,Level,Directory_,Attributes) VALUES ('PwC_Branding_Registry','','PwC Branding Registry','Adds PwC branding to the package','0','1','ProgramFilesFolder','16')")
	    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
	    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)

        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Component (Component,ComponentId,Directory_,Attributes,Condition,KeyPath) VALUES ('PwC_Branding_Registry','{7726FDE8-6C94-42A7-8EF6-CAB447432A02}','ProgramFilesFolder','4','','BrandingRegistry1')")
	    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
	    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)

        [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO FeatureComponents (Feature_,Component_) VALUES ('PwC_Branding_Registry','PwC_Branding_Registry')")
	    $null = &$InvokeMethod -Object $View -MethodName 'Execute'
	    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)


            #[__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Registry (Registry,Root,Key,Name,Value,Component_) VALUES ('','','','','','')")
            [__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Registry (Registry,Root,Name,Value,Component_) VALUES (?,?,?,?,?)")
            $record = &$InvokeMethod -Object $Installer -MethodName 'CreateRecord' -ArgumentList @(5)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(1,"SampleReg")
            $null = &$SetProperty -Object $record -PropertyName 'IntegerData' -ArgumentList @(2,2)
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(3,"testName")
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(4,"testValue" )
            $null = &$SetProperty -Object $record -PropertyName 'StringData' -ArgumentList @(5,"alkaneComponent")
	        $null = &$InvokeMethod -Object $View -MethodName 'Execute' -ArgumentList @()
	        $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
            $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($record)
	        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)

        
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
} catch { }
$Properties.GetEnumerator() | ForEach-Object { &$InsertProperty -PropertyName $_.Key -PropertyValue $_.Value }
Copy-Item $Path -Destination "$FinalPath\$($PackageName -Replace "_$($PropertyList[4])").msi" -Force -ErrorAction SilentlyContinue
$null = &$InvokeMethod -Object $TempDatabase -MethodName 'GenerateTransform' -ArgumentList @($Database,"$FinalPath\$($PackageName).mst")
$null = &$InvokeMethod -Object $TempDatabase -MethodName 'CreateTransformSummaryInfo' -ArgumentList @($Database,"$FinalPath\$PackageName.mst", 0, 1)
try{
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($TempDatabase)
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Database)
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Installer)
} catch { }
Remove-Item (Get-Item $TempMSIPath).Directory -Force -Recurse -ErrorAction SilentlyContinue
Write-Output("$FinalPath\$PackageName.mst" | ConvertTo-Json -Compress)
