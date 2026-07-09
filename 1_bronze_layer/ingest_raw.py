import os
import pandas as pd
from sqlalchemy import create_engine

SERVER_NAME = r"DESKTOP-KP9SQKM\SQLEXPRESS"
DATABASE_NAME = "Airbnb_DWH"
DRIVER = "ODBC Driver 17 for SQL Server"

connection_string = f"mssql+pyodbc://@{SERVER_NAME}/{DATABASE_NAME}?driver={DRIVER}&trusted_connection=yes"
engine = create_engine(connection_string)

DATA_DIR = "./data"  

all_dfs = []

print("🚀 Beginning to read and combine the 20 files...")

for file_name in os.listdir(DATA_DIR):
    if file_name.endswith('.csv'):
        file_path = os.path.join(DATA_DIR, file_name)
        
        df = pd.read_csv(file_path)
        
        base_name = file_name.replace('.csv', '')
        parts = base_name.split('_')
        
        city_name = parts[0].capitalize()
        day_type_name = parts[1].lower()

        df['city'] = city_name
        df['day_type'] = day_type_name
        
        if 'Unnamed' in df.columns[0] or df.columns[0] == '':
            df = df.iloc[:, 1:]
            
        all_dfs.append(df)
        print(f"✅ File prepared: {file_name} -> {city_name} ({day_type_name})")

print("\n🔄 Beginning to combine the data...")
combined_df = pd.concat(all_dfs, ignore_index=True)

print("⏳ Uploading the data to SQL Server automatically...")

combined_df.to_sql(
    name='airbnb_raw', 
    con=engine, 
    schema='bronze', 
    if_exists='replace', 
    index=False
)

print("\nExcellent! The Bronze Layer has been successfully completed.🎉")
print(f"📊 Total number of rows uploaded to the database: {len(combined_df)}")