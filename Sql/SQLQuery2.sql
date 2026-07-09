USE Airbnb_DWH;
GO

-- 1. التأكد من شكل الداتا وأول 10 صفوف
SELECT TOP 10 * FROM bronze.airbnb_raw;

-- 2. التأكد من إجمالي السطور وتوزيعها حسب المدينة والفترة
SELECT city, day_type, COUNT(*) AS total_rows 
FROM bronze.airbnb_raw 
GROUP BY city, day_type
ORDER BY city, total_rows DESC;