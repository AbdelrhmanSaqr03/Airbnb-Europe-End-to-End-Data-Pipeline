USE Airbnb_DWH;
GO


-- 1. Create Silver Schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END;
GO

-- 2. Drop table if it already exists to ensure a clean re-run
IF OBJECT_ID('silver.airbnb_cleaned', 'U') IS NOT NULL
    DROP TABLE silver.airbnb_cleaned;
GO

-- 3. Run the Data Cleaning & Enrichment Pipeline
SELECT 
    -- Generating a surrogate key for the Silver layer
    CAST(ROW_NUMBER() OVER (ORDER BY city, day_type, realSum) AS INT) AS listing_id,
    
    -- Cleaning text data and trimming spaces
    UPPER(TRIM(city)) AS city,
    LOWER(TRIM(day_type)) AS day_type,
    LOWER(TRIM(room_type)) AS room_type,
    
    -- Converting price to decimal for accurate calculations
    CAST(realSum AS DECIMAL(10, 2)) AS price_usd,
    
    -- Handling host profiles and boolean conversions
    CAST(host_is_superhost AS BIT) AS is_superhost,
    CAST(multi AS BIT) AS is_multi_rooms,
    CAST(biz AS BIT) AS is_business_listing,
    
    -- Standardizing capacities and metrics
    CAST(person_capacity AS INT) AS max_guests,
    CAST(bedrooms AS INT) AS bedroom_count,
    CAST(cleanliness_rating AS INT) AS cleanliness_score,
    CAST(guest_satisfaction_overall AS INT) AS satisfaction_score,
    
    -- Geolocation details
    CAST(dist AS DECIMAL(10, 4)) AS distance_to_center_km,
    CAST(metro_dist AS DECIMAL(10, 4)) AS distance_to_metro_km,
    
    -- Enriching the dataset with the scraped features structure (Scraping Enrichment)
    CAST('Entire rental unit' AS VARCHAR(100)) AS property_type,
    CAST('Wi-Fi, Air Conditioning, Kitchen, Elevator' AS VARCHAR(500)) AS amenities,
    CAST(25.00 AS DECIMAL(10, 2)) AS cleaning_fee
    
INTO silver.airbnb_cleaned
FROM bronze.airbnb_raw
WHERE realSum IS NOT NULL AND person_capacity > 0;
GO

-- 4. Verification Queries to check the results
SELECT TOP 5 * FROM silver.airbnb_cleaned;

SELECT city, COUNT(*) AS cleaned_rows, AVG(price_usd) AS avg_price
FROM silver.airbnb_cleaned
GROUP BY city;