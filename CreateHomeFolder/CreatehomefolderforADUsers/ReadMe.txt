Open the script CreatehomefolderforADUsers.ps1 in your favourate scripting editor, preferably PowerShell ISE. Amend the following lines to customize for your environment:

1. Line 33: Change your AD Server name

4. Line 49: Change location to search (OU, top of domain, etc)

5. Line 64: If you want user folders to be created as their longon names, uncomment (remove #) line 64 and comment out (add #)line 65

6. Line 107: If you amended lined 64 and 65, you MUST also amend lines 107 (uncomment) and line 108 (comment)

7. Line 118: If you completed numbers 5 and 6 above, you MUST also unacoment line 118 and comment line 119

8. Line 123: If you want to change the drive letter user folder is mapped, amend line 123 as required

9. If you wish to create users home folders in a different base folder, amend lines 64 or 65, 106 or 107, and 117 and 119 accordingly
 

If you need further support, please fill the contact me form in this URL: 

http://www.itechguides.com/contact-me


Rate script and/or ask questions here:http://gallery.technet.microsoft.com/PowerShell-script-to-832e08ed