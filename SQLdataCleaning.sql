----Data Cleaning in SQL

select *
from PorfolioProject.dbo.NashvilleHousing

----Standartize Date Format

select SaleDateConverted, convert(Date,SaleDate)
from PorfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

----Populate Property Address data

select *
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

---- Breaking out Address into individual columns (address, city, state)

select PropertyAddress
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID;

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) as Address

from PorfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress));

select *
from PorfolioProject.dbo.NashvilleHousing;

select OwnerAddress
from PorfolioProject.dbo.NashvilleHousing;

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from PorfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

select *
from PorfolioProject.dbo.NashvilleHousing;

---- Change Y & N to Yes & No in 'Sold as Vacant'

select distinct(SoldAsVacant), count(SoldAsVacant)
from PorfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant
, CASE when SoldAsVacant = 'Y'then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PorfolioProject.dbo.NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y'then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end;

---- Remove duplicates

WITH RowNumCTE as (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
		UniqueID
		) row_num

from PorfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress;

select *
from PorfolioProject.dbo.NashvilleHousing;

---- Delete unused columns

select *
from PorfolioProject.dbo.NashvilleHousing;

Alter table PorfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

select *
from PorfolioProject.dbo.NashvilleHousing;
