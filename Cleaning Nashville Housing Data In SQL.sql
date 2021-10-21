
-- Cleaning data from a Nashville housing dataset found here: https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fraw.githubusercontent.com%2FAlexTheAnalyst%2FPortfolioProjects%2Fmain%2FNashville%2520Housing%2520Data%2520for%2520Data%2520Cleaning.xlsx&wdOrigin=BROWSELINK


SELECT *
From Portfolioproject.dbo.NashvilleHousing


-- Standardizing Date Format


Select SaleDateConverted, CONVERT(Date, SaleDate)
From Portfolioproject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)



--------------------------------------------------------------------------------------------------------------------------------------

-- Populating Property Address Data


Select *
From Portfolioproject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Portfolioproject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  LEN(PropertyAddress)) as Address

From Portfolioproject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  LEN(PropertyAddress))



--------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Owner Address into Individual Columns


Select OwnerAddress
From Portfolioproject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolioproject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



--------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and NO in "Sold as Vacant" field


Select Distinct(SoldasVacant) , Count(SoldasVacant)
From Portfolioproject.dbo.NashvilleHousing
Group by SoldasVacant
order by 2



Select SoldasVacant
, CASE When SoldasVacant = 'Y' THEN 'Yes'
		When SoldasVacant = 'N' THEN 'No'
		Else SoldasVacant
		END
From Portfolioproject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldasVacant = CASE When SoldasVacant = 'Y' THEN 'Yes'
		When SoldasVacant = 'N' THEN 'No'
		Else SoldasVacant
		END


--------------------------------------------------------------------------------------------------------------------------------------

--Removing Duplicates


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
From Portfolioproject.dbo.NashvilleHousing
--order by UniqueID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



--------------------------------------------------------------------------------------------------------------------------------------

--Deleting Unused Columns


Select *
From Portfolioproject.dbo.NashvilleHousing


ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN SaleDate


