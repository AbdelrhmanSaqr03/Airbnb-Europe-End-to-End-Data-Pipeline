import pandas as pd
from sqlalchemy import create_engine
import seaborn as sns
import matplotlib.pyplot as plt

SERVER_NAME = r"DESKTOP-KP9SQKM\SQLEXPRESS"
DATABASE_NAME = "Airbnb_DWH"
DRIVER = "ODBC Driver 17 for SQL Server"

connection_string = f"mssql+pyodbc://@{SERVER_NAME}/{DATABASE_NAME}?driver={DRIVER}&trusted_connection=yes"
engine = create_engine(connection_string)

print("📊 Extracting a data sample for correlation analysis...")
query = """
    SELECT realSum, person_capacity, cleanliness_rating, 
           guest_satisfaction_overall, bedrooms, dist, metro_dist
    FROM bronze.airbnb_raw
"""
df = pd.read_sql(query, engine)

corr_matrix = df.corr()

print("\n📈 Price Correlation Coefficient (realSum):")
print(corr_matrix['realSum'].sort_values(ascending=False))

print("\n💡 As expected, the correlations with distances and ratings might be weak or moderate—which is why scraping is necessary!")