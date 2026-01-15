
# Data Lineage Documentation

Generated: 2026-01-14T09:30:29.381548

## Source
- File: crop_production_1990_2023.csv

## Raw Layer
- File: data/raw/crop_production_raw_20260114_093017.csv
- Contains exact copy of source with metadata columns added

## Cleaned Layer  
- File: data/cleaned/crop_production_cleaned_20260114_093017.csv

## Transformations Applied
- Stripped whitespace from text columns
- Converted Year from string to integer (handled X.0 format)
- Converted numeric columns to float (handled European decimals)
- Replaced missing codes (NA, .., -, N/A) with NULL
- Removed footnote markers (*, **, (e), (p)) from numbers
