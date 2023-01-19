SELECT *
FROM nashville_housing
--- Populate Property Address
SELECT *
FROM nashville_housing
--WHERE property_address IS NULL
ORDER BY parcel_id

SELECT n1.parcel_id, n1.property_address, n2.parcel_id, n2.property_address, COALESCE(n1.property_address, n2.property_address)
FROM nashville_housing n1
JOIN nashville_housing n2
ON n1.parcel_id = n2.parcel_id AND n1.unique_id != n2.unique_id
WHERE n1.property_address IS NULL

UPDATE nashville_housing 
SET property_address = COALESCE(n1.property_address, n2.property_address)
FROM nashville_housing n1
JOIN nashville_housing n2
ON n1.parcel_id = n2.parcel_id AND n1.unique_id != n2.unique_id
WHERE n1.property_address IS NULL

--- BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT property_address
FROM nashville_housing

SELECT split_part(property_address, ',', 1) AS address_new, 
split_part(property_address, ',', -1) AS city_name
FROM nashville_housing

ALTER TABLE nashville_housing
ADD property_split_address TEXT
UPDATE nashville_housing
SET property_split_address = split_part(property_address, ',', 1)

ALTER TABLE nashville_housing
ADD property_split_city TEXT
UPDATE nashville_housing
SET property_split_city = split_part(property_address, ',', -1)


--- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT owner_address
FROM nashville_housing

SELECT split_part(owner_address, ',', 1) as street_name,
split_part(owner_address, ',', 2) as city_name,
split_part(owner_address, ',', 3) as state_name
FROM nashville_housing

ALTER TABLE nashville_housing
ADD owner_split_address TEXT
UPDATE nashville_housing
SET owner_split_address = split_part(owner_address, ',', 1)

ALTER TABLE nashville_housing
ADD owner_split_city TEXT
UPDATE nashville_housing
SET owner_split_city = split_part(owner_address, ',', 2)

ALTER TABLE nashville_housing
ADD owner_split_state TEXT
UPDATE nashville_housing
SET owner_split_state = split_part(owner_address, ',', 3)

--- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD
SELECT DISTINCT (sold_as_vacant), COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant
ORDER BY 2

SELECT sold_as_vacant,
	CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		 WHEN sold_as_vacant = 'N' THEN 'No'
		 ELSE sold_as_vacant END
FROM nashville_housing

ALTER TABLE nashville_housing
ADD owner_split_city TEXT
UPDATE nashville_housing
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		 WHEN sold_as_vacant = 'N' THEN 'No'
		 ELSE sold_as_vacant END
		 
		 
-- REMOVE DUPLICATES
WITH row_num_cte AS(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY parcel_id, property_address,sale_price,sale_date, legal_reference ORDER BY unique_id) row_num
FROM nashville_housing
)
SELECT *
FROM row_num_cte
WHERE row_num > 1

--- DELETE UNUSED COLUMN
SELECT *
FROM nashville_housing

ALTER TABLE nashville_housing
DROP COLUMN owner_address

ALTER TABLE nashville_housing
DROP COLUMN property_address

ALTER TABLE nashville_housing
DROP COLUMN tax_district

ALTER TABLE nashville_housing
DROP COLUMN sale_date


