Do { 
while ($choice1 -le "0" -or $choice1 -gt "99" )
{
$Choice1 = 0


Write-Host "
---------- MENU ----------
1 = Section 1
2 = Section 2
3 = Section 3
4 = Section 4
5 = Section 5
6 = Section 6
99 = Quit
--------------------------"  -Fore Green

$choice1 = read-host -prompt "Select number & press enter"
 } 

Switch ($choice1) {

#SECTION 1
#

"1" {
#
Write-host "test section 1"

$Choice1 = 0
}

#SECTION 2
#

"2" {
#
Write-host "test section 2"

$Choice1 = 0
}


#SECTION 3
#

"3" {
#
Write-host "test section 3"

$Choice1 = 0
}


#SECTION 4
#

"4" {
#
Write-host "test section 4"

$Choice1 = 0
}

#SECTION 5
#

"5" {
#
Write-host "test section 5"

$Choice1 = 0
}

#SECTION 6
#

"6" {
#
Write-host "test section 6"

$Choice1 = 0
}

}}while ( $choice1 -ne "99" )