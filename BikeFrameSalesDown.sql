/*Creates temporary table #CostvRevenueJuly13 to select ProductID, SalesOrderID, OrderDate, Quantity, UnitCost, UnitRevenue, TotalCost, TotalRevenue, 
TransactionProfit for the current price*/
CREATE TABLE #CostvRevenueJuly13 (ProductID INT, SalesOrderID INT, OrderDate DATE, 	Quantity INT, UnitCost FLOAT, UnitRevenue FLOAT, 
	TotalCost FLOAT, TotalRevenue FLOAT, TransactionProfit FLOAT)

--Insert Vaules into #CostvRevenueJuly13
INSERT INTO #CostvRevenueJuly13 (ProductID, SalesOrderID, OrderDate, Quantity, UnitCost, 	UnitRevenue, TotalCost, TotalRevenue, TransactionProfit)
	SELECT DISTINCT Production.TransactionHistory.ProductID, 	Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderHeader.OrderDate, 
		Sales.SalesOrderDetail.OrderQty, Production.TransactionHistory.ActualCost, Sales.SalesOrderDetail.UnitPrice, 
		Sales.SalesOrderDetail.OrderQty * Production.TransactionHistory.ActualCost, Sales.SalesOrderDetail.UnitPrice * Sales.SalesOrderDetail.OrderQty, 
		Sales.SalesOrderDetail.UnitPrice * Sales.SalesOrderDetail.OrderQty - Sales.SalesOrderDetail.OrderQty * Production.TransactionHistory.ActualCost
		FROM Production.TransactionHistory, Sales.SalesOrderDetail, Sales.SalesOrderHeader
		WHERE Production.TransactionHistory.ProductID=723 AND 	Production.TransactionHistory.ProductID=Sales.SalesOrderDetail.ProductID AND 
			Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID AND 
			Sales.SalesOrderHeader.OrderDate=Production.TransactionHistory.TransactionDate AND Production.TransactionHistory.ActualCost <> 0

--Creates table #CostvRevenue similar to the one above but for old prices
CREATE TABLE #CostvRevenue (ProductID INT, SalesOrderID INT, OrderDate DATE, Quantity INT, UnitCost FLOAT, UnitRevenue FLOAT, 
	TotalCost FLOAT, TotalRevenue FLOAT, TransactionProfit FLOAT)

--Insert Vaules into #CostvRevenue
INSERT INTO #CostvRevenue (ProductID, SalesOrderID, OrderDate, Quantity, UnitCost, 	UnitRevenue, TotalCost, TotalRevenue, TransactionProfit)
	SELECT DISTINCT Production.TransactionHistoryArchive.ProductID, 	Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderHeader.OrderDate, 
	Sales.SalesOrderDetail.OrderQty, Production.TransactionHistoryArchive.ActualCost, Sales.SalesOrderDetail.UnitPrice, 
	Sales.SalesOrderDetail.OrderQty * Production.TransactionHistoryArchive.ActualCost, Sales.SalesOrderDetail.UnitPrice * 
	Sales.SalesOrderDetail.OrderQty, Sales.SalesOrderDetail.UnitPrice * Sales.SalesOrderDetail.OrderQty - Sales.SalesOrderDetail.OrderQty * 
	Production.TransactionHistoryArchive.ActualCost
	FROM Production.TransactionHistoryArchive, Sales.SalesOrderDetail, Sales.SalesOrderHeader
	WHERE Production.TransactionHistoryArchive.ProductID=723 AND 	Production.TransactionHistoryArchive.ProductID=Sales.SalesOrderDetail.ProductID 	AND Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID AND 
		Sales.SalesOrderHeader.OrderDate=Production.TransactionHistoryArchive.TransactionDate AND Production.TransactionHistoryArchive.ActualCost <> 0

--Checks that the two tables are fully complete and correct
SELECT * FROM #CostvRevenue
UNION
SELECT * FROM #CostvRevenueJuly13

--Combines the 2 temporary tables
INSERT INTO #CostvRevenue
	SELECT * FROM #CostvRevenueJuly13

--Selects the full table
SELECT * FROM #CostvRevenue