# Government Spending Composition and GDP Growth — OECD Panel Analysis

## Overview

Does *what* governments spend on matter more than *how much* they spend? This project investigates whether the composition of government expenditure — across health, social protection, economic affairs, and education — is associated with long-term GDP growth across OECD countries.

Using panel data from 37 OECD countries over 22 years (2000–2022), I apply pooled OLS and fixed effects regression models to identify which spending categories show the most robust correlation with economic growth.

---

## Research Question

**How does government spending composition correlate with GDP growth across OECD countries?**

---

## Data Sources

| Dataset | Source | Coverage |
|---|---|---|
| Annual Government Expenditure by Function (COFOG) | OECD National Accounts | 37 countries, 2000–2022 |
| GDP Growth (annual %) | World Bank — World Development Indicators | 37 countries, 2000–2022 |

Spending categories used (COFOG codes):
- `_T` — Total government expenditure
- `GF04` — Health
- `GF07` — Education
- `GF09` — Economic affairs (infrastructure & productive investment)
- `GF10` — Social protection

All spending variables are expressed as a **share of total government expenditure (%)** to ensure comparability across countries with different currencies and economy sizes.

---

## Methodology

### Data Cleaning & Merging
- Loaded OECD COFOG data and World Bank GDP data in R
- Reshaped OECD data from long to wide format using `pivot_wider()`
- Computed spending shares as % of total expenditure
- Merged datasets on country code and year using `left_join()`

### Models

Three regression models are estimated, all with the same specification:

```
GDP_growth = β1·health_share + β2·social_share + β3·econ_share + β4·educ_share + ε
```

| Model | Specification | Purpose |
|---|---|---|
| Model 1 | Pooled OLS | Naive baseline, ignores country differences |
| Model 2 | Country Fixed Effects | Controls for time-invariant country characteristics |
| Model 3 | Two-Way Fixed Effects | Controls for country differences + global shocks (e.g. 2008 crisis, COVID) |

A **F-test** (`pFtest`) confirmed that fixed effects are necessary over pooled OLS (F = 2.97, p < 0.001).

---

## Key Findings

<img width="634" height="541" alt="image" src="https://github.com/user-attachments/assets/7a065d73-a2ea-42f5-868e-68306a16fe78" />

**Two findings are robust across all three models:**

1. **Social protection spending is negatively associated with GDP growth** — a 1 percentage point increase in social protection's share of total expenditure is associated with 0.09 to 0.31 pp lower GDP growth, depending on the model.

2. **Economic affairs spending is positively associated with GDP growth** — a 1 pp increase in economic affairs share is associated with 0.12 to 0.32 pp higher GDP growth.

These results are consistent with mainstream growth economics: productive investment (infrastructure, R&D support) tends to be associated with higher growth, while pure transfer spending shows a negative relationship — though causal interpretation requires caution (see Limitations).

---

## Visualizations

### Health Spending Share by Country (2019)
<img width="500" height="820" alt="image" src="https://github.com/user-attachments/assets/caaaea46-aaec-4a2b-946e-ded5f5d66430" />

### Spending Shares vs GDP Growth
<img width="500" height="820" alt="image" src="https://github.com/user-attachments/assets/e4b6766d-bcc8-46f4-9af4-71f7adb44c52" />

<img width="500" height="820" alt="image" src="https://github.com/user-attachments/assets/5f9ee1e0-2237-45a5-bd62-ee3c7fc6af27" />

<img width="1014" height="994" alt="image" src="https://github.com/user-attachments/assets/a7f59c65-b503-4fef-9f19-e0ace3b42e93" />

### Correlation Matrix
<img width="500" height="820" alt="image" src="https://github.com/user-attachments/assets/646765e1-f5cb-4d9d-836e-c289404970a5" />

---

## Limitations

- **Causality:** This analysis identifies correlations, not causal effects. Reverse causality is plausible (e.g. slower growing countries may expand social transfers as a stabilizer).
- **Omitted variables:** Despite fixed effects, time-varying factors such as trade openness, demographic change, and institutional quality are not controlled for.
- **Spending quality:** The analysis captures spending quantities, not efficiency or targeting quality.
- **Unbalanced panel:** Not all countries have data for all years, resulting in an unbalanced panel (T = 5–23 per country).

---

## Tools & Packages

- **Language:** R
- **Packages:** `tidyverse`, `ggplot2`, `plm`, `stargazer`, `corrplot`
- **Data wrangling:** `dplyr`, `tidyr`
- **Visualization:** `ggplot2`, `corrplot`
- **Econometrics:** `plm` (panel linear models), `stargazer` (regression tables)

---

## Repository Structure

```
oecd-spending-gdp-growth/
│
├── analysis.R              # Full R script
├── README.md               # This file
├── data/
│   ├── oecdspending.csv    # OECD COFOG expenditure data
│   └── GDPgrowthAPI.csv    # World Bank GDP growth data
└── plots/
    ├── plot_health_bar.png
    ├── plot_health_scatter.png
    ├── plot_social_scatter.png
    ├── plot_econ_scatter.png
    └── plot_correlation.png
```

---

## Author

**André Martins Kirschke**  
