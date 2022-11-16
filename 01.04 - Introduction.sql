USE AdventureWorks2012
GO
-- Enable Execution Plan
-- CTRL + M (Actual Execution Plan)
-- CTRL + L (Estimated Execution Plan)
SELECT [SalesOrderID]
      ,[SalesOrderDetailID]
      ,[CarrierTrackingNumber]
      ,[OrderQty]
      ,[ProductID]
      ,[SpecialOfferID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
FROM [Sales].[SalesOrderDetail]
GO
SELECT [ProductID],SUM([OrderQty])
FROM [Sales].[SalesOrderDetail]
GROUP BY [ProductID]
GO
SELECT VendorID, EmployeeID
FROM Purchasing.PurchaseOrderHeader
WHERE VendorID = 1540 AND EmployeeID = 258
GO
--****************************************************************************************
-- TEST
CREATE INDEX IX01 ON Purchasing.PurchaseOrderHeader(VENDORID,EMPLOYEEID);
CREATE INDEX IX02 ON Purchasing.PurchaseOrderHeader(EMPLOYEEID,VENDORID);
GO
SET STATISTICS IO ON 
SET STATISTICS TIME ON
GO
SELECT VendorID, EmployeeID
FROM Purchasing.PurchaseOrderHeader WITH(INDEX(IX01))
WHERE VendorID = 1540 AND EmployeeID = 258
GO
SELECT VendorID, EmployeeID
FROM Purchasing.PurchaseOrderHeader WITH(INDEX(IX02))
WHERE VendorID = 1540 AND EmployeeID = 258
GO
SELECT VendorID, EmployeeID
FROM Purchasing.PurchaseOrderHeader WITH(INDEX(IX_PurchaseOrderHeader_EmployeeID,IX_PurchaseOrderHeader_VendorID))
WHERE VendorID = 1540 AND EmployeeID = 258
GO
--****************************************************************************************
-- Cleanup
DROP INDEX IX01 ON Purchasing.PurchaseOrderHeader
DROP INDEX IX02 ON Purchasing.PurchaseOrderHeader

