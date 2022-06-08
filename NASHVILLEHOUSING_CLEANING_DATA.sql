select * from NASHVILLE_HOUSE.dbo.NashVilleHousing

/*
Cleaning Data in sql
*/
---------------------------------------------------------------------------------
--Standardize Date Format

Select SaleDate,convert(date,saleDate) from NASHVILLE_HOUSE.dbo.NashVilleHousing



ALTER table NASHVILLE_HOUSE.dbo.NashVilleHousing add saleDateConverted date
Update NASHVILLE_HOUSE.dbo.NashVilleHousing set saleDateConverted=convert(date,saleDate)

Select SaleDate,saleDateConverted from NASHVILLE_HOUSE.dbo.NashVilleHousing




-----------------------------------------------------------------------------
--Populate Property adress data
select * from NASHVILLE_HOUSE.dbo.NashVilleHousing 
--Where PropertyAddress is null
order by ParcelId


select a.parcelID,a.PropertyAddress,b.parcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NASHVILLE_HOUSE.dbo.NashVilleHousing A
Join NASHVILLE_HOUSE.dbo.NashVilleHousing B
on a.ParcelID=b.parcelId
and a.UniqueID<>b.uniqueId
Where a.PropertyAddress is null


UPDATE A
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NASHVILLE_HOUSE.dbo.NashVilleHousing A
Join NASHVILLE_HOUSE.dbo.NashVilleHousing B
on a.ParcelID=b.parcelId
and a.UniqueID<>b.uniqueId
Where a.PropertyAddress is null

----------------------------------------------------------------------------------
--Breaking out Address into Individuals columns(adress,city,state)
select PropertyAddress from NASHVILLE_HOUSE.dbo.NashVilleHousing 
--Where PropertyAddress is null
order by ParcelId


select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from NASHVILLE_HOUSE.dbo.NashVilleHousing

--Add the two columns in the database
ALTER Table NASHVILLE_HOUSE.dbo.NashVilleHousing
ADD PropertySplitAddress VARCHAR(255)

ALTER Table NASHVILLE_HOUSE.dbo.NashVilleHousing
ADD PropertySplitCity VARCHAR(255)

update NASHVILLE_HOUSE.dbo.NashVilleHousing 
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

update NASHVILLE_HOUSE.dbo.NashVilleHousing 
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select PropertySplitAddress,PropertySplitCity 
from NASHVILLE_HOUSE.dbo.NashVilleHousing




select OwnerAddress 
from NASHVILLE_HOUSE.dbo.NashVilleHousing

select 
PARSENAME(Replace(OwnerAddress,',','.'),1) as State,
PARSENAME(Replace(OwnerAddress,',','.'),2) as City,
PARSENAME(Replace(OwnerAddress,',','.'),3) as Address

from NASHVILLE_HOUSE.dbo.NashVilleHousing

ALTER Table NASHVILLE_HOUSE.dbo.NashVilleHousing
ADD OwnerSplitAddress VARCHAR(255)

ALTER Table NASHVILLE_HOUSE.dbo.NashVilleHousing
ADD OwnerSplitCity VARCHAR(255)

ALTER Table NASHVILLE_HOUSE.dbo.NashVilleHousing
ADD OwnerSplitState VARCHAR(255)

update NASHVILLE_HOUSE.dbo.NashVilleHousing 
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

update NASHVILLE_HOUSE.dbo.NashVilleHousing 
set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

update NASHVILLE_HOUSE.dbo.NashVilleHousing 
set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)


----------------------------------------------------------------------------------

--Change Y and N to Yes and No in SoldasVacant field


Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from NASHVILLE_HOUSE.dbo.NashVilleHousing
group by soldAsVacant
order by 2

select soldAsVacant,
CASE
WHEN soldAsVacant='Y' then 'Yes'
WHEN soldAsVacant='N' then 'No'
ELSE soldAsVacant
END As SoldAsVacantClean
from NASHVILLE_HOUSE.dbo.NashVilleHousing
Where SoldAsVacant in ('Y','N')

ALTER TABLE NashVilleHousing
ADD SoldAsVacantClean varchar(255)

UPDATE NashVilleHousing
set SoldAsVacant=
CASE
WHEN soldAsVacant='Y' then 'Yes'
WHEN soldAsVacant='N' then 'No'
ELSE soldAsVacant
END 

Select SoldAsVacantClean,SoldAsVacant
from NASHVILLE_HOUSE.dbo.NashVilleHousing
Where SoldAsVacant in ('Y','N')


--------------------------------------------------------------------------
--REMOVE DUPLUCATES

WITH ROWNUMCTE as (
Select *,
ROW_NUMBER() over (partition by parcelID,
                       PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   Order by UniqueID)
					   As Row_num

from NASHVILLE_HOUSE.dbo.NashVilleHousing)
delete from ROWNUMCTE where Row_num>1

WITH ROWNUMCTE as (
Select *,
ROW_NUMBER() over (partition by parcelID,
                       PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   Order by UniqueID)
					   As Row_num

from NASHVILLE_HOUSE.dbo.NashVilleHousing)
select * from ROWNUMCTE where Row_num>1


----------------------------------------------------------------


--Delete UNUSED Coloumns

select * from NASHVILLE_HOUSE.dbo.NashVilleHousing

ALTER TABLE NASHVILLE_HOUSE.dbo.NashVilleHousing
DROP Column SaleDate,PropertyAddress,OwnerAddress,SoldAsVacantClean