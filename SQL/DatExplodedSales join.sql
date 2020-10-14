select count(1) from dbo.DatExplodedSales e 
inner Join datTrxs d 
on
 d.priceElementID  = e.priceElementID 
/* inner Join  datSKUCostPrices s
on
  s.SiteID=e.siteid and e.SKUID = s.SKUID */
