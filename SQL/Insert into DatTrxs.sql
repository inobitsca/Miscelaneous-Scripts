insert into  PulseTemp.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select *  from PulseII.dbo.datTrxs 
where ModDate > '2011-04-18 00:00:00.000'

use pulsetemp
go 

select top 100 * from lstStockTransactions

Select count(1) from PulseTemp.dbo.datTrxs 
where moddate > '2012-10-20 10:35:04.000' 

Select top 100 * from PulseII.dbo.datTrxs where moddate > '2012-10-20 10:35:04.000' order by Moddate desc