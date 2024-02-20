---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- IMPORT DATA USING BULK INSERT AND OPENROWSET --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- USING BULK INSERT --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
USE [Amazon Product];
GO

CREATE TABLE AmazonProduct
(
product_ID nvarchar(50),
title varchar(max),
imgUrl nvarchar(250),
productURL nvarchar(250),
stars float,
reviews	int,
price float,
listPrice float,
category_id	int,
isBestSeller nvarchar(50),
boughtInLastMonth int
)
GO

BULK INSERT AmazonProduct
FROM 'C:\Users\User\Documents\DATA ANALYST LEARN\PYTHON\Personal Project Python\Amazon Product Project\amazon_products.csv'
WITH(
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a'
	);
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- USING OPENROWSET --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

USE [Amazon Product];
GO

SELECT * INTO ProductCategories
FROM OPENROWSET ('Microsoft.ACE.OLEDB.12.0', 
				'Excel 12.0; Database=C:\Users\User\Documents\DATA ANALYST LEARN\PYTHON\Personal Project Python\Amazon Product Project\amazon_categories.xlsx', 
				'SELECT * FROM [amazon_categories$]');
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA CLEANING --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Cast isBestSeller column into bit type --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

EXEC sp_help 'dbo.AmazonProduct';

ALTER TABLE dbo.AmazonProduct
ALTER COLUMN isBestSeller bit

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA EXPLORATION --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TOP 10 Product Category With 5 Stars Rating --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT TOP 10 cat.id, (cat.category_name) AS product_category, COUNT(pro.category_id) AS total_product, pro.stars
FROM AmazonProduct pro
JOIN ProductCategories cat
	ON pro.category_id = cat.id
WHERE stars = 5
GROUP BY cat.category_name, pro.category_id, cat.id, pro.stars
ORDER BY 3 DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5 Trending Product Based on Sales Performance -- 
-- Best Seller Product With The Highest Bought in Last Month --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT TOP 5 title, boughtInLastMonth, isBestSeller, stars
FROM AmazonProduct 
WHERE isBestSeller = 1 
ORDER BY 2 DESC, 4 DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Best Seller Product With 5 Stars Ratings --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT TOP 10 title, isBestSeller, boughtInLastMonth, stars
FROM AmazonProduct
WHERE stars = 5 AND isBestSeller = 1
ORDER BY 3 DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TOP 5 Category Product That Easiest To Sell Based on Highest Bought in Last Month --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT TOP 5 Cat.category_name, Pro.boughtInLastMonth
FROM AmazonProduct Pro
JOIN ProductCategories Cat
	ON Pro.category_id = Cat.id
WHERE boughtInLastMonth <> 0
ORDER BY 2 DESC 