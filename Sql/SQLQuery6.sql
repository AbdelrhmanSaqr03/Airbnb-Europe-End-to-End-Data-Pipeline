USE Airbnb_DWH;
GO

-- 1. Drop existing Gold tables if they exist (to ensure a clean re-run)
IF OBJECT_ID('gold.fact_listings', 'U') IS NOT NULL DROP TABLE gold.fact_listings;
IF OBJECT_ID('gold.dim_properties', 'U') IS NOT NULL DROP TABLE gold.dim_properties;
IF OBJECT_ID('gold.dim_locations', 'U') IS NOT NULL DROP TABLE gold.dim_locations;
IF OBJECT_ID('gold.dim_hosts', 'U') IS NOT NULL DROP TABLE gold.dim_hosts;
GO

-- ==========================================
-- 2. Create Dimension Tables Explicitly
-- ==========================================

-- Create Location Dimension
CREATE TABLE gold.dim_locations (
    location_key INT NOT NULL,
    city VARCHAR(100) NOT NULL,
    CONSTRAINT PK_dim_locations PRIMARY KEY (location_key)
);

-- Create Property Dimension
CREATE TABLE gold.dim_properties (
    property_key INT NOT NULL,
    room_type VARCHAR(100) NOT NULL,
    property_type VARCHAR(100) NOT NULL,
    amenities VARCHAR(500) NOT NULL,
    CONSTRAINT PK_dim_properties PRIMARY KEY (property_key)
);

-- Create Host Dimension
CREATE TABLE gold.dim_hosts (
    host_key INT NOT NULL,
    is_superhost BIT NOT NULL,
    CONSTRAINT PK_dim_hosts PRIMARY KEY (host_key)
);


-- ==========================================
-- 3. Populate Dimension Tables from Silver
-- ==========================================

INSERT INTO gold.dim_locations (location_key, city)
SELECT 
    CAST(ROW_NUMBER() OVER (ORDER BY city) AS INT) AS location_key,
    city
FROM (SELECT DISTINCT city FROM silver.airbnb_cleaned) t;

INSERT INTO gold.dim_properties (property_key, room_type, property_type, amenities)
SELECT 
    CAST(ROW_NUMBER() OVER (ORDER BY room_type, property_type) AS INT) AS property_key,
    room_type,
    property_type,
    amenities
FROM (SELECT DISTINCT room_type, property_type, amenities FROM silver.airbnb_cleaned) t;

INSERT INTO gold.dim_hosts (host_key, is_superhost)
SELECT 
    CAST(ROW_NUMBER() OVER (ORDER BY is_superhost) AS INT) AS host_key,
    is_superhost
FROM (SELECT DISTINCT is_superhost FROM silver.airbnb_cleaned) t;


-- ==========================================
-- 4. Create Fact Table Explicitly
-- ==========================================
CREATE TABLE gold.fact_listings (
    listing_id INT NOT NULL,
    location_key INT NOT NULL,
    property_key INT NOT NULL,
    host_key INT NOT NULL,
    day_type VARCHAR(50) NOT NULL,
    price_usd DECIMAL(10, 2) NOT NULL,
    cleaning_fee DECIMAL(10, 2) NOT NULL,
    max_guests INT NOT NULL,
    bedroom_count INT NOT NULL,
    cleanliness_score INT NULL,
    satisfaction_score INT NULL,
    distance_to_center_km DECIMAL(10, 4) NOT NULL,
    distance_to_metro_km DECIMAL(10, 4) NOT NULL,
    is_multi_rooms BIT NOT NULL,
    is_business_listing BIT NOT NULL,
    CONSTRAINT PK_fact_listings PRIMARY KEY (listing_id),
    CONSTRAINT FK_fact_location FOREIGN KEY (location_key) REFERENCES gold.dim_locations(location_key),
    CONSTRAINT FK_fact_property FOREIGN KEY (property_key) REFERENCES gold.dim_properties(property_key),
    CONSTRAINT FK_fact_host FOREIGN KEY (host_key) REFERENCES gold.dim_hosts(host_key)
);


-- ==========================================
-- 5. Populate Fact Table
-- ==========================================
INSERT INTO gold.fact_listings
SELECT 
    s.listing_id,
    l.location_key,
    p.property_key,
    h.host_key,
    s.day_type,
    s.price_usd,
    s.cleaning_fee,
    s.max_guests,
    s.bedroom_count,
    s.cleanliness_score,
    s.satisfaction_score,
    s.distance_to_center_km,
    s.distance_to_metro_km,
    s.is_multi_rooms,
    s.is_business_listing
FROM silver.airbnb_cleaned s
JOIN gold.dim_locations l ON s.city = l.city
JOIN gold.dim_properties p ON s.room_type = p.room_type AND s.property_type = p.property_type AND s.amenities = p.amenities
JOIN gold.dim_hosts h ON s.is_superhost = h.is_superhost;
GO

-- ==========================================
-- 6. Verification Check
-- ==========================================
SELECT 'Fact Rows Count' AS Table_Name, COUNT(*) AS Total_Rows FROM gold.fact_listings
UNION ALL
SELECT 'Dim Locations Count', COUNT(*) FROM gold.dim_locations
UNION ALL
SELECT 'Dim Properties Count', COUNT(*) FROM gold.dim_properties
UNION ALL
SELECT 'Dim Hosts Count', COUNT(*) FROM gold.dim_hosts;