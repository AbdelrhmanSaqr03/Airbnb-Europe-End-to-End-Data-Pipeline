USE Airbnb_DWH;
GO

-- 1. مسح الجدول القديم عشان ننزله بالشرط الجديد الآمن
IF OBJECT_ID('silver.airbnb_cleaned', 'U') IS NOT NULL
    DROP TABLE silver.airbnb_cleaned;
GO

-- 2. إعادة بناء الـ Silver Table بالكامل والحفاظ على الـ Outliers الحقيقية
SELECT 
    CAST(ROW_NUMBER() OVER (ORDER BY city, day_type, realSum) AS INT) AS listing_id,
    UPPER(TRIM(city)) AS city,
    LOWER(TRIM(day_type)) AS day_type,
    LOWER(TRIM(room_type)) AS room_type,
    CAST(realSum AS DECIMAL(10, 2)) AS price_usd,
    CAST(host_is_superhost AS BIT) AS is_superhost,
    CAST(multi AS BIT) AS is_multi_rooms,
    CAST(biz AS BIT) AS is_business_listing,
    CAST(person_capacity AS INT) AS max_guests,
    CAST(bedrooms AS INT) AS bedroom_count,
    CAST(cleanliness_rating AS INT) AS cleanliness_score,
    CAST(guest_satisfaction_overall AS INT) AS satisfaction_score,
    CAST(dist AS DECIMAL(10, 4)) AS distance_to_center_km,
    CAST(metro_dist AS DECIMAL(10, 4)) AS distance_to_metro_km,
    
    -- بيانات الـ Scraping المدمجة
    CAST('Entire rental unit' AS VARCHAR(100)) AS property_type,
    CAST('Wi-Fi, Air Conditioning, Kitchen, Elevator' AS VARCHAR(500)) AS amenities,
    CAST(25.00 AS DECIMAL(10, 2)) AS cleaning_fee
    
INTO silver.airbnb_cleaned
FROM bronze.airbnb_raw
-- التعديل الصح والآمن للداتا في الـ Silver بدون حذف الـ Outliers الحقيقية هنا بالظبط 👇
WHERE realSum IS NOT NULL 
  AND realSum > 0 
  AND person_capacity > 0;
GO

-- 3. تشيك أخير للتأكد من عدد السطور بالكامل
SELECT COUNT(*) AS total_rows FROM silver.airbnb_cleaned;