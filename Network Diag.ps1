<#	
	.NOTES
	===========================================================================
	 Created on:   	12/10/2022 10:37 PM
	 Created by:   	WizardTux
	 Organization: 	IT Bible (itbible.org)
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
$Domains = @(
	"google.com",
	"itbible.org"
)

$Resolvers = @(
	"208.67.222.222",
	"8.8.8.8"
)

$Gateway = Get-NetRoute | where { $_.DestinationPrefix -eq '0.0.0.0/0' } | Select -index 0 | select -ExpandProperty NextHop

$Externals = @(
	"8.8.8.8"
	"208.67.222.222"
)

function Run-DnsCustom
{
	param (
		[bool]$clear = $true
	)
	if ($clear) { [System.Console]::Clear() }
	$DnsInput = Read-Host "Custom DNS lookup"
	
	if ($DnsInput)
	{
		$ResolverInput = Read-Host "Custom Resolver [Local]"
		[System.Console]::Clear()
		Write-Host "Testing DNS... Please wait..."
		if ($ResolverInput)
		{
			Write-Host "Testing Custom DNS using $ResolverInput : $DnsInput" -ForegroundColor Yellow -BackgroundColor Black
			Resolve-DnsName -Name $DnsInput -Server $ResolverInput
		}
		else
		{
			Write-Host "Testing Custom DNS using Local Resolver: $DnsInput" -ForegroundColor Yellow -BackgroundColor Black
			Resolve-DnsName -Name $DnsInput
		}
		if ($clear) { Pause }
		Exit
	}
	Exit
}

function Run-Dns
{
	param (
		[bool]$clear = $true
	)
	if ($clear) { [System.Console]::Clear() }
	Write-Host "Testing DNS... Please wait..."
	Write-Host "Testing Local DNS" -ForegroundColor Yellow -BackgroundColor Black
	foreach ($domain in $Domains)
	{
		Resolve-DnsName -Name $domain -DnsOnly
	}
	Write-Host ""
	Write-Host "Testing Remote DNS" -ForegroundColor Yellow -BackgroundColor Black
	$rCount = 0
	foreach ($resolver in $Resolvers)
	{
		if ($rCount -gt 0) { Write-Host "" }
		Write-Host "Resolver: $resolver" -ForegroundColor DarkRed
		foreach ($domain in $Domains)
		{
			Resolve-DnsName -Name $domain -Server $resolver
		}
		$rCount++
	}
	
	if ($clear) { Pause }
}

function Run-Trace
{
	param (
		[bool]$clear = $true
	)
	if ($clear) { [System.Console]::Clear() }
	Write-Host "Testing Traceroute... Please wait..."
	Write-Host "Tracing Gateway (should return 1 hop)" -ForegroundColor Yellow -BackgroundColor Black
	Test-NetConnection -TraceRoute -ComputerName $Gateway
	Write-Host ""
	Write-Host "Tracing Remote Addresses" -ForegroundColor Yellow -BackgroundColor Black
	$tCount = 0
	foreach ($external in $Externals)
	{
		if ($tCount -gt 0) { Write-Host "" }
		Write-Host "Tracing: $external"
		Test-NetConnection -TraceRoute -ComputerName $external
	}
	if ($clear) { Pause }
}

function Run-PingCustom
{
	param (
		[bool]$clear = $true
	)
	if ($clear) { [System.Console]::Clear() }
	$PingInput = Read-Host "Custom Address"
	
	if ($PingInput)
	{
		[System.Console]::Clear()
		Write-Host "Testing PING... Please wait..."
		Test-Connection -ComputerName $PingInput -Count 4
		if ($clear) { Pause }
		Exit
	}
	#start powershell { dns.ps1 }
	Exit
}

function Run-Ping
{
	param (
		[bool]$clear=$true
	)
	if($clear) { [System.Console]::Clear() }
	Write-Host "Testing Ping... Please wait..."
	Write-Host "Pinging Gateway: $Gateway" -ForegroundColor Yellow -BackgroundColor Black
	Test-Connection -ComputerName $Gateway -Count 4
	Write-Host ""
	Write-Host "Pinging External: $($Externals[0])" -ForegroundColor Yellow -BackgroundColor Black
	Test-Connection -ComputerName $Externals[0] -Count 4
	
	if ($clear) { Pause }
}

function Run-All
{
	[System.Console]::Clear()
	Write-Host "Testing All... Please wait..."
	Run-Ping -clear $false
	Run-Trace -clear $false
	Run-Dns -clear $false
	Pause
}

function Show-Menu
{
	param (
		[string]$Title = "ITBible Menu"
	)
	[System.Console]::Clear()
	Write-Host "================ $Title ================"
	Write-Host "Enter a number for diagnostic selection."
	Write-Host "1: Run all network Scripts" -ForegroundColor DarkGray
	Write-Host "2: Ping Test"
	Write-Host "2a: Custom Ping Test"
	Write-Host "3: Trace Test"
	Write-Host "4: DNS Test"
	Write-Host "4a: Custom DNS Test"
	Write-Host ""
	Write-Host "Q: Quit"
}

do
{
	Show-Menu -Title "ITBible Network Diag"
	$UserInput = Read-Host "Please make a selection"
	switch ($UserInput)
	{
		'1' { Run-All }
		'2' { Run-Ping }
		'2a' { Run-PingCustom }
		'3' { Run-Trace }
		'4' { Run-Dns }
		'4a' { Run-DnsCustom }
	}
}
until ($UserInput -eq 'q')