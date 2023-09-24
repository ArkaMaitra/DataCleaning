/*
cleaning data  through SQL
*/

Select *
From NashvilleHousing..housing

/* Date Formatting 

using convert*/

Select SaleDateconverted, CONVERT(date, SaleDate)
From NashvilleHousing..housing

update housing
Set SaleDate = CONVERT(date,SaleDate)

Alter Table housing
Add SaleDateConverted date;

update housing
Set SaleDateConverted = CONVERT(date,SaleDate)

/*  Porperty Address */

Select *
From NashvilleHousing..housing
--where PropertyAddress is null and
	--OwnerName is null
order by ParcelID

/* Adding addresses to null value with parcleid as 
reference point, so if someone has the same parcid but
has no address in another row, we can populate that cell
with pre-existing information about the same owner */

Select a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
from housing a
join housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from housing a
join housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


/* Divinding addresses into separate columns 
adding new columns
( Address, City, State) 

using substring, charindex*/

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , 
LEN(PropertyAddress)) as City
From NashvilleHousing..housing

Alter Table housing
Add PropertySplitAddress nvarchar(255);

update housing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, 
CHARINDEX(',',PropertyAddress) -1 )

Alter Table housing
Add PropertySplitCity nvarchar(255);

update housing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', 
PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From NashvilleHousing..housing

/* fixing Owner Adress using parsename and replace */

Select OwnerAddress
From NashvilleHousing..housing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHousing..housing

Alter Table housing
Add OwnerSplitAddress nvarchar(255);

update housing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table housing
Add OwnerSplitCity nvarchar(255);

update housing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table housing
Add OwnerSplitState nvarchar(255);

update housing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


Select *
From NashvilleHousing..housing
order by 24

/* In soldasvacant, turning all the y and n to yes 
and no and updating it into the database 

using case statements */

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing..housing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
From NashvilleHousing..housing
Group by SoldAsVacant

update housing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' 
then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

/* Removing Duplicates 
also, alwaystry to avoid original data, use temp 
table and then clean all th data inti it

using row number, cte and windows function partition by
*also, order by doesn't work in CTE
*/

With RowNumCTE as(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 order by UniqueID) as RowNum
From NashvilleHousing..housing
)
SELECT *
From RowNumCTE
where RowNum > 1
order by 2

/* deleting unused columns 

using drop*/

SELECT *
From NashvilleHousing..housing
order by 2

Alter table NashvilleHousing..housing
drop column PropertyAddress, TaxDistrict, 
OwnerAddress, SaleDate