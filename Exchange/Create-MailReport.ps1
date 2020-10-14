#
# Create-MailReport.ps1
#
# By David Barrett, Microsoft Ltd. 2016. Use at your own risk.  No warranties are given.
#
#  DISCLAIMER:
# THIS CODE IS SAMPLE CODE. THESE SAMPLES ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
# MICROSOFT FURTHER DISCLAIMS ALL IMPLIED WARRANTIES INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR OF FITNESS FOR
# A PARTICULAR PURPOSE. THE ENTIRE RISK ARISING OUT OF THE USE OR PERFORMANCE OF THE SAMPLES REMAINS WITH YOU. IN NO EVENT SHALL
# MICROSOFT OR ITS SUPPLIERS BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS,
# BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR INABILITY TO USE THE
# SAMPLES, EVEN IF MICROSOFT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. BECAUSE SOME STATES DO NOT ALLOW THE EXCLUSION OR LIMITATION
# OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, THE ABOVE LIMITATION MAY NOT APPLY TO YOU.


param (
	[Parameter(Mandatory=$False,HelpMessage="Specifies the month for which the report will be run (1-12 for Jan-Dec)")]
	[ValidateNotNullOrEmpty()]
	[int]$ReportMonth = 0,

	[Parameter(Mandatory=$False,HelpMessage="Specifies the start date for the generated report")]
	[ValidateNotNullOrEmpty()]
	[string]$StartDate,

	[Parameter(Mandatory=$False,HelpMessage="Specifies the end date for the generated report")]
	[ValidateNotNullOrEmpty()]
	[string]$EndDate,

	[Parameter(Mandatory=$False,HelpMessage="The file to which the user stats will be exported.  {D} is replaced by report date")]
	[string]$UserStatsExport = "user_stats_{D}.csv",

	[Parameter(Mandatory=$False,HelpMessage="The file to which the user stats will be exported.  {D} is replaced by report date")]
	[string]$OrgStatsExport = "org_stats_{D}.csv"
)


# Set date/time variables for report run. If month not specified, we assume last month
$today = get-date
if (![String]::IsNullOrEmpty($StartDate))
{
    # We have a date specified - if no end date, we use yesterday
    $ReportStartDate = [DateTime]::Parse($StartDate)
    if ($EndDate -eq $Null)
    {
        $ReportEndDate = $today.AddDays(-1)
    }
    else
    {
        $ReportEndDate = [DateTime]::Parse($EndDate)
    }
    $reportDate = "$($ReportStartDate.ToShortDateString()) to $($ReportEndDate.ToShortDateString())"
    $reportDate = $reportDate -replace "/","-"
}
else
{
    # No specific date specified, so we'll create a monthly report
    $ReportYear = $today.Year
    if ( $ReportMonth -lt 1 )
    {
        $ReportMonth = $today.AddMonths(-1).Month
    }
    if ($ReportMonth -gt $today.Month) { $ReportYear-- }

    $ReportStartDate = New-Object System.DateTime($ReportYear, $ReportMonth, 1, 0,0,0) # First day of report month
    $ReportEndDate = $ReportStartDate.AddMonths(1) # We stop on the first day of the next month (i.e. at 00:00:00)
    $reportDate ="$($ReportStartDate.ToString("MMMM")),$ReportYear"
}

$rundate = $($today.AddDays(-1)).tolongdatestring()
Write-Host "Creating report: $reportDate" -ForegroundColor Green

# Work out the output filename (based on report start date)
if ($ReportMonth -gt 0)
{
    $outfile_date = $ReportStartDate.tostring("yyyy_MM") 
}
else
{
    $outfile_date = $ReportStartDate.tostring("yyyy_MM_dd")
}
$outfile = "$outfile_date.email_stats.csv"

# Retrieve our local domains 
$accepted_domains = Get-AcceptedDomain |% {$_.domainname.domain} 
[regex]$dom_rgx = "`(?i)(?:" + (($accepted_domains |% {"@" + [regex]::escape($_)}) -join "|") + ")$" 

# Get a list of hub transport and mailbox servers (we query all these for tracking logs)
$hts = get-exchangeserver |? {($_.serverrole -match "hubtransport") -or ($_.serverrole -match "mailbox")} |% {$_.name} 

# Now initialise our variables (hash tables) to collect the stats
$all_user_stats = @{}
$org_stats = @{}

# This function gives some user feedback while processing
function time_pipeline { 
param ($increment  = 1000) 
begin{$i=0;$timer = [diagnostics.stopwatch]::startnew()} 
process { 
    $i++ 
    if (!($i % $increment)){Write-host “`rProcessed $i in $([int]$timer.elapsed.totalseconds) seconds...” -nonewline} 
    $_ 
    } 
end { 
    write-Host “`rProcessed $i log records in $([int]$timer.elapsed.totalseconds) seconds.   ” 
    Write-Host "   Average rate: $([int]($i/$timer.elapsed.totalseconds)) log recs/sec." 
    } 
} 


$internal_msgids = @()

foreach ($ht in $hts)
{
    Write-Verbose "Executing get-messagetrackinglog -Server $ht -Start ""$reportStartDate"" -End ""$reportEndDate"" -resultsize unlimited"
    $trackingdata = get-messagetrackinglog -Server $ht -Start "$reportStartDate" -End "$reportEndDate" -resultsize unlimited
    $trackingdata | time_pipeline |% {

        if ($_.source -eq "STOREDRIVER")
        {
            # Directionality is only logged in Exchange 2013.  For 2010, we need to work it out
            $directionality = $_.Directionality
            if ($directionality -eq $Null)
            {
                $directionality = "Incoming"
                if ($_.Sender -match $dom_rgx)
                {
                    $directionality = "Originating"
                }
            }

            if ($directionality.Equals("Incoming") -and $_.eventid.Equals("DELIVER"))
            {
                # This is an external message being delivered internally

                # Update the user stats
                ForEach ($rcpt in $_.Recipients)
                {
                    $userstats = $all_user_stats[$rcpt]
                    if ($userstats -eq $Null)
                    {
                        $userstats = @{}
                    }
                    $userstats["Messages received (total)"] += 1
                    $userstats["Messages received (external)"] += 1
                    $userstats["Bytes received (total)"] += $_.TotalBytes
                    $userstats["Bytes received (external)"] += $_.TotalBytes
                    $all_user_stats[$rcpt] = $userstats
                }

                # Update the org stats
                $org_stats["Messages received (total)"] += 1
                $org_stats["Messages received (external)"] += 1
                $org_stats["Bytes received (total)"] += $_.TotalBytes
                $org_stats["Bytes received (external)"] += $_.TotalBytes
            }
            elseif ($directionality.Equals("Originating"))
            {
                # This message originated internally - it's either an internal message, or an outgoing one
                if ($_.Sender.Equals("maildeliveryprobe@maildeliveryprobe.com"))
                {
                    # Ignore these messages
                }
                else
                {
                    if ($_.EventId.Equals("DELIVER"))
                    {
                        # This is an internal message being delivered internally

                        ForEach ($rcpt in $_.Recipients)
                        {
                            # Update received stats
                            $userstats = $all_user_stats[$rcpt]
                            if ($userstats -eq $Null)
                            {
                                $userstats = @{}
                            }
                            $userstats["Messages received (total)"] += 1
                            $userstats["Messages received (internal)"] += 1
                            $userstats["Bytes received (total)"] += $_.TotalBytes
                            $userstats["Bytes received (internal)"] += $_.TotalBytes
                            $all_user_stats[$rcpt] = $userstats
                        }
                        # Update the org stats
                        $org_stats["Messages received (total)"] += 1
                        $org_stats["Messages received (internal)"] += 1
                        $org_stats["Bytes received (total)"] += $_.TotalBytes
                        $org_stats["Bytes received (internal)"] += $_.TotalBytes

                        # Update sent stats (i.e. here we retrieve the sender and update accordingly)
                        $userstats = $all_user_stats[$_.Sender]
                        if ($userstats -eq $Null)
                        {
                            $userstats = @{}
                        }
                        $userstats["Messages sent (total)"] += 1
                        $userstats["Messages sent (internal)"] += 1
                        $userstats["Bytes sent (total)"] += $_.TotalBytes
                        $userstats["Bytes sent (internal)"] += $_.TotalBytes
                        $all_user_stats[$_.Sender] = $userstats

                        # Update the org stats
                        $org_stats["Messages sent (total)"] += 1
                        $org_stats["Messages sent (internal)"] += 1
                        $org_stats["Bytes sent (total)"] += $_.TotalBytes
                        $org_stats["Bytes sent (internal)"] += $_.TotalBytes
                    }
                    elseif ($_.EventId.Equals("RECEIVE"))
                    {
                        # This is an internal message that has been submitted to transport
                        # If the recipients are not internal, then we track this as internal message being sent externally

                        $userstats = $all_user_stats[$_.Sender]
                        if ($userstats -eq $Null)
                        {
                            $userstats = @{}
                        }
                        ForEach ($rcpt in $_.Recipients)
                        {
                            if (!($rcpt -match $dom_rgx))
                            {
                                $userstats["Messages sent (total)"] += 1
                                $userstats["Messages sent (external)"] += 1
                                $userstats["Bytes sent (total)"] += $_.TotalBytes
                                $userstats["Bytes sent (external)"] += $_.TotalBytes
                                $all_user_stats[$_.Sender] = $userstats

                                # Update the org stats
                                $org_stats["Messages sent (total)"] += 1
                                $org_stats["Messages sent (external)"] += 1
                                $org_stats["Bytes sent (total)"] += $_.TotalBytes
                                $org_stats["Bytes sent (external)"] += $_.TotalBytes
                            }
                        }
                    }
                }
            }
        }    
    } 
}

# Now we have all the data, we export to file

$OrgStatsExport = $OrgStatsExport -replace "{D}", $reportDate
$UserStatsExport = $UserStatsExport -replace "{D}", $reportDate

# Export organisation data
Write-Host "Exporting organisation stats to: $OrgStatsExport" -ForegroundColor Green
$headers = ""
$stats = ""
ForEach ($field in $org_stats.Keys)
{
    $headers += ",""$field"""
    $stats += ",$($org_stats[$field])"
}

if ($headers.Length -gt 0)
{
    $headers.SubString(1) | Out-File $OrgStatsExport
    $stats.SubString(1) | Out-File $OrgStatsExport -Append
}

# Export user data
$user_stats_fields = @("Messages received (total)","Messages sent (total)","Bytes received (total)","Bytes sent (total)","Messages received (external)",
    "Messages sent (external)","Bytes received (external)","Bytes Sent (external)","Messages received (internal)","Messages sent (internal)",
    "Bytes received (internal)","Bytes Sent (internal)")

Write-Host "Exporting user stats to: $UserStatsExport" -ForegroundColor Green
$headers = """User"","""
$headers += $user_stats_fields -join ""","""
$headers += """"
$headers | Out-File $UserStatsExport
ForEach ($user in $all_user_stats.Keys)
{
    $stats = """$user"""
    ForEach ($field in $user_stats_fields)
    {
        if ($all_user_stats[$user].ContainsKey($field))
        {
            $stats += ",""$($all_user_stats[$user][$field])"""
        }
        else
        {
            $stats += ",""0"""
        }
    }
    $stats | Out-File $UserStatsExport -Append
}
 
 
Write-Host "Run time was $(((get-date) - $today).totalseconds) seconds." 
