<#	
	.NOTES
	===========================================================================
	 Created on:   	12/10/2022 12:45 AM
	 Created by:   	WizardTux
	 Organization: 	IT Bible (itbible.org)
	 Filename: GetProcessByPort.ps1     	
	===========================================================================
	.DESCRIPTION
		Gets a list of processes using a specific port and outputs the list.
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$Port # e.g. 443
)

$pids = (Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $Port }) | Select-Object -Property OwningProcess

$lastName=""
foreach ($localpid in $pids)
{
	$current = Get-Process -PID $localpid.OwningProcess | Select-Object -Property ProcessName, Id
	if ($current.ProcessName -ne $lastName)
	{
		$current
		$lastName = $current.ProcessName
	}
}