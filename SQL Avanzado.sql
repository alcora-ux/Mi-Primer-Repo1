-- ROW NUMBER

SELECT 
	TerritoryID,
	Name,
	SalesYTD,
	[Group],
	ROW_NUMBER() OVER (ORDER BY SalesYTD DESC) AS Numero_fila,
	ROW_NUMBER() OVER (PARTITION BY [Group] ORDER BY SalesYTD DESC) AS Numero_fila_partition
FROM Sales.SalesTerritory
ORDER BY TerritoryID

-- RANK

SELECT 
	ProductID,
	ListPrice,
	RANK() OVER (ORDER BY ListPrice) AS Ranking,
	ROW_NUMBER() OVER (ORDER BY ListPrice) AS NumeroFila,
	DENSE_RANK() OVER (ORDER BY ListPrice) AS RankingDenso
FROM Production.Product

-- LEAD y LAG
SELECT 
	empleados.BusinessEntityID,
	FirstName,
	LastName,
	BirthDate,
	Gender,
	MaritalStatus,
	LAG(BirthDate) OVER(
		PARTITION BY Gender
		ORDER BY BirthDate
	) AS NacimientoPrevio,
	LEAD(BirthDate) OVER(
		PARTITION BY Gender
		ORDER BY BirthDate
	) AS NacimientoSiguiente
FROM HumanResources.Employee AS empleados
LEFT JOIN Person.Person AS personas
ON empleados.BusinessEntityID = personas.BusinessEntityID

-- N TILE
SELECT 
	CustomerID,
	SubTotal,
	NTILE(10) OVER (ORDER BY SubTotal) AS Grupo
FROM Sales.SalesOrderHeader

-- AGREGACIONES
SELECT 
	TerritoryID,
	Name,
	[Group],
	SalesYTD,
	SUM(SalesYTD) OVER() AS sum_over,
	SUM(SalesYTD) OVER(ORDER BY  SalesYTD) AS sum_over_order,
	SUM(SalesYTD) OVER(PARTITION BY [Group]) AS sum_over_part,
	SUM(SalesYTD) OVER(PARTITION BY [Group] ORDER BY  SalesYTD) AS sum_over_part_order
FROM Sales.SalesTerritory

----------------------
-- PIVOT FUNCTION ----
----------------------

SELECT
	TerritoryID,
	ShipMethodID,
	SUM(TotalDue) AS Total_ventas
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID, ShipMethodID
ORDER BY TerritoryID, ShipMethodID;

SELECT *
FROM (
	SELECT TerritoryID, ShipMethodID, TotalDue
	FROM Sales.SalesOrderHeader
) AS tabla
PIVOT (
	SUM(TotalDue)
	FOR ShipMethodID IN ([1], [5])
) AS tabla_pivot
ORDER BY TerritoryID

--------------------
-- CROSS APPLY -----
--------------------

----- Quiero obtener las 2 ventas más grandes por territorio ------
SELECT *
FROM Sales.SalesOrderHeader

-- OPCION 1
SELECT TOP 2
	TerritoryID,
	SalesOrderID,
	TotalDue
FROM sales.SalesOrderHeader
ORDER BY TotalDue DESC

-- OPCION 2
SELECT *
FROM Sales.SalesTerritory AS territorio
LEFT JOIN (
	SELECT TOP 2
		TerritoryID,
		SalesOrderID,
		TotalDue
	FROM sales.SalesOrderHeader
	ORDER BY TotalDue DESC
) AS ventas
ON territorio.TerritoryID = ventas.TerritoryID

-- OPCION 3

SELECT territorio.TerritoryID, SalesOrderID, TotalDue
FROM Sales.SalesTerritory AS territorio
CROSS APPLY(
	SELECT TOP 2
		TerritoryID,
		SalesOrderID,
		TotalDue
	FROM sales.SalesOrderHeader AS ventas
	WHERE territorio.TerritoryID = ventas.TerritoryID
	ORDER BY TotalDue DESC
) AS tabla_apply

-- OUTER
SELECT
	territorio.TerritoryID,
	territorio.Name,
	ventas.SalesOrderID,
	ventas.TotalDue
FROM Sales.SalesTerritory territorio
OUTER APPLY(
	SELECT TOP(2)
		TerritoryID,
		SalesOrderID,
		TotalDue
	FROM sales.SalesOrderHeader
	WHERE 
		TerritoryID = territorio.TerritoryID AND
		OrderDate = '2012-01-01' 
	ORDER BY TotalDue Desc
) AS ventas
ORDER BY territorio.TerritoryID
