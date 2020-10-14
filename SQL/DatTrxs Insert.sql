/* insert into  PulseTemp.dbo.lstStockTransactions (SiteID, TransactionID, ComplexID, TransactionTypeID, TransactionDate, TransactionUser, SKUID, Qty, LocationID )
select  *  from PulseII.dbo.lstStockTransactions
where transactiondate > '2011-04-18 00:00:00.000'
*/

Use pulsetemp
go 
select * from dbo.datTrxs where Basketcreatedate > '2012-10-20' order by Basketcreatedate desc

DBCC Shrinkfile (PulseTemp_log)

bulk insert  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select top 100 *  from PulseTemp.dbo.lstStockTransactions where Transactiondate > '2012-10-21 16:43:59.000'