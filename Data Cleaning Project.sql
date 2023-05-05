SELECT *
FROM PortfolioProject..NashvilleHousingData



-- Standardize the Date Format
Select SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData 
ALTER COLUMN SaleDate Date



-- Populate the Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousingData
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData A
JOIN PortfolioProject..NashvilleHousingData B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ] 
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData A
JOIN PortfolioProject..NashvilleHousingData B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ] 
WHERE A.PropertyAddress is null



--Putting Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData 
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousingData 
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousingData


ALTER TABLE NashvilleHousingData 
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData 
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData 
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Changing Y and N to Yes and No in "Sold as Vacant" Column
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END



-- Removing Duplicate Data
WITH RowNumCTE AS(
	SELECT *, 
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
			ORDER BY UniqueID
		) AS row_num
	FROM PortfolioProject..NashvilleHousingData
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Deleting Unused Columns
SELECT *
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress