# Amazon Shampoo Sentiment Analysis

## Project Overview
**The Business Problem:**
Even the top-selling products on Amazon are at risk of losing market share due to unanswered requests or wishes and shifting customer sentiment. This project analyses a **12 GB dataset (23+ million reviews)** from the "Beauty and Personal Care" category to identify the specific root causes of customer churn for a leading shampoo brand.

**The Solution:** End-to-end data engineering and analytics pipeline. The system uses Docker to deploy a distributed Hadoop cluster, Apache Hive for structural processing of unstructured JSON data, and Python for predictive sentiment modeling.

## Key Findings
* **Root Cause Discovery:** While dryness was a common complaint, the analysis revealed that oily residue (keywords: *greasy, waxy, heavy*) was a more critical driver of negative sentiment for this specific product.
* **Secondary Limitation:** "Hair Fall" and "dandruff" were identified as significant negative phrase clusters.
* **Model Performance:** The Logistic Regression model achieved a precision of 0.93 for positive sentiment and 0.83 for negative sentiment, proving effective for automated feedback classification.

## Architecture & Tech Stack
* **Infrastructure:** Dockerized Hadoop Cluster (NameNode, DataNodes, Hive Server).
* **Storage:** HDFS (Distributed storage for 100+ blocks of JSON data).
* **ETL & Warehousing:** Apache Hive (using JsonSerDe for Schema-on-Read.
* **Machine Learning:** Python (Pandas, TF-IDF Vectorization, Logistic Regression).

## Repository Structure
```text
├── compose.yaml           # Infrastructure-as-Code (Hadoop Cluster config)
├── sql/
│   └── data_ingestion.hql # Hive scripts for table creation and data loading
├── notebooks/
│   └── Shampoo_Sentiment_Analysis.ipynb  # Main ML analysis & visualizations
├── logs/
│   └── execution_logs.txt # Evidence of successful MapReduce execution
└── requirements.txt       # Python dependencies
```

## How to Run

**1. Infrastructre Setup**
Start the Hadoop & Hive environment using Docker:
```bash
docker compose up -d
```
**2. Data Ingestion**
Load the raw data into the Hive warehouse:

```bash
docker cp data/beauty_reviews.jsonl namenode:/input/
docker exec -it hive-server hive -f sql/data_ingestion.hql
```
**3. Analytics & Modeling**
Install dependencies and run the Jupyter Notebook:

```bash
pip install -r requirements.txt
jupyter notebook notebooks/Shampoo_Sentiment_Analysis.ipynb
```

Raw data can be found here: https://amazon-reviews-2023.github.io/#citation







