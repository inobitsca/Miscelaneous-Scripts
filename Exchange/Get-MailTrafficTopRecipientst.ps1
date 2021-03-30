function Get-MailTrafficTopRecipients
{
    param
    (
    [Parameter(Mandatory=$true)]
    [DateTime]$StartDate,
    [Parameter(Mandatory=$true)]
    [DateTime]$EndDate
    )
    
    [int]$threshold = 3600
    [int]$page=1
    Do
    {
        Write-Host "Getting mail traffic data from page: $($page)"
        $mailTrafficData=Get-MailTrafficTopReport -StartDate $StartDate -EndDate $EndDate -Direction Inbound -EventType TopMailUser -Page $page -PageSize 5000 -AggregateBy Hour
        $aggregatedMailTrafficData+=$MailTrafficData | Where-Object{$_.MessageCount -gt $threshold}
        $Page++
    }While($mailTrafficData.count -eq 5000)
    return $aggregatedMailTrafficData | Sort Hour,MessageCount -Descending
}

