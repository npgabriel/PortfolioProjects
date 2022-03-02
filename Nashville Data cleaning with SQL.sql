-- Data cleaning

select * 
from NashvilleHousingData

-- Populate Property Address nulls

Select *
from NashvilleHousingData
where PropertyAddress is NULL


Select NHD1.ParcelID, NHD1.PropertyAddress, NHD2.ParcelID, NHD2.PropertyAddress, ISNULL(NHD1.PropertyAddress, NHD2.PropertyAddress)
from NashvilleHousingData NHD1
JOIN NashvilleHousingData NHD2
    on NHD1.ParcelID = NHD2.ParcelID
    and NHD1.[UniqueID] <> NHD2.[UniqueID]
where NHD1.PropertyAddress is NULL


Update NHD1
SET PropertyAddress = ISNULL(NHD1.PropertyAddress, NHD2.PropertyAddress)
from NashvilleHousingData NHD1
JOIN NashvilleHousingData NHD2
    on NHD1.ParcelID = NHD2.ParcelID
    and NHD1.[UniqueID] <> NHD2.[UniqueID]
where NHD1.PropertyAddress is null


-- Breaking PropertyAddress into individual columns with substring

Select PropertyAddress
From NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add PropertySplitStreet Nvarchar(200);

Update NashvilleHousingData
SET PropertySplitStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(100);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Breaking OwnerAddress into individual columns using parse

Select OwnerAddress
From NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerSplitStreet Nvarchar(200);

Update NashvilleHousingData
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(100);

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(5);

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in SoldAsVacant column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousingData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
        when SoldAsVacant = 'N' Then 'No'
        else SoldAsVacant
        END
From NashvilleHousingData

Update NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
    Else SoldAsVacant
    END


-- Remove Duplicates with CTE

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY 
                UniqueID
    ) row_num
From NashvilleHousingData
)
Delete
From RowNumCTE
Where row_num > 1

-- Delete unused columns

Alter Table NashvilleHousingData
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

Select * 
from NashvilleHousingData

