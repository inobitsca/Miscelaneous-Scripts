-- Select top 100 * from dbo.datExplodedSales where SKUID = 920 and priceelementid =422023 --no way to determin date of transaction
-- Select top 100 * from dbo.datTokenFrequencyByMonth where salesyear > 2009 -- no record later than 2009
-- Select top 100 * from dbo.lstStockTransactions where transactiondate > '2012-09-11 09:12:39.000'
-- Select top 100 * from datSalesByFlavour
Use PulseII 
Go




--select top 100 PulseII.datTrxs.BasketCreateDate from dbo.PulseII.datTrxs

/*  
insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select *  from PulseTemp.dbo.datTrxs where BasketCreateDate <>  BasketCreateDate 

insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select *  from PulseTemp.dbo.datTrxs where moddate < '2012-10-01 10:35:04.000' And moddate > '2012-07-01 00:00:00.000' - Done

-- dbcc shrinkfile  (pulseII_log)

insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select *  from PulseTemp.dbo.datTrxs where moddate < '2012-07-01 00:00:00.000' And moddate > '2012-04-01 00:00:00.000' - done

insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select *  from PulseTemp.dbo.datTrxs where moddate < '2012-04-01 00:00:00.000' And moddate > '2012-01-01 00:00:00.000' - Done

insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select *  from PulseTemp.dbo.datTrxs where moddate < '2012-01-01 00:00:00.000' And moddate > '2011-10-01 00:00:00.000'   - Done

dbcc shrinkfile  (pulseII_log)

insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select *  from PulseTemp.dbo.datTrxs where moddate < '2011-10-01 00:00:00.000' And moddate > '2011-07-01 00:00:00.000' - Done 

insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select *  from PulseTemp.dbo.datTrxs where moddate < '2011-07-01 00:00:00.000' -Done

Select top 100 * from dattrxs where PriceElementId = '3922526'

*/

insert into  PulseII.dbo.datTrxs (SiteID, BasketID, BasketCreateOrigin, BasketModOrigin, BasketCreateDate, ModDate, SettlementTrxID, SettlementTrxCreateOrigin, SettlementTrxCreateDateTime, SettlementTrxCreateDate, InvoicePartID, PaymentTypeID, PaymentToken, PriceElementID, PriceElementReinstatementStatusID, PriceElementReinstatementReasonID, PriceElementTypeID, IsBoxOffice, SalesModifierTypeID, SalesItemID, Quantity, UnitPrice, UnitDiscount, TotalPrice, ShowDate, PerformanceID, ComplexID, CinemaID, MovieID, ShowDateTime, ShowNo, CreateDateTime, ComboDetails, PartitionId, ChannelID, PrimaryDiscountToken, TotalPriceExVat, TotalPricePadded) 
select * from PulseTemp.dbo.datTrxs where moddate < '2012-10-05 17:10:13.000' And moddate > '2012-10-01 10:35:04.000'

--where moddate < '2011-07-01 00:00:00.000' -Done

select * from PulseTemp.dbo.datTrxs where basketcreatedate = '2012-10-01 10:44:43.000'

select * from PulseII.dbo.datTrxs where basketcreatedate = '2012-10-01 10:44:43.000'


Select *  from PulseII.dbo.datTrxs where moddate < '2012-10-11 12:00:00.000' And moddate > '2012-10-01 10:35:04.000'

Select count(1)  from PulseTemp.dbo.datTrxs where moddate < '2012-10-20 10:35:04.000' And moddate > '2012-10-01 10:35:04.000'



select top 100 * from datExplodedSales
