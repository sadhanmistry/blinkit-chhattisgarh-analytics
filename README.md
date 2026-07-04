# Blinkit Chhattisgarh — Sales & Operations Analytics Platform (FY2025-26)

![Python](https://img.shields.io/badge/Python-3.14-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![Pandas](https://img.shields.io/badge/Pandas-data%20wrangling-150458)
![PowerBI](https://img.shields.io/badge/Power%20BI-dashboard-F2C811)
![Status](https://img.shields.io/badge/Status-Dashboard%20complete-brightgreen)

An end-to-end data analytics project simulating Blinkit's quick-commerce operations across
Chhattisgarh for fiscal year 2025-26 — built on a **medallion architecture** (Bronze → Silver →
Gold) using Python, pandas, and MySQL, with the analysis layer delivered through SQL business
questions and a six-page Power BI dashboard.

---

## Problem statement

Quick-commerce operators run on thin margins and tight delivery SLAs, where decisions on store
expansion, rider allocation, and inventory stocking depend on clean, queryable operational data.
This project builds that data foundation from the ground up — starting from realistically messy
raw data (missing values, duplicates, inconsistent formatting, referential integrity breaks) and
producing a trustworthy, analysis-ready warehouse capable of answering concrete business
questions around sales trends, store performance, delivery SLAs, customer behavior, and
inventory health, visualized in an interactive multi-page dashboard.

---

## Dashboard preview

| Home | Sales Overview |
|---|---|
| ![Home](dashboard/01_home.png) | ![Sales](dashboard/02_sales.png) |

| Store Performance | Customer Insights |
|---|---|
| ![Stores](dashboard/03_stores.png) | ![Customers](dashboard/04_customers.png) |

| Delivery & Rider Performance | Inventory Health |
|---|---|
| ![Delivery](dashboard/05_delivery.png) | ![Inventory](dashboard/06_inventory.png) |



---

## Architecture

```
                 ┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
   Raw CSVs  ──▶ │  blinkit_bronze │ ──▶  │  blinkit_silver  │ ──▶  │   blinkit_gold   │
                 │  (untouched,    │      │  (cleaned,       │      │  (star schema,   │
                 │   raw import)   │      │   correctly      │      │   PK/FK          │
                 │                 │      │   typed)         │      │   enforced)      │
                 └─────────────────┘      └──────────────────┘      └─────────────────┘
                                                                              │
                                                                              ▼
                                                                  SQL business questions
                                                                              │
                                                                              ▼
                                                                  Power BI dashboard
                                                                  (6 pages, CSV import)
```

- **Bronze**: raw CSVs loaded as-is into MySQL, no transformations — the permanent, immutable
  source of truth.
- **Silver**: cleaned and correctly typed — nulls resolved (imputed or re-derived, not just
  dropped), duplicates removed on the correct business key, referential integrity breaks
  quarantined, mixed date/time formats parsed explicitly, outliers identified against fixed
  business thresholds rather than blanket percentile cuts, column types corrected from generic
  `TEXT`/`DOUBLE`/`DATETIME` to proper `VARCHAR`/`INT`/`DECIMAL`/`DATE`.
- **Gold**: reshaped into a star schema (5 dimension tables, 4 fact tables) with explicit primary
  and foreign key constraints, exported to CSV and imported directly into Power BI.
- **Dashboard**: six pages (Home, Sales Overview, Store Performance, Customer Insights,
  Delivery & Rider Performance, Inventory Health) with cross-page navigation, KPI cards in
  Indian currency format (Crore/Lakh), and slicers on every analytical page.

---

## Dataset

A large-scale synthetic dataset modeling Blinkit's Chhattisgarh operations (Raipur, Bhilai,
Bilaspur, Durg, Korba, Rajnandgaon) across FY2025-26, including realistic store ramp-up
(newer stores launching mid-year) and seasonal demand patterns (festive-season spikes in
October–November, clearly visible in the Sales Overview trend).

| Table | Rows |
|---|---|
| stores | 15 |
| riders | 800 |
| customers | 50,000 |
| products | 6,000 |
| orders | 1,203,600 (1,115,768 non-cancelled) |
| order_items | ~4,495,500 |
| deliveries | 1,200,000 |
| inventory snapshots | 471,135 |

The raw data was deliberately generated with realistic data-quality problems — missing values,
duplicate records, inconsistent text casing, mixed date formats, sign errors, referential
integrity breaks, and outliers — so the cleaning phase reflects the kind of work a real-world
data pipeline actually requires, not just a happy-path ETL.

---

## Tech stack

- **Python**: pandas, NumPy, SQLAlchemy, PyMySQL
- **MySQL 8.0**: storage layer across all three medallion stages
- **SQL**: business-question queries, schema constraints, `ALTER`-based type correction
- **Jupyter Notebook**: pipeline development and documentation
- **Power BI Desktop**: six-page interactive dashboard, DAX measures, CSV-based data model

---

## Project structure

| File | Purpose |
|---|---|
| `01_bronze_data_import.ipynb` | Loads raw CSVs into `blinkit_bronze`, untouched |
| `01_silver_initial_data_exploration.ipynb` | Broad first-pass profiling of every table |
| `02_silver_data_transformation_findings.ipynb` | Deep-dive audit — documents every specific issue found per table before any fix is applied |
| `03_silver_data_cleaning.ipynb` | Fixes every issue identified in `02`, writes cleaned data back to `blinkit_silver` |
| `silver.sql` | Creates `blinkit_silver`, copies data from Bronze, and corrects column types (`TEXT`/`DOUBLE`/`DATETIME` → proper `VARCHAR`/`INT`/`DECIMAL`/`DATE`) |
| `04_gold_layer_build.ipynb` | Builds the `blinkit_gold` star schema (dimensions + facts) from cleaned Silver data |
| `gold.sql` | Creates `blinkit_gold` and adds primary/foreign key constraints across the star schema |
| `05_gold_tables_export_csv.ipynb` | Exports all 9 Gold tables to CSV for direct import into Power BI |
| `gold_business_questions.sql` | 13 SQL queries answering concrete business questions against `blinkit_gold` |
| `Blinkit_CG_Dashboard.pbix` | The Power BI dashboard file (add this to the repo) |

---

## Data quality issues handled

- Missing values — imputed where derivable (e.g. `selling_price` re-derived from `mrp` and
  `discount_pct`), left as `NULL` with a flag where not (e.g. unassigned `rider_id`)
- Duplicate records — deduplicated on the correct business key (`order_id`, `customer_id`), not
  naive full-row matching, which under-counts duplicates whose other fields drifted after the
  duplicate was created
- Inconsistent text formatting — casing and whitespace standardized across categorical columns
- Mixed date formats — parsed explicitly per format rather than relying on automatic inference,
  which can silently swap day/month on some rows
- Referential integrity breaks — order line items referencing non-existent products identified
  and quarantined rather than silently kept or dropped
- Sign errors — negative quantities and stock levels corrected
- Outliers — identified against fixed, domain-appropriate thresholds (e.g. delivery time > 100
  minutes) rather than statistical percentile cutoffs, which would also clip genuinely slow (but
  real) deliveries
- Legitimate nulls preserved — e.g. delivery time is correctly `NULL` for cancelled orders; this
  was distinguished from genuinely missing data rather than imputed away
- Generic MySQL column types (`TEXT`/`DOUBLE`/`DATETIME` from pandas auto-inference) corrected to
  proper `VARCHAR`/`INT`/`DECIMAL`/`DATE` for indexing, storage efficiency, and floating-point
  precision on currency fields

---

## Key insights

*(Fill in with your own headline numbers pulled from the dashboard — a few strong candidates
based on the queries in this repo: total FY2025-26 revenue and order count from Sales Overview;
which store leads on revenue vs. which has the highest cancellation rate from Store Performance;
the split between new/returning/premium customer revenue from Customer Insights; the average
delivery delay and top-performing rider from Delivery & Rider Performance; and the store or
category with the highest stockout rate from Inventory Health.)*

---

## Business questions answered (`gold_business_questions.sql`)

1. Monthly revenue trend across FY2025-26
2. Store performance ranking by revenue
3. Cancellation and return rate by store
4. Top 10 products by revenue
5. Revenue and quantity by product category
6. Payment mode distribution
7. Revenue split across customer segments
8. Customer repeat-purchase rate
9. Delivery performance by store (promised vs. actual time)
10. Rider performance leaderboard
11. Inventory stockout/low-stock frequency by store
12. Weekday vs. weekend order pattern
13. Store ramp-up — order volume relative to days since opening

---

## Dashboard

Six pages, navigable via a persistent top nav bar (built with Power BI's Page Navigator visual):

- **Home** — landing page with navigation tiles to every section
- **Sales Overview** — revenue/order trend, category and product mix, payment mode split
- **Store Performance** — revenue ranking, cancellation/return rates, store map, ramp-up analysis
- **Customer Insights** — segment revenue split, repeat-purchase behavior, age distribution, top spenders
- **Delivery & Rider Performance** — SLA tracking (promised vs. actual), rider leaderboard, delay analysis
- **Inventory Health** — stockout frequency by store/category, stock level trend, low-stock event detail

All currency KPIs are formatted in Indian numbering (Crore/Lakh) via custom DAX measures rather
than Power BI's default Western number formatting.

---

## How to run

1. Create three MySQL databases: `blinkit_bronze`, `blinkit_silver`, `blinkit_gold`.
2. Run `01_bronze_data_import.ipynb` to load the raw CSVs into `blinkit_bronze`.
3. Run `01_silver_initial_data_exploration.ipynb` and
   `02_silver_data_transformation_findings.ipynb` to audit the data.
4. Run `03_silver_data_cleaning.ipynb` to clean it and write the result to `blinkit_silver`.
5. Run `silver.sql` against `blinkit_silver` to correct column types.
6. Run `04_gold_layer_build.ipynb` to build the `blinkit_gold` star schema.
7. Run `gold.sql` against `blinkit_gold` to add PK/FK constraints.
8. Run the queries in `gold_business_questions.sql` against `blinkit_gold` to validate the layer.
9. Run `05_gold_tables_export_csv.ipynb` to export Gold tables to CSV.
10. Open `Blinkit_CG_Dashboard.pbix` in Power BI Desktop, or re-import the CSVs and rebuild the
    data model relationships (see the dashboard section above) if starting from scratch.

Update the MySQL connection credentials (`DB_USER`, `DB_PASSWORD`, `DB_HOST`) at the top of each
notebook before running.

---

## Known issues / next improvements

- A small number of stores share identical names (e.g. two different stores both named
  "Shankar Nagar") due to the synthetic data generation — resolved in the dashboard by referencing
  `store_id` alongside `store_name` where ambiguity matters.
- Repeat purchase rate currently computes as 100% at this data volume (~22 orders/customer on
  average) — verified against the underlying query rather than assumed.
- Planned: a written project report (PDF) summarizing findings, methodology, and recommendations.
- Planned: a slide deck for presenting the project.

---

## Author

**Sadhan Mistry**
B.Tech CSE | Data Analyst / Business Analyst

- LinkedIn: [linkedin.com/in/sadhanmistry](https://linkedin.com/in/sadhanmistry)
- GitHub: [github.com/sadhanmistry](https://github.com/sadhanmistry)
- Email: sadhanmistry.dev@gmail.com
