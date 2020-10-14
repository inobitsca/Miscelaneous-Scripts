Select count(1) from PulseII.dbo.DatExplodedSales e 
inner Join PulseII.dbo.datTrxs d 
on
 d.priceElementID  = e.priceElementID  where d.BasketCreateDate >= '2012-01-01 07:30:47.000'