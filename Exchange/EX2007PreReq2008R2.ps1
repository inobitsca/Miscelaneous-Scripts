if (-not((Get-WMIObject win32_OperatingSystem).OSArchitecture -eq '64-bit') -and (Get-WMIObject win32_OperatingSystem).Version -eq '6.1.7600'){
       Write-Host "This script requires a 64bit version of Windows Server 2008 R2, which this is not." -ForegroundColor Red -BackgroundColor Black
       Exit
}
Import-Module ServerManager
$opt = "None"
Do { 
       clear
       if ($opt -ne "None") {write-host "Last command: "$opt -foregroundcolor Yellow}
       write-host
       write-host Exchange Server 2007 Sp3 on Windows Server 2008 R2- Prerequisites script
       write-host Please, select which role you are going to install..
       write-host
       write-host '1) Hub Transport'
       write-host '2) Client Access Server'
       write-host '3) Mailbox'
       write-host '4) Unified Messaging'
       write-host '5) Edge Transport'
       write-host '6) Typical (CAS/HUB/Mailbox)'
       write-host '7) Client Access and Hub Transport'
       write-host
       write-host '8) Restart the Server'
       write-host '10) Quit'
       write-host
       $opt = Read-Host "Select an option.. [1-10]? "
       switch ($opt)    {
              1 { Add-WindowsFeature RSAT-ADDS,Web-Metabase,Web-Lgcy-Mgmt-Console; $opt=10}
              2 { Add-WindowsFeature RSAT-ADDS,Web-Server,Web-Metabase,Web-Lgcy-Mgmt-Console,Web-Dyn-Compression,Web-Windows-Auth,Web-Basic-Auth,Web-Digest-Auth,RPC-Over-HTTP-Proxy; $opt=10}
              3 { Add-WindowsFeature RSAT-ADDS,Web-Server,Web-ISAPI-Ext,Web-Metabase,Web-Lgcy-Mgmt-Console,Web-Basic-Auth,Web-Windows-Auth; $opt=10 }
              4 { Add-WindowsFeature RSAT-ADDS,Web-Metabase,Web-Lgcy-Mgmt-Console,Desktop-Experience; $opt=10 }
              5 { Add-WindowsFeature RSAT-ADDS,ADLDS; $opt=10 }
              6 { Add-WindowsFeature RSAT-ADDS,Web-Server,Web-Metabase,Web-Lgcy-Mgmt-Console,Web-Dyn-Compression,Web-Windows-Auth,Web-Basic-Auth,Web-Digest-Auth,RPC-Over-HTTP-Proxy; $opt=10}
              7 { Add-WindowsFeature RSAT-ADDS,Web-Server,Web-Metabase,Web-Lgcy-Mgmt-Console,Web-Dyn-Compression,Web-Windows-Auth,Web-Basic-Auth,Web-Digest-Auth,RPC-Over-HTTP-Proxy; $opt=10 }
              8 { Restart-Computer }
              10 {break}
              default {write-host "You haven't selected any of the available options. "}
       }
 }
while ($opt -ne 10)
