# FRE 521D Final Project
## Drought Impacts on Cereal Production: A Multi-Regional Analysis

**Team AgroAnalytics**


**Date:** February 10, 2024

---

## Overview

This project analyzes how drought affects cereal crop yields across different regions and income groups. We use data from Assignments 1 and 2 to quantify drought impacts, identify vulnerable regions, and understand what makes some agricultural systems more resilient than others.

## Research Questions

1. **Drought Impact on Yields**: How does drought affect crop yields, and which crops are most affected?
2. **Regional Vulnerability**: Which regions are most vulnerable to drought?
3. **Resilience Factors**: What factors help agricultural systems be more resilient to drought?

## Data Sources

All data comes from our FRE521D assignments:
- **Crop Production**: From A1 database - yields, area, production for major cereals
- **Weather Data**: From A2 ETL pipeline - temperature, precipitation by country/year
- **Country Metadata**: Income groups, regions from World Bank classification

## How to Run

### Prerequisites
- Python 3.8+
- Libraries in requirements.txt

### Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Make sure data files are in the data/ folder
ls data/
# Should show: crop_production_cleaned.csv, weather_data_cleaned.csv, countries.csv
```

### Running the Analysis

1. Open `01_main_analysis.ipynb` in Jupyter
2. Run all cells in order
3. Figures will be saved to `figures/`
4. Result tables saved to `data/`

Or from command line:
```bash
cd code
jupyter nbconvert --execute --to notebook 01_main_analysis.ipynb
```

## File Structure

```
FinalProject_AgroAnalytics/
│
├── README.md                 # This file
├── requirements.txt          # Python dependencies
├── report.pdf               # Final report (IEEE format)
├── presentation.pptx        # Slide deck
│
├── code/
│   ├── 01_main_analysis.ipynb   # Main analysis notebook
│   ├── 02_data_prep.ipynb       # Data cleaning (optional)
│   └── sql_queries.sql          # SQL queries used
│
├── data/
│   ├── crop_production_cleaned.csv
│   ├── weather_data_cleaned.csv
│   ├── countries.csv
│   ├── final_analysis_dataset.csv    # Output
│   ├── results_crop_drought_impact.csv
│   ├── results_regional_vulnerability.csv
│   └── results_country_resilience.csv
│
└── figures/
    ├── fig1_drought_yield_loss.png
    ├── fig2_drought_boxplots.png
    ├── fig3_regional_vulnerability.png
    ├── fig4_income_resilience.png
    └── fig5_temporal_trends.png
```

## Key Findings

1. **Maize is most vulnerable** - loses ~12% yield during drought years
2. **Sub-Saharan Africa faces highest risk** - combination of drought exposure and low adaptive capacity
3. **Income matters** - High-income countries lose only ~5% vs ~15% for low-income
4. **Irrigation is key** - Countries with irrigation infrastructure show much lower yield losses

## Methodology Notes

### Drought Definition
We define drought as years when precipitation falls below the 25th percentile for each country. This is a relative measure that accounts for different baseline climates.

### Vulnerability Index
Our vulnerability index combines:
- Yield loss during drought (50% weight)
- Yield coefficient of variation (30% weight)  
- Drought frequency (20% weight)

### Limitations
- Country-level aggregation hides local variation
- Drought defined by precipitation only (not temperature)
- Cannot establish causation from observational data
- Missing data for some countries

## Contact

Questions about this project? Email: 

## Acknowledgments

Thanks to Prof. Neloy for guidance on methodology and Dr. Wiseman for data access.
