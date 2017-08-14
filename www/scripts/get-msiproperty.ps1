	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Path,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string]$Table = 'Property',
        [Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[int32]$OpenMode = 0,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ContinueOnError = $true
	)

    [psobject]$TableProperties = New-Object -TypeName PSObject
    [__comobject]$Installer = New-Object -ComObject WindowsInstaller.Installer -ErrorAction 'Stop'
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
    [__comobject]$Database = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($Path, $OpenMode)
    [__comobject]$View = &$InvokeMethod -Object $Database -MethodName 'OpenView' -ArgumentList @("SELECT * FROM $Table")
	&$InvokeMethod -Object $View -MethodName 'Execute' | Out-Null
    [__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
    While ($Record) {
				$TableProperties | Add-Member -MemberType NoteProperty -Name (&$GetProperty -Object $Record -PropertyName 'StringData' -ArgumentList @(1)) -Value (&$GetProperty -Object $Record -PropertyName 'StringData' -ArgumentList @(2))
				#  Retrieve the next row in the table
				[__comobject]$Record = & $InvokeMethod -Object $View -MethodName 'Fetch'
	}
    & $InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @() | Out-Null
    Write-Output($TableProperties | Select-object Manufacturer,ProductName,ProductVersion,ProductLanguage | ConvertTo-Json -Compress)
