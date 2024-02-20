--Cleaning Data in SQL Queries --

SELECT *
FROM NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT --

-- CARA 1 --
-- (Sometimes it doesn't work)
--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

-- CARA 2 --
ALTER TABLE NashvilleHousing
ADD Sale_Date Date;

UPDATE NashvilleHousing
SET Sale_Date = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------
-- POPULATED PROPERTY ADDRESS DATA --
-- mengisi data alamat yang kosong berdasarkan parcellID & UniqueID--

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- lakukan self join menggabungkan satu table berdasarkan (ParcellID dan UniqueID) --
-- UniqueID berguna untuk membedakan parcellID yang punya ID sama --
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- ISNULL berguna untuk mengganti/mengisi bagian null --
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
-------------------------------------------------------------------------------------------------------------------------
-- bisa juga diisi dengan kalimat seperti 'no address' --
--UPDATE a
--SET PropertyAddress = ISNULL(a.PropertyAddress,'no address')
--FROM NashvilleHousing a 
--JOIN NashvilleHousing b
--	ON a.ParcelID = b.ParcelID
--	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL
-------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
-- PropertyAddress --

-- CARA 1 (menggunakan PARSENAME)
-- PARSENAME DIURUTKAN DARI BELAKANG --
SELECT 
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)
, PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAdress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAdress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD PropertyAdressCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAdressCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)


-- CARA 2 (menggunakan SUBSTRING & CHARINDEX)
-- (lebih gampang menggunakan PARSENAME)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAdress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyAdressCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAdressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------------
-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
-- OwnerAddress --

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAdress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSpiltCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSpiltState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
-- Mengganti Y & N dengan 'CASE STATEMENT' --

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-------------------------------------------------------------------------------------------------------------------------
-- REMOVE DUPLICATED --
-- Menggunakan ROW_NUMBER, PARTITION BY, CTE dan WINDOWS FUNCTIONS --
-- STEP 1 membuat queries ROW_NUMBER dan PARTITION BY, untuk mencari duplicate --
-- STEP 2 membuat CTE dan menggunakan WINDOWS FUNCTIONS, untuk mengkelompokkan semua duplicate menjadi satu -- 
-- STEP 3 menghapus duplicated --

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				LegalReference
	ORDER BY UniqueID ) AS Row_Num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress


-------------------------------------------------------------------------------------------------------------------------
-- DELETE UN USED COLUMNS --

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM NashvilleHousing