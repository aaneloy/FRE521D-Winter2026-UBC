# FRE 521D: Supplementary Notes
## Lecture 3: ETL Pipeline I - Beyond the Basics

**Instructor:** Asif Ahmed Neloy  
**Program:** UBC Master of Food and Resource Economics

---

These notes expand on concepts from Lecture 3 with additional real-world considerations you will encounter in practice.

---

## 1. The Encoding Nightmare: Why Your Data Looks Like Garbage

In lecture, we mentioned `encoding='utf-8'` as a solution. But the real world is messier. Let me explain why.

### The Historical Problem

Back in the 1980s, every country created their own character encoding:
- **Latin-1 (ISO-8859-1):** Western European languages
- **Windows-1252:** Microsoft's "extended" Latin-1
- **Shift-JIS:** Japanese
- **GB2312:** Simplified Chinese

When you open a file with the wrong encoding, you see mojibake (garbled text):

| Original | Wrong Encoding | What Happened |
|----------|----------------|---------------|
| café | cafÃ© | UTF-8 read as Latin-1 |
| São Paulo | SÃ£o Paulo | UTF-8 read as Latin-1 |
| naïve | na•ve | Latin-1 read as ASCII |

### The Detective Work

When pandas gives you garbage, here is how I approach it:

**Step 1:** Check the first few bytes of the file

```python
with open('mystery_file.csv', 'rb') as f:
    print(f.read(100))
```

If you see `b'\xef\xbb\xbf'` at the start, that is a UTF-8 BOM (Byte Order Mark). Use `encoding='utf-8-sig'`.

**Step 2:** Try the usual suspects in order

```python
encodings_to_try = ['utf-8', 'utf-8-sig', 'latin-1', 'cp1252', 'iso-8859-1']

for enc in encodings_to_try:
    try:
        df = pd.read_csv('file.csv', encoding=enc)
        print(f"Success with {enc}")
        break
    except UnicodeDecodeError:
        continue
```

**Step 3:** Use chardet for stubborn files

```python
import chardet

with open('mystery_file.csv', 'rb') as f:
    result = chardet.detect(f.read(10000))
    print(result)  # {'encoding': 'Windows-1252', 'confidence': 0.73}
```

### Why This Matters for Your Career

I have seen data pipelines break at 2 AM because someone in the Paris office saved a file with French accents using Windows-1252 instead of UTF-8. The pipeline expected UTF-8, crashed, and nobody noticed until the morning report was missing.

**Lesson:** Never assume encoding. Always detect or specify it explicitly.

---

## 2. The Chunking Strategy: When Data Does Not Fit in Memory

The lecture showed loading entire CSV files. But what happens when your file is 50 GB and your laptop has 16 GB of RAM?

### The Memory Problem

When you call `pd.read_csv()`, pandas loads the entire file into memory. For a 10 GB CSV with numeric data, you might need 20-30 GB of RAM after pandas creates its internal structures.

### The Solution: Chunked Reading

```python
# Process in chunks of 100,000 rows
chunk_size = 100_000
results = []

for chunk in pd.read_csv('huge_file.csv', chunksize=chunk_size):
    # Process each chunk
    summary = chunk.groupby('country')['yield'].mean()
    results.append(summary)

# Combine results
final_result = pd.concat(results).groupby(level=0).mean()
```

### When to Use Chunking

| File Size | RAM Available | Strategy |
|-----------|---------------|----------|
| < 1 GB | Any | Load entire file |
| 1-10 GB | 16+ GB | Load entire file, monitor memory |
| 10-50 GB | Any | Chunk processing |
| > 50 GB | Any | Consider Dask or Spark |

### A Real Scenario

Imagine you are processing 10 years of daily weather data for 10,000 stations. That is roughly 36 million rows. Instead of loading everything:

```python
# Calculate monthly averages without loading everything
monthly_temps = {}

for chunk in pd.read_csv('decade_weather.csv', chunksize=500_000):
    chunk['month'] = pd.to_datetime(chunk['date']).dt.to_period('M')
    monthly = chunk.groupby('month')['temperature'].agg(['sum', 'count'])
    
    for month, row in monthly.iterrows():
        if month not in monthly_temps:
            monthly_temps[month] = {'sum': 0, 'count': 0}
        monthly_temps[month]['sum'] += row['sum']
        monthly_temps[month]['count'] += row['count']

# Calculate final averages
for month in monthly_temps:
    monthly_temps[month]['avg'] = monthly_temps[month]['sum'] / monthly_temps[month]['count']
```

This processes the entire file using only enough memory for one chunk at a time.

---

## 3. The Excel Trap: Why CSV is Not Always Better

Many analysts prefer CSV because it is "simpler." But Excel files have hidden complexity that can bite you.

### Problem 1: Excel Silently Converts Your Data

Excel tries to be "helpful" by auto-detecting data types. This causes disasters:

| You Enter | Excel Shows | What Excel Stored |
|-----------|-------------|-------------------|
| 001234 | 1234 | Integer, leading zeros gone |
| 1-2 | 2-Jan | Date (January 2nd) |
| 10e5 | 1000000 | Scientific notation converted |
| TRUE | TRUE | Boolean, not string |

When you export to CSV, the damage is already done.

### Problem 2: Multiple Sheets

```python
# Reading a specific sheet
df = pd.read_excel('data.xlsx', sheet_name='2023_Data')

# Reading all sheets into a dictionary
all_sheets = pd.read_excel('data.xlsx', sheet_name=None)
for sheet_name, df in all_sheets.items():
    print(f"Sheet: {sheet_name}, Rows: {len(df)}")
```

### Problem 3: Formulas vs Values

Excel cells can contain formulas. When reading with pandas, you get the computed value, not the formula. This is usually fine, but if the formula references external files that are not available, you get errors or stale values.

### The Safe Approach

```python
# Read Excel with explicit type handling
df = pd.read_excel(
    'data.xlsx',
    sheet_name='Sheet1',
    dtype={'product_code': str},  # Preserve leading zeros
    na_values=['N/A', 'n/a', '-'],
    parse_dates=['date_column']
)
```

---

## 4. Schema Drift: When Your Source Changes Without Warning

In the lecture, we assumed the CSV structure stays constant. In reality, data sources change.

### Types of Schema Drift

| Type | Example | Impact |
|------|---------|--------|
| Column added | New "region" column appears | Pipeline ignores it (usually OK) |
| Column removed | "price" column disappears | Pipeline crashes |
| Column renamed | "temp" becomes "temperature" | Pipeline crashes |
| Type changed | Integer becomes float | Subtle bugs |
| Order changed | Columns rearranged | Problems if using position-based access |

### Defensive Loading

```python
def safe_load_csv(filepath, required_columns, optional_columns=None):
    """Load CSV with schema validation."""
    df = pd.read_csv(filepath)
    
    # Check required columns exist
    missing = set(required_columns) - set(df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {missing}")
    
    # Check for unexpected columns (potential drift indicator)
    expected = set(required_columns) | set(optional_columns or [])
    unexpected = set(df.columns) - expected
    if unexpected:
        print(f"WARNING: Unexpected columns found: {unexpected}")
    
    return df

# Usage
df = safe_load_csv(
    'crop_data.csv',
    required_columns=['country', 'year', 'crop', 'yield'],
    optional_columns=['notes', 'source']
)
```

### The Contract Approach

Before your pipeline processes data, verify the "contract":

```python
def validate_schema(df, contract):
    """Validate DataFrame against expected schema."""
    errors = []
    
    for col, expected_type in contract.items():
        if col not in df.columns:
            errors.append(f"Missing column: {col}")
        elif not pd.api.types.is_dtype_equal(df[col].dtype, expected_type):
            errors.append(f"Type mismatch for {col}: expected {expected_type}, got {df[col].dtype}")
    
    return errors

# Define your contract
schema_contract = {
    'country_code': 'object',
    'year': 'int64',
    'yield_kg_ha': 'float64'
}

errors = validate_schema(df, schema_contract)
if errors:
    raise ValueError(f"Schema validation failed: {errors}")
```

---

## 5. File Locking and Race Conditions

When multiple processes access the same file, chaos ensues.

### The Problem

Imagine two ETL jobs running simultaneously:
- Job A reads `data.csv` at 10:00:01
- Job B starts writing new `data.csv` at 10:00:02
- Job A finishes reading at 10:00:05 with half old data, half new data

### Solutions

**Option 1: File-based locking**

```python
import fcntl
import time

def read_with_lock(filepath):
    with open(filepath, 'r') as f:
        # Acquire shared lock (allows other readers)
        fcntl.flock(f.fileno(), fcntl.LOCK_SH)
        try:
            return pd.read_csv(f)
        finally:
            fcntl.flock(f.fileno(), fcntl.LOCK_UN)
```

**Option 2: Write to temporary, then rename (atomic)**

```python
import tempfile
import shutil

def safe_write_csv(df, filepath):
    # Write to temp file first
    temp_path = filepath + '.tmp'
    df.to_csv(temp_path, index=False)
    
    # Atomic rename (on same filesystem)
    shutil.move(temp_path, filepath)
```

**Option 3: Timestamp-based file naming**

```python
from datetime import datetime

def get_latest_file(pattern_dir, prefix):
    """Get the most recent file matching pattern."""
    import glob
    files = glob.glob(f"{pattern_dir}/{prefix}_*.csv")
    if not files:
        raise FileNotFoundError(f"No files matching {prefix}")
    return max(files)  # Lexicographic sort works with ISO timestamps

# Files named like: crop_data_2024-01-15_103045.csv
latest = get_latest_file('/data/raw', 'crop_data')
```

---

## 6. The Hidden Cost of Type Inference

Pandas tries to guess column types. This is convenient but expensive.

### Memory Impact

```python
import numpy as np

# Default inference - uses 8 bytes per integer
df = pd.DataFrame({'count': [1, 2, 3, 4, 5]})
print(df['count'].dtype)  # int64 (8 bytes each)

# Explicit small type - uses 1 byte per integer
df['count'] = df['count'].astype('int8')
print(df.memory_usage(deep=True))
```

### Type Optimization for Large Datasets

```python
def optimize_dtypes(df):
    """Reduce memory usage by downcasting numeric types."""
    for col in df.columns:
        col_type = df[col].dtype
        
        if col_type == 'int64':
            if df[col].min() >= 0 and df[col].max() <= 255:
                df[col] = df[col].astype('uint8')
            elif df[col].min() >= -128 and df[col].max() <= 127:
                df[col] = df[col].astype('int8')
            elif df[col].min() >= -32768 and df[col].max() <= 32767:
                df[col] = df[col].astype('int16')
        
        elif col_type == 'float64':
            df[col] = pd.to_numeric(df[col], downcast='float')
        
        elif col_type == 'object':
            num_unique = df[col].nunique()
            if num_unique / len(df) < 0.5:  # Less than 50% unique
                df[col] = df[col].astype('category')
    
    return df
```

For a 1 million row dataset, this can reduce memory from 500 MB to 50 MB.

---

## Summary: The Extraction Mindset

When extracting data, always ask yourself:

1. **What encoding is this file?** Never assume UTF-8.
2. **Will this fit in memory?** Plan for chunked processing if needed.
3. **What could change?** Build schema validation into your pipeline.
4. **Who else touches this file?** Consider locking or immutable file patterns.
5. **Am I wasting memory?** Optimize types for large datasets.

The goal is not just to load data, but to load it reliably, repeatedly, and efficiently.

---

## Practice Exercise

Take the crop production CSV from Assignment 1. Write a function that:
1. Detects the file encoding automatically
2. Validates that required columns exist
3. Optimizes memory usage by downcasting types
4. Adds metadata columns (_source_file, _extracted_at)
5. Returns both the DataFrame and a validation report

This is what production-grade extraction looks like.
