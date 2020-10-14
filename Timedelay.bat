set h=%TIME:~0,2%
set m=%TIME:~3,2%
set s=%TIME:~6,2%
set/a m2="m+1"
set t2=%h%:%m2%:%s%
set t2
at %t2% cmd.exe