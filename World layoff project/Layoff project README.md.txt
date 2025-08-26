# 📊 Global Tech Layoffs Analysis (SQL Project)

## 🔹 Project Overview
This project explores global **tech sector layoffs (2020–2023)** using SQL.  
The dataset was messy, so I applied a full **data cleaning workflow** before analyzing trends across companies, industries, countries, and years.  

The aim was to showcase SQL skills in cleaning, transformation, and analysis — and to draw insights with real business relevance.  

---

## 🔹 Dataset
- Source: Public layoffs dataset (Kaggle / aggregated reports).  
- Columns: Company, Location, Industry, Country, Stage, Funds Raised, Date, Total Laid Off, Percentage Laid Off.  
- Size: Thousands of records from 2020–2023.  

---

## 🔹 Data Cleaning Process
Steps taken to prepare the data for analysis:  
1. **Preserve raw data** → created duplicate working tables.  
2. **Remove duplicates** using `ROW_NUMBER()` + CTE.  
3. **Standardization**:  
   - Trimmed company names  
   - Unified industry labels (e.g., “crypto” → “Crypto”)  
   - Fixed country names (“United States.” → “United States”)  
   - Converted date from text → SQL `DATE` format  
4. **Handle nulls/missing**:  
   - Replaced blanks with `NULL`  
   - Imputed industry values by joining on company & location  
   - Dropped rows with no layoff data  
5. **Dropped helper columns** → produced a clean final dataset `layoffs_new2`.  

---

## 🔹 Key Insights
📈 From the exploratory analysis:  
- **Layoffs peaked in late 2022 – early 2023**, reflecting global economic uncertainty.  
- The **United States** recorded the highest layoffs globally.  
- **Crypto, Retail, and Consumer Tech** were the hardest-hit industries.  
- **Big Tech (Meta, Amazon, Google, Microsoft)** consistently ranked in the top 5 yearly layoffs.  
- Startups with significant fundraising were not immune — showing that funding does not always guarantee job security.  

---

## 🔹 Recommendations
- **For Investors**: Exercise caution in highly volatile industries (e.g., Crypto). Diversify beyond high-risk tech segments.  
- **For Companies**: Build more sustainable workforce planning strategies to avoid extreme layoff cycles.  
- **For Policymakers**: Consider monitoring workforce stability in tech, as layoffs have ripple effects on local economies.  

---

## 🔹 Tools & Skills Demonstrated
- **SQL (MySQL)**: Data cleaning, CTEs, window functions, ranking, aggregations  
- **Data Preparation**: Handling duplicates, nulls, and data standardization  
- **Business Insight**: Identifying patterns and providing actionable recommendations  

---



