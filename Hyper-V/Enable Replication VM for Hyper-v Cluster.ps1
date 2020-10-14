# Create Replication VM
# Author Robert Smit
# Company @ClusterMVP
# Date April 10, 2015
# Version 1.0


# Variable
$SourceHV= "MVPTENANT001"
$ReplHV= "MVPTENANT011"
$DRVM= "MVPLOADTEST01"


# Replica info
Get-Command –Module Hyper-V *repl*

# get current status
Get-VMReplication

#get repl server status settings
Get-VMReplication –ReplicaServerName $ReplHV

#get ReplicationHealth status 
Get-VMReplication –ReplicationHealth Normal
Get-VMReplication –ReplicationHealth Warning

#get repl server
Get-VMReplicationServer $ReplHV
Get-VMReplication -ComputerName $SourceHV | Format-List *


(1..2) | % {get-VMReplicationServer –ComputerName MVPTENANT00$_} | Format-Table repenabled, authtype, intauth, certauth, anyserver, moninterval, monstarttime, computername

#Set-VMReplicationServer 
enable-VMReplication –VMname $DRVM –ReplicaServerName $ReplHV –ReplicaServerPort 80 -AuthenticationType Kerberos

#start init Replication
Start-VMInitialReplication –VMName $DRVM

#show status
Measure-VMReplication 
Get-VMReplication | Format-List *