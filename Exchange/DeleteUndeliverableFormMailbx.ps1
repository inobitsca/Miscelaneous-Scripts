#Mailbox to search
$SM = read-host "Enter the alias of the maibox to clear"
$TM = Read-host "Enter the alias of the admin mailbox"

$mess ="Your message couldn't be delivered"
$I = """"
$F = "subject:" + $I+ $mess + $I

get-mailbox $SM | Search-Mailbox -SearchQuery $F -TargetMailbox $TM -TargetFolder "Inbox" -LogLevel Full -DeleteContent