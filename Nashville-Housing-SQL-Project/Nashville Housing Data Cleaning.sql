use portfolioproject;

select * from NashvilleHousing;
-- Date Standardization
go 
Alter table NashvilleHousing
Alter column SaleDate date;

select saledate from NashvilleHousing

-- populating Null address values
select * from NashvilleHousing where PropertyAddress is null;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

-- Splitting OwnerAddress into (address,city,state)
select * from NashvilleHousing;

select 
	PropertyAddress,
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from NashvilleHousing;

Alter table NashvilleHousing
add Address varchar(255),State varchar(255)

update NashvilleHousing
Set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

update NashvilleHousing
Set State = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Owner address seperation

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing;

Alter table NashvilleHousing
add OwnersAddress varchar(255),OwnerCity varchar(255),OwnerState varchar(255)

update NashvilleHousing
Set OwnersAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

update NashvilleHousing
Set OwnerCity = PARSENAME(replace(OwnerAddress,',','.'),2)

update NashvilleHousing
set OwnerState = PARSENAME(replace(OwnerAddress,',','.'),1)


-- select * from NashvilleHousing;
-- Conversting y and n into yes and no

select Distinct SoldAsVacant
from NashvilleHousing;

/*update NashvilleHousing
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

update NashvilleHousing
set SoldAsVacant = 'No'
where SoldAsVacant = 'N'
*/
update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end 

--Removing Duplicates
select * from NashvilleHousing;

-- all duplicate values deleted from the table.
with Row_num as
(
select * ,
ROW_NUMBER() over(partition by ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice order by UniqueID) row_num
from NashvilleHousing
)
--delete from Row_num
--where row_num > 1
select * from Row_num where row_num > 1


select * from NashvilleHousing
order by [UniqueID ];


Alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress
