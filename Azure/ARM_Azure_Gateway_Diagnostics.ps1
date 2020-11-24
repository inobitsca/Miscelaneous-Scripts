#------------------------------------------------------------------------------  
#  
# Copyright © 2016 Microsoft Corporation.  All rights reserved.  
#  
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT  
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT  
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS  
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR   
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.  
#  
#------------------------------------------------------------------------------  
#  
# PowerShell Source Code  
#  
# NAME:  
#    Azure_Gateway_Diagnostics.ps1  
#  
# VERSION:  
#    3.1 
#  
#------------------------------------------------------------------------------ 
 
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
" Copyright © 2016 Microsoft Corporation.  All rights reserved. " | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
" THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED `“AS IS`” WITHOUT " | Write-Host -ForegroundColor Yellow 
" WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT " | Write-Host -ForegroundColor Yellow 
" LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS " | Write-Host -ForegroundColor Yellow 
" FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR  " | Write-Host -ForegroundColor Yellow 
" RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER. " | Write-Host -ForegroundColor Yellow 
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
" PowerShell Source Code " | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
" NAME: " | Write-Host -ForegroundColor Yellow 
"    Azure_Gateway_Diagnostics.ps1 " | Write-Host -ForegroundColor Yellow 
"" | Write-Host -ForegroundColor Yellow 
" VERSION: " | Write-Host -ForegroundColor Yellow 
"    3.1" | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow 
"" | Write-Host -ForegroundColor Yellow 
"`n This script SAMPLE is provided and intended only to act as a SAMPLE ONLY," | Write-Host -ForegroundColor Yellow 
" and is NOT intended to serve as a solution to any known technical issue."  | Write-Host -ForegroundColor Yellow 
"`n By executing this SAMPLE AS-IS, you agree to assume all risks and responsibility associated."  | Write-Host -ForegroundColor Yellow 
 
$ErrorActionPreference = "SilentlyContinue" 
$ContinueAnswer = Read-Host "`n Do you wish to proceed at your own risk? (Y/N)" 
If ($ContinueAnswer -ne "Y") { Write-Host "`n Exiting." -ForegroundColor Red;Exit } 

#import module
Import-Module Azure

#Check the Azure PowerShell module version
Write-Host "`n[WORKITEM] - Checking Azure PowerShell module verion" -ForegroundColor Yellow
$APSMajor =(Get-Module azure).version.Major
$APSMinor =(Get-Module azure).version.Minor
$APSBuild =(Get-Module azure).version.Build
$APSVersion =("$PSMajor.$PSMinor.$PSBuild")

If ($APSVersion -ge 1.5.0)
{
    Write-Host "`tSuccess"
}
Else
{
   Write-Host "[ERROR] - Azure PowerShell module must be version 1.5.0 or higher. Exiting." -ForegroundColor Red
   Exit
}

Write-Host "`n[INFO] - Login to Azure RM" -ForegroundColor Yellow
Login-AzureRmAccount

Write-Host "`n[INFO] - Login to Azure ASM" -ForegroundColor Yellow
Add-AzureAccount

Write-Host "`n[INFO] - Obtaining subscriptions" -ForegroundColor Yellow
[array] $AllSubs = get-AzureRmSubscription

If ($AllSubs)
{
        Write-Host "`tSuccess"

        }
Else
{
        Write-Host "`tNo subscriptions found. Exiting." -ForegroundColor Red
        Exit
}

Write-Host "`n[SELECTION] - Select the Azure subscription." -ForegroundColor Yellow

$SelSubName = $AllSubs | Out-GridView -PassThru -Title "Select the Azure subscription"

If ($SelSubName)
{
	#Write sub
	Write-Host "`tSelection: $($SelSubName.SubscriptionName)"
		
        $SelSub = $SelSubName.SubscriptionId
        Select-AzureRmSubscription -Subscriptionid $SelSub | Out-Null
		Write-Host "`tSuccess"
}
Else
{
        Write-Host "`n[ERROR] - No Azure subscription was selected. Exiting." -ForegroundColor Red
        Exit
}

[array] $AllRGs = Get-AzureRmResourceGroup -WarningAction Ignore

Write-Host "`n[SELECTION] - Select the Azure resource group that contains the gateway to trace." -ForegroundColor Yellow

if ($AllRGs)
{
        Write-Host "`tSuccess"

        }
Else
{
        Write-Host "`tNo subscriptions found. Exiting." -ForegroundColor Red
        Exit
}

$SelRGName = $AllRGs | Out-GridView -PassThru -Title "Select the Resource Group"

$AllGW = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $SelRGName.ResourceGroupName 

if ($AllGW)
{
        Write-Host "`tSuccess"

        }
Else
{
        Write-Host "`tNo Azure gateways found found. Exiting." -ForegroundColor Red
        Exit
}

$SelGW = $AllGW | Select-Object Name,GatewayType,VpnType,Location | Sort-Object -Property Name -descending |Out-GridView -PassThru -Title "Select the Azure Gatway to trace."

$AsmGW = Get-AzureVirtualNetworkGateway
$SelAsmGW = $AsmGW | where {($_.GatewayName -ceq $SelGW.Name)}

$SelGWName = $SelGW.Name
$SelGWName = $SelGWName.tolower()
$StorAccName = $SelGWName

# create a Storage account
New-AzureRmStorageAccount -ResourceGroupName $SelRGName.ResourceGroupName -Name $StorAccName -Type Standard_LRS -Location $SelGW.Location |Out-Null
Write-Host "`n[INFO] - Creating storage account named $($StorAccName), Please wait." -ForegroundColor Yellow

#get key for stoage account we created
$Storagekey = Get-AzureRmStorageAccountKey -ResourceGroupName $SelRGName.ResourceGroupName -Name $StorAccName
$key1 = $Storagekey.value[0]

$storageContext = New-AzureStorageContext -StorageAccountName $StorAccName -StorageAccountKey $key1
$storageContainer = "vpnlogs"

#select duration
[int]$duration=Read-Host "`n Select Duration (seconds with 300 max)"
If (!($duration -gt 0 -and $duration -le 300)){ Write-Host "`n FAILED: Invalid Duration`n" -fore red;Exit }

#start vpn diag
Write-Host "`n[INFO] - Starting Azure Gateway tracing for $duration seconds." -ForegroundColor Yellow
Start-AzureVirtualNetworkGatewayDiagnostics -GatewayId $SelAsmGW.GatewayId -CaptureDurationInSeconds $duration -ContainerName $storageContainer -StorageContext $storageContext

#wait
Write-Host "`n Waiting $duration seconds" -ForegroundColor Yellow
Start-Sleep -Seconds $duration

#check status for up to 6 minutes
$State = "NotReady"
$Iterations = 0
While ($State -ne "Ready" -and $Iterations -lt 6)
{
     Write-Host "`n Checking status" -ForegroundColor Yellow
     $State = (Get-AzureVNetGatewayDiagnostics -GatewayId $SelAsmGW.GatewayId).State
     Write-Host "`t$State"
     Start-Sleep -Seconds 60
	 $Iterations++
}

#set output file
$outputfile="$Env:TEMP\AzureGatewayDiag.txt"

#get diags URL
$logUrl = ( Get-AzureVirtualNetworkGatewayDiagnostics -GatewayId $SelAsmGW.GatewayId).DiagnosticsUrl

#download output
Write-Host "`n[INFO] Downloading data" -ForegroundColor Yellow
$wc = New-Object System.Net.WebClient
Try
{ $wc.DownloadFile($logUrl, $outputFile) }
Catch [Exception]
{ Write-Host "`tFAILED: $_`n`n`tTry manually browsing the portal" -fore red 

Write-Host "`n Press any key to continue ...`n"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Exit
}

#open output file
If (Test-Path $outputFile) { Invoke-Item $outputFile } Else { Write-Host "`tFAILED: Output file not found`n`n`tTry manually browsing the portal" -fore red }
Write-Host "`n Done`n`n" -ForegroundColor Cyan

Write-Host "`n Press any key to continue ...`n"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Exit