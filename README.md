# NexaMart — Sales & Profitability Analysis

## Project Overview

This project analyzes retail sales performance to understand why high revenue does not always translate into high profitability.

Using Excel, SQL, and Power BI, I examined revenue, gross profit, profit margins, and branch-level performance to identify business improvement opportunities.

**Dataset:** Simulated retail transaction data used for portfolio practice.

## Business Questions

1. How much revenue and gross profit does NexaMart generate?
2. Which branches have the highest and lowest profit margins?
3. Why can a high-revenue branch have a relatively low profit margin?
4. What actions should management investigate to improve profitability?

## Tools & Workflow

| Tool | Purpose |
|---|---|
| Excel | Data auditing, cleaning, and validation |
| SQL | KPI calculations, branch comparisons, and financial analysis |
| Power BI | Interactive dashboard and executive summary |

**Workflow:** Data Quality Audit → SQL Analysis → Power BI Dashboard → Business Recommendations.

## Key Results

| KPI | Result |
|---|---:|
| Total Revenue | Rp33,176,965,950 |
| Gross Profit | Rp3,017,014,093 |
| Gross Profit Margin | 9.09% |
| Highest Branch Margin | B04 — 9.48% |
| Lowest Branch Margin | B06 — 8.53% |

### Key Insight

Branch B06 recorded a lower gross profit margin than B04. This indicates that revenue volume alone is insufficient to evaluate branch profitability.

The financial analysis identifies a margin gap, but it does not establish the operational cause with certainty.

## Data Quality & Validation

Before finalizing the dashboard:

- Five invalid orders were excluded.
- Nine problematic order-item rows were excluded.
- Two missing cost values were estimated using documented rules.
- Final revenue and gross profit KPIs were reconciled with the cleaned analysis results.

**Limitation:** Some cost values remain estimates, and the operational causes of branch-level margin differences have not been conclusively verified.

## Business Recommendations

1. Review discount policies in branch B06.
2. Compare product mix and purchasing costs between B06 and B04.
3. Examine promotional records and supplier prices to test potential explanations.
4. Validate findings before implementing operational changes.

These are evidence-informed recommendations for further investigation, not claims that the root cause has already been proven.

## Project Files

- [QA-Resolved Excel Dataset](NexaMart_QA_Resolved.xlsx)
- [Power BI Dashboard — PDF](NexaMart_Sales_Profit_Dashboard%20(2).pdf)
- [SQL Analysis Queries](NexaMart_Portfolio_SQL_Analysis.sql)

## Conclusion

This project demonstrates an end-to-end junior data analyst workflow: validating data, calculating business KPIs, investigating performance differences, visualizing results, and communicating practical recommendations with transparent limitations.
