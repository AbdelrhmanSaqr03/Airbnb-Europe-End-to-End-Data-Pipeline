# Airbnb Europe: End-to-End Data Engineering & BI Analytics Pipeline

An end-to-end data architecture project that ingests, cleans, warehouses, and visualizes Airbnb Europe market performance data to drive investment and operational insights.

## 🛠️ Tech Stack & Tools
- **Language:** Python
- **Database / Data Warehouse:** SQL Server (Transact-SQL)
- **Business Intelligence:** Power BI

## 🏗️ Architecture Breakdown

### 1. Bronze Layer (Ingestion)
- Located in `bronzelayer/`
- `ingest_raw.py`: Automates the raw data ingestion, preserving historical raw data in an immutable state.

### 2. Silver Layer (Cleaning & Transformation)
- Located in `silver layer/`
- Includes data profiling, deduplication, schema enforcement, and correlation checks to ensure high data quality before modeling.

### 3. Gold Layer (Data Warehousing)
- Implemented inside **SQL Server** using optimized SQL queries.
- Built a **Star Schema** with robust Fact and Dimension tables for high-performance querying and analytics.

### 4. BI Analytics Layer (Power BI Dashboard)
A highly polished, 4-page responsive dashboard focusing on strategic business pillars:
1. **Overview:** High-level executive performance and geographical distributions.
2. **Price Analysis:** Pricing dynamics and seasonality across cities and room types.
3. **Satisfaction & Quality Analysis:** Correlating host tiers (Superhosts) and cleanliness with customer retention signals.
4. **Capacity & Operational Analysis:** Visualizing hidden operational costs (cleaning fees) and room capacities.
