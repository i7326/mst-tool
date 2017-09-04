﻿[CmdletBinding()]	
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
Function Exit-script {
    param(
	    [string]$ErrorOutput
    )
    Try{
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Database)
	    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Installer)
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Record)
    } Catch { }
    Throw $ErrorOutput
    Exit 0
}
    [psobject]$TableProperties = New-Object -TypeName PSObject
    [psobject]$ErrorObject = New-Object -TypeName PSObject
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
    [scriptblock]$GetProperty = {
			Param (
				[__comobject]$Object,
				[string]$PropertyName,
				[object[]]$ArgumentList
			)
			$Object.GetType().InvokeMember($PropertyName, [System.Reflection.BindingFlags]::GetProperty, $null, $Object, $ArgumentList, $null, $null, $null)
	}
Try{
    [__comobject]$Database = &$InvokeMethod -Object $Installer -MethodName 'OpenDatabase' -ArgumentList @($Path, $OpenMode)
    }
catch{
	$ScriptError = "Access denied : $Path"
    Exit-script -ErrorOutput $ScriptError
}
Try{
    [__comobject]$View = &$InvokeMethod -Object $Database -MethodName 'OpenView' -ArgumentList @("SELECT * FROM $Table")
	$null = &$InvokeMethod -Object $View -MethodName 'Execute'
    [__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
    While ($Record) {
				$TableProperties | Add-Member -MemberType NoteProperty -Name (&$GetProperty -Object $Record -PropertyName 'StringData' -ArgumentList @(1)) -Value (&$GetProperty -Object $Record -PropertyName 'StringData' -ArgumentList @(2))
				[__comobject]$Record = &$InvokeMethod -Object $View -MethodName 'Fetch'
	}
    $null = &$InvokeMethod -Object $View -MethodName 'Close' -ArgumentList @()
    if([bool]($TableProperties.psobject.Properties | Where-Object { @("pwcpackageName","pwclang","pwcrelease") -ccontains $_.Name.ToLower() })) {
        $TableProperties | Add-Member -MemberType NoteProperty -Name "Exclude" -Value $true
    }
    [__comobject]$SummaryInfo = &$GetProperty -Object $Database -PropertyName 'SummaryInformation'
    [string]$Template = &$GetProperty -Object $SummaryInfo -PropertyName 'Property' -ArgumentList @(7)
    Try { $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($SummaryInfo) } Catch { }
    if ($Template -match "64") {
       $TableProperties | Add-Member -MemberType NoteProperty -Name "Arch" -Value "x64"
    }
} Catch { 
    $ScriptError = "Error Fetching Properties"
    Exit-script -ErrorOutput $ScriptError
}
Try {
	 $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Database)
	 $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Installer)
     $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
     $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Record)
} Catch { }

    Write-Output($TableProperties | Select-object Manufacturer,ProductName,Arch,ProductVersion,ProductLanguage,Exclude | ConvertTo-Json -Compress)