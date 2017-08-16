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
[string]$Table = 'Property'

[string]   $TemplateMST = "$((get-item $ScriptDir).parent.FullName)\template\Branding.mst"
[string]$FinalPath = (New-Item "$((Get-Item $Path).Directory)\P1.00" -type directory -force).FullName
[string[]] $PropertyList = $PackageName.split('_')

[hashtable] $Properties = @{
	PwCPackageName = $PackageName
	PwCLang = $PropertyList[3]
	PwCRelease = $PropertyList[4]
	ARPCOMMENTS = $PackageName
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

[scriptblock]$GetProperty = {
	Param (
		[__comobject]$Object,
		[string]$PropertyName,
		[object[]]$ArgumentList
	)
	$Object.GetType().InvokeMember($PropertyName, [System.Reflection.BindingFlags]::GetProperty, $null, $Object, $ArgumentList, $null, $null, $null)
}

try{
	[__comobject]$Database = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($Path, $OpenReadMode)
}
catch{
	$ScriptError = "Access denied : $Path"
}

[__comobject]$TempDatabase = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($TempMSIPath, 2)

[scriptblock]$InsertProperty = {
	Param (
		[string]$PropertyName,
		[string]$PropertyValue
	)
	[__comobject]$View = &$InvokeMethod -Object $TempDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Property (Property, Value) VALUES ('$PropertyName','$PropertyValue')")
	$null = &$InvokeMethod -Object $View -MethodName 'Execute'
	$null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
}

[__comobject]$ApplyTransform = &$InvokeMethod -Object $TempDatabase -MethodName 'ApplyTransform' -ArgumentList @($TemplateMST,$msiSuppressApplyTransformErrors)
$null = &$InvokeMethod -Object $TempDatabase -MethodName 'Commit' -ArgumentList @()

$Properties.GetEnumerator() | ForEach-Object { &$InsertProperty -PropertyName $_.Key -PropertyValue $_.Value }

$null = &$InvokeMethod -Object $TempDatabase -MethodName 'GenerateTransform' -ArgumentList @($Database,"$FinalPath\$PackageName.mst")
$null = &$InvokeMethod -Object $TempDatabase -MethodName 'CreateTransformSummaryInfo' -ArgumentList @($Database,"$FinalPath\$PackageName.mst", 0, 0)

try{
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($TempDatabase)
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Database)
	$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Installer)
} catch { }

Copy-Item $Path -Destination "$FinalPath\$($PackageName �Replace "_$($PropertyList[4])").msi" -Force -ErrorAction SilentlyContinue

Remove-Item (Get-Item $TempMSIPath).Directory -Force -Recurse -ErrorAction SilentlyContinue

Write-Output("$FinalPath\$PackageName.mst" | ConvertTo-Json -Compress)
















#[__comobject]$View = &$InvokeMethod -Object $NewDatabase -MethodName 'OpenView' -ArgumentList @("INSERT INTO Property (Property, Value) VALUES (PwCLang,'test')")
<# &$InvokeMethod -Object $View -MethodName 'Execute' | Out-Null
#>


#&$InvokeMethod -Object $NewDatabase -MethodName 'Close' -ArgumentList @() | Out-Null
#Copy-Item $Path -Destination "$FinalPath\$($PackageName –Replace ("_$PwCRelease"))" -Force -ErrorAction SilentlyContinue


#Write-Output($FinalMST | ConvertTo-Json -Compress)
