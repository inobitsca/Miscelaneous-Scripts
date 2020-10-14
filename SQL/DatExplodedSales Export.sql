Insert into  PulseTemp.dbo.DatExplodedSales  (SiteID, PriceElementID,SKUID, Quantity, AmountIncldVAT )
Select e.SiteID, e.PriceElementID,e.SKUID, e.Quantity, e.AmountIncldVAT  from PulseII.dbo.DatExplodedSales e 
inner Join PulseII.dbo.datTrxs d 
on
 d.priceElementID  = e.priceElementID  where d.BasketCreateDate < '2011-08-01 07:30:47.000'


--Select top 0 * from PulseII.dbo.DatExplodedSales e 