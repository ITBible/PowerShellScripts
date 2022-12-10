<#	
	.NOTES
	===========================================================================
	 Created on:   	12/9/2022 11:38 PM
	 Created by:   	WizardTux
	 Organization: 	IT Bible (itbible.org)
	 Filename: ClearStuckPrintJobs.ps1     	
	===========================================================================
	.DESCRIPTION
		Clears print jobs on an array of computers
#>

$Computers = @(
	"."	
)

foreach ($Computer in $Computers)
{
	$name = $Computer
	if ($Computer -eq ".") { $name = "Local Machine" }
	Write-Host "Checking Print Jobs on: $($name)"
	$PrintJobs = Get-WmiObject -Class "Win32_PrintJob" -Namespace "root\CIMV2" -ComputerName $Computer
	foreach ($job in $PrintJobs)
	{
		$pos = ($job.Name).IndexOf(",")
		$printerName = ($job.Name).Substring(0, $pos)
		if ($job.JobStatus -like "Error | Printing")
		{
			Remove-PrintJob -ComputerName $env:COMPUTERNAME -ID $job.JobId -PrinterName $printerName
		}
	}
}