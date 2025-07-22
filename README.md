# Google-Play-Store-Apps-Analysis
📱 Google Play Store Analytics: SQL-Powered App Performance Tool

🔍 What This Project Does
A MySQL-based analysis system that dynamically identifies underperforming apps in the Google Play Store by comparing ratings against category benchmarks. Perfect for developers, product managers, and marketers seeking data-driven insights.


## 📌 Project Highlights

- **8 real-world business scenarios** solved with SQL
- **Dynamic category analysis** via stored procedures
- **Data security measures** with audit logging
- **Correlation analysis** between ratings and reviews
- **Data cleaning operations** for improved quality

  
📊 Key Analyses Performed
Top 5 Promising Categories for free apps

Highest Revenue Generating Categories for paid apps

App Distribution Analysis across categories

Paid vs Free App Strategy Recommendations

Rating-Review Correlation Study

Dynamic Underperformer Identification

🚀 Getting Started
Prerequisites
MySQL Server 8.0+

Sample dataset (googleplaystore.csv)

🛠️ Technical Stack
Database: MySQL

Core Techniques:

Aggregation (AVG, ROUND)

Temporary tables

Query optimization

User-defined variables

/playstore-analysis  
├── /data                 # Sample dataset (CSV)  
├── schema.sql            # Table creation script  
├── analysis_procedure.sql # Core stored procedure  
├── README.md             # Project documentation  
└── queries.sql           # Example queries  
