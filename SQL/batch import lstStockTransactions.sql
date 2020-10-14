
/*  
insert into  PulseII.dbo.lstStockTransactions (SiteID, TransactionID, ComplexID, TransactionTypeID, TransactionDate, TransactionUser, SKUID, Qty, LocationID)
select *  from PulseTemp.dbo.lstStockTransactions where TransactionDate > '2012-10-01 10:35:04.000' - done

insert into  PulseII.dbo.lstStockTransactions (SiteID, TransactionID, ComplexID, TransactionTypeID, TransactionDate, TransactionUser, SKUID, Qty, LocationID)
select *  from PulseTemp.dbo.lstStockTransactions where TransactionDate < '2012-10-01 10:35:04.000' And TransactionDate > '2012-07-01 00:00:00.000'  - Done

-- dbcc shrinkfile  (pulseII_log)

insert into  PulseII.dbo.lstStockTransactions (SiteID, TransactionID, ComplexID, TransactionTypeID, TransactionDate, TransactionUser, SKUID, Qty, LocationID)
select *  from PulseTemp.dbo.lstStockTransactions where TransactionDate < '2012-07-01 00:00:00.000' And TransactionDate > '2012-04-01 00:00:00.000'  - done

insert into  PulseII.dbo.lstStockTransactions (SiteID, TransactionID, ComplexID, TransactionTypeID, TransactionDate, TransactionUser, SKUID, Qty, LocationID)
select *  from PulseTemp.dbo.lstStockTransactions where TransactionDate < '2012-04-01 00:00:00.000' And TransactionDate > '2012-01-01 00:00:00.000' - Done

insert into  PulseII.dbo.lstStockTransactions (SiteID, TransactionID, ComplexID, TransactionTypeID, TransactionDate, TransactionUser, SKUID, Qty, LocationID)
select *  from PulseTemp.dbo.lstStockTransactions where TransactionDate < '2012-01-01 00:00:00.000' And TransactionDate > '2011-10-01 00:00:00.000'   

dbcc shrinkfile  (pulseII_log)

insert into  PulseII.dbo.lstStockTransactions (SiteID, TransactionID, ComplexID, TransactionTypeID, TransactionDate, TransactionUser, SKUID, Qty, LocationID)
select *  from PulseTemp.dbo.lstStockTransactions where TransactionDate < '2011-10-01 00:00:00.000' And TransactionDate > '2011-07-01 00:00:00.000'  - Done

insert into  PulseII.dbo.lstStockTransactions (SiteID, TransactionID, ComplexID, TransactionTypeID, TransactionDate, TransactionUser, SKUID, Qty, LocationID)
select *  from PulseTemp.dbo.lstStockTransactions where TransactionDate < '2011-07-01 00:00:00.000' - done

select count(1) from PulseII.dbo.lstStockTransactions
select count(1) from Pulsetemp.dbo.lstStockTransactions

select count(1) from PulseII.dbo.dattrxs
select count(1) from Pulsetemp.dbo.dattrxs

select top 100 *  from PulseII.dbo.lstStockTransactions where TransactionDate > '2012-10-21 16:00:00.000' order by TransactionDate desc
truncate table PulseII.dbo.lstStockTransactions

Select count(1)  from PulseII.dbo.datTrxs where moddate < '2012-10-20 10:35:04.000' And moddate > '2012-10-01 00:00:00.000'
Select count(1)  from Pulsetemp.dbo.datTrxs where moddate < '2012-10-20 10:35:04.000' And moddate > '2012-10-01 00:00:00.000'

*/
--Delete from PulseII.dbo.datTrxs where moddate < '2012-10-20 10:35:04.000' And moddate > '2012-10-01 00:00:00.000'


insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select * from PulseTemp.dbo.datTrxs where moddate > '2012-10-20 10:35:04.000' 

select count(1) from PulseII.dbo.datTrxs where moddate > '2012-10-20 10:35:04.000'