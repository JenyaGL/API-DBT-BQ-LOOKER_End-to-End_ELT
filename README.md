
  **The Uppsala Conflict Data Program (UCDP)**

This project leverages data from the Uppsala Conflict Data Program (UCDP) alongside GDP data from the World Bank.
The UCDP is highly respected by researchers and is considered the gold standard for global conflict data. The dataset contains detailed records of individual conflict events worldwide, including precise dates, locations, the specific actors involved, and estimated fatalities.

The UCDP is highly respected by researchers and is considered the gold standard for global conflict data. 

The dataset contains detailed records of individual conflict events worldwide, including precise dates, locations, the specific actors involved, and estimated fatalities.

The goal of this project is to take this raw, historical conflict data and build a fully automated modern data stack that not only aggregates historical trends but actively predicts the probability of future conflicts occurring in specific countries.


  **Tools & architecture:**

Data Lake: Google Cloud Storage
Data Warehouse: BigQuery 
Data Transformation: dbt Core 
ML: BigQuery ML (BQML) 
BI: Looker Studio 
Version Control & CI/CD: Git & GitHub actions 

**The data flows through the architecture in the following stages:**

* **Automated Extract & Load (Data Lake):** 
A Python script fetches the latest 7 days of conflict events using the UCDP API. It attaches a `_loaded_at` audit timestamp to every row and uploads the data to Google Cloud Storage using dynamic filenames.

* **Warehouse Integration (Wildcard URIs):** 
Google BigQuery acts as the data warehouse. The external raw table is configured using a Wildcard URI (`ucdp_raw_data/GEDEvent_v26_*.csv`), allowing BigQuery to automatically combine all the weekly files into one massive table seamlessly.

* **Transformation & Deduplication (dbt Staging):** 
dbt reads the raw data and executes a staging model (`stg_ucdp_conflicts`) to standardize column names, filter out broken rows, and fix data types. It also utilizes BigQuery's `UNPIVOT` function to transpose 35 years of horizontal World Bank demographic columns into a clean, vertical format.

* **Feature Engineering:** 
A dbt model (`mart_country_conflict_features`) uses SQL window functions (`OVER PARTITION BY`) to create rolling 2-year historical windows for each country. This engineers a binary target variable to represent whether a conflict occurred in the following 2 years, while also joining demographic data to create contextual features like `gdp_per_capita` and `fatalities_per_100k_people`.

* **Machine Learning:** 
A Logistic Regression classification model is trained natively inside BigQuery using BigQuery ML

* **Inference (dbt Output):** 
A final dbt model (`mart_conflict_risk_predictions`) uses the `ML.PREDICT` function to ask the trained model to evaluate current data and output a probability percentage (0-100%) and a Risk Category (Low, Medium, High, Critical) for future conflicts.

* **Automation & Visualization:** 
BigQuery Scheduled Queries are set up to automatically retrain the ML model weekly. Looker Studio connects directly to the final dbt inference table, feeding a self-updating dashboard complete with a Choropleth Global Risk Map, an At-Risk Leaderboard, and Global Pulse scorecards.

https://datastudio.google.com/reporting/c7619470-2730-41b0-8c55-73a0e43db142

<img width="1024" height="696" alt="image" src="https://github.com/user-attachments/assets/3f8e7dfe-0847-49e1-b51d-1ad107f6ad0d" />

<img width="1075" height="774" alt="image" src="https://github.com/user-attachments/assets/df08137b-44f8-4b89-bea1-fd504939c4db" />

<img width="1024" height="687" alt="image" src="https://github.com/user-attachments/assets/04207a9e-8f29-46a0-bbbf-9daff61bb697" />


Building this pipeline from scratch was a rigorous exercise in Data Engineering best practices. Key challenges and learnings included:

Evolving the Pipeline Architecture: Transitioned from a manual CSV extraction process to a fully automated API Python script, implementing an append-only architecture with audit trails (_loaded_at) and SQL-based deduplication logic to ensure data integrity.

Navigating Git & Version Control: Successfully resolved complex Git merge conflicts (reconciling divergent branches between local and remote environments) and configured upstream tracking to push the repository to GitHub.

dbt Configuration & Security: Managed Google Cloud Service Account credentials securely, troubleshooting absolute vs. relative paths in the profiles.yml file to successfully link dbt to BigQuery.

Strict SQL Typing in BigQuery: Debugged strict boolean evaluation errors in BigQuery, learning that BigQuery requires explicit logical comparisons (e.g., type_of_violence = 1) rather than treating integers or strings as booleans in IF and CASE statements.

Cost Optimization & Data Contracts: Refactored dbt inference models to completely remove SELECT * statements. Explicitly defining columns established a strict data contract and significantly reduced BigQuery scanning costs via columnar storage optimization.


Machine Learning Nuances: Engineered solutions for mathematical overflow (converting decimal probabilities correctly)
