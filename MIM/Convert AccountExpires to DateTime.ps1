$EXPS = import-csv c:\temp\exp.csv
Foreach ($Exp in $EXPS) {
$EXDT = $EXP.Exp
$DN = $EXP.DN
$DEC=[convert]::toint64($EXDT,16)
$dt = [datetime]"1601-01-01 00:00:00"
$EXPDate =   $DT.addticks($DEC) 
$out = get-date $EXPDate -format yyyy-MM-dd
$outdate = $DN +";" +$Out 
$outdate >> c:\temp\outdate1.csv}



#DateTime dt = new DateTime(1601, 01, 02).AddTicks($DEC);


modify,accountExpires,number,9223372036854775807,131354712000000000
modify,accountExpires,number,9223372036854775807,131354712000000000
modify,accountExpires,number,0,9223372036854775807

$dec = "9223372036854775807"