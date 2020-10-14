use pulseii 
go

--select top 10000 * from dbo.datTrxs where (select left(basketcreatedate,11)as shortdate) > 2006-04-20

-- select top 10000 * from dbo.datTrxs where (Convert(int,basketcreatedate)) > 2006-04-20

-- select top 1000(CAST(basketcreatedate AS DECIMAL(12, 5))) from dbo.datTrxs

-- select top 10000 basketcreatedate, CAST(basketcreatedate AS DECIMAL(12, 5))as decimaldate from dbo.datTrxs

select * from dbo.datTrxs where basketcreatedate < '2007-01-01 00:00:00.000'
