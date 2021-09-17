-- Cleaning Data using SQL

-- Check the data in the table
SELECT *
FROM
   housing_data;
   
SELECT
   COUNT(*)
FROM
   housing_data;

-- Standardize Date format
ALTER TABLE housing_data
ALTER COLUMN "SaleDate" TYPE DATE
USING "SaleDate"::DATE;

SELECT *
FROM housing_data;


-- Populate PropertyAddress data
SELECT *
FROM housing_data
WHERE "PropertyAddress" IS NULL;


SELECT *
FROM housing_data
ORDER BY "ParcelID";

SELECT a."ParcelID", a."PropertyAddress",
       b."ParcelID", b."PropertyAddress",
	   COALESCE(a."PropertyAddress", b."PropertyAddress")
FROM housing_data a
 JOIN housing_data b
 ON a."ParcelID" = b."ParcelID"
 AND a."UniqueID" != b."UniqueID"
WHERE a."PropertyAddress" IS NULL;

UPDATE housing_data a
SET "PropertyAddress" = COALESCE(a."PropertyAddress", b."PropertyAddress") 
FROM housing_data b
WHERE a."ParcelID" = b."ParcelID"
AND a."UniqueID" != b."UniqueID"
AND a."PropertyAddress" IS NULL;

SELECT COUNT(DISTINCT "PropertyAddress")
FROM housing_data;

-- Separating the Address into 3 separate columns (Address, City, State)
SELECT "PropertyAddress"
FROM housing_data;

SELECT
 SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress") - 1) AS "Address",
 SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress") + 2, LENGTH("PropertyAddress")) AS "City"
FROM housing_data;

UPDATE housing_data
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress") - 1);

SELECT *
FROM housing_data;

UPDATE housing_data
SET "City" = SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress") + 2, LENGTH("PropertyAddress"));

SELECT *
FROM housing_data;

SELECT SPLIT_PART("OwnerAddress", ',', 1) AS "Address",
SPLIT_PART("OwnerAddress", ',', 2) AS "City",
SPLIT_PART("OwnerAddress", ',', 3) AS "State"
FROM housing_data
WHERE "OwnerAddress" IS NOT NULL;

UPDATE housing_data
SET "SplitOwnerAddress" = SPLIT_PART("OwnerAddress", ',', 1);

UPDATE housing_data
SET "SplitOwnerCity" = SPLIT_PART("OwnerAddress", ',', 2);

UPDATE housing_data
SET "SplitOwnerState" = SPLIT_PART("OwnerAddress", ',', 3);

SELECT "PropertyAddress",
       "OwnerAddress"
FROM housing_data
WHERE "OwnerAddress" IS NOT NULL;

-- Change Y and N to Yes and No in the "SoldAsVacant" column
SELECT DISTINCT("SoldAsVacant")
FROM housing_data;

SELECT DISTINCT("SoldAsVacant"), 
COUNT("SoldAsVacant")
FROM housing_data
GROUP BY "SoldAsVacant"
ORDER BY 2;

SELECT "SoldAsVacant",
  CASE WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
       WHEN "SoldAsVacant" = 'N' THEN 'No'
  ELSE "SoldAsVacant"
  END
FROM housing_data;

UPDATE housing_data
SET "SoldAsVacant" =  CASE WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
                           WHEN "SoldAsVacant" = 'N' THEN 'No'
                           ELSE "SoldAsVacant"
                           END;

-- Checking if the last update worked
SELECT DISTINCT("SoldAsVacant"), 
COUNT("SoldAsVacant")
FROM housing_data
GROUP BY "SoldAsVacant"
ORDER BY 2;

-- Remove duplicates
WITH RowNumCTE AS(
  SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY "ParcelID",
		         "PropertyAddress",
		         "SalePrice",
		         "SaleDate",
		         "LegalReference"
		         ORDER BY "UniqueID") row_num
	FROM housing_data		
	)
  SELECT *
  FROM RowNumCTE
  WHERE row_num > 1
  ORDER BY "PropertyAddress";

WITH RowNumCTE AS(
  SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY "ParcelID",
		         "PropertyAddress",
		         "SalePrice",
		         "SaleDate",
		         "LegalReference"
		         ORDER BY "UniqueID") row_num
	FROM housing_data		
	)
  DELETE FROM RowNumCTE 
  WHERE row_num > 1;
