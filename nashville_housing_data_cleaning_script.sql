/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data`

-- Standardize Date Format

ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
ADD COLUMN SaleDateConverted Date;

UPDATE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
SET SaleDateConverted = PARSE_DATE("%B %e, %Y", SaleDate)
WHERE TRUE

--Populate Property Address Data

SELECT *
FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data`
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddressNew
FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data` a
JOIN `geometric-vim-314715.nashville_data_cleaning.nashville_data` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE `geometric-vim-314715.nashville_data_cleaning.nashville_data` a
SET PropertyAddress = b.PropertyAddress
FROM (
  SELECT ParcelID, MIN(PropertyAddress) PropertyAddress
  FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data`
  WHERE NOT PropertyAddress IS NULL
  GROUP BY ParcelID
) b
WHERE a.ParcelID = b.ParcelID
AND a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data`
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ",") -1) as Address, 
SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ",") +1, LENGTH(PropertyAddress)) as Address 
FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data`


ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
ADD COLUMN PropertySplitAddress STRING;

UPDATE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ",") -1)
WHERE TRUE


ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
ADD COLUMN PropertySplitCity STRING;

UPDATE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
SET PropertySplitCity = SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ",") +1, LENGTH(PropertyAddress))
WHERE TRUE


SELECT
SPLIT(OwnerAddress, ",") [OFFSET(0)] AS A,
SPLIT(OwnerAddress, ',')[OFFSET(1)] AS B,
SPLIT(OwnerAddress, ',')[OFFSET(2)] AS C
FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data`

ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
ADD COLUMN OwnerSplitAddress STRING;

UPDATE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
SET OwnerSplitAddress = SPLIT(OwnerAddress, ",") [OFFSET(0)]
WHERE TRUE


ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
ADD COLUMN OwnerSplitCity STRING;

UPDATE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
SET OwnerSplitCity = SPLIT(OwnerAddress, ',')[OFFSET(1)]
WHERE TRUE


ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
ADD COLUMN OwnerSplitState STRING;

UPDATE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
SET OwnerSplitState = SPLIT(OwnerAddress, ',')[OFFSET(2)]
WHERE TRUE

--Remove Duplicates

CREATE OR REPLACE TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data` AS
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) AS row_num
FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data`
)

DELETE 
FROM `geometric-vim-314715.nashville_data_cleaning.nashville_data`
WHERE row_num > 1

-- Delete Unused Columns

ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
DROP COLUMN row_num

ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
DROP COLUMN OwnerAddress

ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
DROP COLUMN PropertyAddress

ALTER TABLE `geometric-vim-314715.nashville_data_cleaning.nashville_data`
DROP COLUMN SaleDate
