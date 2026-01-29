# FRE 521D: Supplementary Notes
## Lecture 6: Python Wrangling I - The Subtle Art of Clean Data

**Instructor:** Asif Ahmed Neloy  
**Program:** UBC Master of Food and Resource Economics

---

These notes explore data wrangling concepts that go beyond the lecture, with emphasis on edge cases that will trip you up in real projects.

---

## 1. The Categorical Type: Your Memory Best Friend

In lecture, we discussed data types like int64, float64, and object. But we did not cover the `category` type, which can dramatically reduce memory usage.

### The Problem with Object Type

When pandas stores strings as `object` type, each string is a separate Python object in memory:

```python
df = pd.DataFrame({
    'country': ['Canada', 'Canada', 'Canada', 'USA', 'USA', 'USA'] * 100000
})
print(df.memory_usage(deep=True))
# country: ~34 MB (600,000 separate string objects)
```

### The Category Solution

```python
df['country'] = df['country'].astype('category')
print(df.memory_usage(deep=True))
# country: ~0.6 MB (just integers pointing to 2 unique strings)
```

That is a **98% memory reduction** for repetitive string columns.

### When to Use Categories

| Use Category When | Do Not Use When |
|-------------------|-----------------|
| Few unique values (< 50% of rows) | Many unique values |
| Column used for grouping | Column will have new values added |
| Memory is a concern | You need string operations |

### Category Gotcha: New Values

```python
df['country'] = df['country'].astype('category')

# This works
df.loc[0, 'country'] = 'Canada'

# This FAILS - 'Mexico' is not in the category
df.loc[0, 'country'] = 'Mexico'
# TypeError: Cannot setitem on a Categorical with a new category

# You must add the category first
df['country'] = df['country'].cat.add_categories(['Mexico'])
df.loc[0, 'country'] = 'Mexico'  # Now works
```

### Ordered Categories for Rankings

```python
# Useful for ordinal data
risk_order = ['Low', 'Medium', 'High', 'Critical']
df['risk_level'] = pd.Categorical(
    df['risk_level'], 
    categories=risk_order, 
    ordered=True
)

# Now comparisons work
df[df['risk_level'] > 'Medium']  # Returns High and Critical only
```

---

## 2. The Timezone Trap

Datetime handling in lecture assumed naive datetimes. Real-world data has timezones, and getting them wrong causes subtle bugs.

### The Problem

```python
# Weather station reports temperature at 14:00 local time
# But what local time? Vancouver? Tokyo? London?

df = pd.DataFrame({
    'timestamp': ['2024-01-15 14:00:00', '2024-01-15 14:00:00'],
    'city': ['Vancouver', 'Tokyo'],
    'temperature': [5, 8]
})

df['timestamp'] = pd.to_datetime(df['timestamp'])
# These are now naive datetimes - pandas assumes they're the same moment
# But Vancouver 14:00 and Tokyo 14:00 are 17 hours apart!
```

### The Solution: Timezone-Aware Datetimes

```python
import pytz

# Method 1: Parse with timezone
df['timestamp_utc'] = pd.to_datetime(df['timestamp']).dt.tz_localize('UTC')

# Method 2: Convert local times to UTC
def localize_timestamp(row):
    local_tz = {
        'Vancouver': 'America/Vancouver',
        'Tokyo': 'Asia/Tokyo',
        'London': 'Europe/London'
    }
    tz = pytz.timezone(local_tz[row['city']])
    local_time = tz.localize(row['timestamp'])
    return local_time.astimezone(pytz.UTC)

df['timestamp_utc'] = df.apply(localize_timestamp, axis=1)
```

### The Golden Rule

**Store everything in UTC. Convert to local time only for display.**

```python
# Storage format (in database or files)
df['timestamp_utc'] = pd.to_datetime(df['timestamp']).dt.tz_localize('UTC')

# Display format (for reports)
df['timestamp_local'] = df['timestamp_utc'].dt.tz_convert('America/Vancouver')
```

### Daylight Saving Time Disasters

```python
# This timestamp does not exist in Vancouver
# (clocks jumped from 2:00 to 3:00)
pd.Timestamp('2024-03-10 02:30:00', tz='America/Vancouver')
# NonExistentTimeError

# This timestamp exists twice in Vancouver
# (clocks went back from 2:00 to 1:00)
pd.Timestamp('2024-11-03 01:30:00', tz='America/Vancouver')
# AmbiguousTimeError
```

Handle these with:

```python
df['timestamp'] = pd.to_datetime(df['timestamp']).dt.tz_localize(
    'America/Vancouver',
    nonexistent='shift_forward',  # Move to 3:00
    ambiguous='NaT'  # Mark as missing if ambiguous
)
```

---

## 3. Unicode Normalization: Why "café" ≠ "café"

Sometimes two strings look identical but are not equal. This is a Unicode nightmare.

### The Problem

```python
s1 = "café"  # 4 characters: c, a, f, é
s2 = "café"  # 5 characters: c, a, f, e, ◌́ (combining accent)

print(s1 == s2)  # False!
print(len(s1), len(s2))  # 4, 5
```

These are two valid ways to encode "é":
1. **Precomposed:** Single character "é" (U+00E9)
2. **Decomposed:** "e" + combining acute accent (U+0065 + U+0301)

### Why This Happens

- Data from different sources uses different normalization
- Copy-paste from web pages may change normalization
- Different operating systems have different defaults

### The Solution: Normalize Everything

```python
import unicodedata

def normalize_text(text):
    """Normalize unicode text to NFC form."""
    if pd.isna(text):
        return text
    return unicodedata.normalize('NFC', str(text))

df['city'] = df['city'].apply(normalize_text)
```

### The Four Normalization Forms

| Form | Description | Use Case |
|------|-------------|----------|
| NFC | Composed (é as single char) | Default, use this |
| NFD | Decomposed (e + accent) | Text processing |
| NFKC | Compatibility composed | Search/matching |
| NFKD | Compatibility decomposed | Search/matching |

For data pipelines, always use NFC as your standard.

---

## 4. The Floating Point Equality Problem

In lecture, we validated numeric ranges. But comparing floating point numbers has hidden traps.

### The Problem

```python
0.1 + 0.2 == 0.3  # False!

print(f"{0.1 + 0.2:.20f}")  # 0.30000000000000004441
```

Computers cannot represent most decimal numbers exactly in binary.

### Why This Matters for Data

```python
# You expect this to find rows where percentage sums to 100
df[df['pct_a'] + df['pct_b'] + df['pct_c'] == 100.0]  # Might find nothing!

# Some rows might sum to 99.99999999999999 or 100.00000000000001
```

### The Solution: Use Tolerances

```python
import numpy as np

# Instead of exact equality
df[df['value'] == 100.0]  # Bad

# Use approximate equality
df[np.isclose(df['value'], 100.0)]  # Good

# For checking sums
tolerance = 1e-9
mask = abs(df['pct_a'] + df['pct_b'] + df['pct_c'] - 100.0) < tolerance
df[mask]
```

### For Validation

```python
def validate_percentage_sum(df, columns, expected=100.0, tolerance=1e-6):
    """Validate that percentage columns sum to expected value."""
    actual_sum = df[columns].sum(axis=1)
    is_valid = np.isclose(actual_sum, expected, rtol=tolerance)
    
    invalid_rows = df[~is_valid]
    if len(invalid_rows) > 0:
        print(f"Found {len(invalid_rows)} rows where sum != {expected}")
        print(f"Actual sums range: {actual_sum[~is_valid].min():.10f} to {actual_sum[~is_valid].max():.10f}")
    
    return is_valid
```

---

## 5. The Duplicate Detection Puzzle

Finding duplicates seems simple, but real data has nuances.

### Exact Duplicates

```python
# Find rows that are completely identical
duplicates = df[df.duplicated(keep=False)]

# Find rows with duplicate keys
key_duplicates = df[df.duplicated(subset=['country', 'year'], keep=False)]
```

### Fuzzy Duplicates

What about "Canada" vs "CANADA" vs "canada "?

```python
def standardize_for_matching(text):
    """Standardize text for duplicate detection."""
    if pd.isna(text):
        return text
    return str(text).strip().lower()

df['country_std'] = df['country'].apply(standardize_for_matching)
fuzzy_dupes = df[df.duplicated(subset=['country_std', 'year'], keep=False)]
```

### Near-Duplicates: The Typo Problem

"Cananda" should match "Canada". This requires fuzzy matching:

```python
from rapidfuzz import fuzz, process

def find_similar_values(values, threshold=80):
    """Find values that are suspiciously similar (possible typos)."""
    unique_values = values.dropna().unique()
    suspicious_pairs = []
    
    for i, val1 in enumerate(unique_values):
        for val2 in unique_values[i+1:]:
            similarity = fuzz.ratio(str(val1), str(val2))
            if similarity >= threshold and similarity < 100:
                suspicious_pairs.append((val1, val2, similarity))
    
    return suspicious_pairs

# Find potential typos in country names
suspicious = find_similar_values(df['country'], threshold=85)
# [('Canada', 'Cananda', 92), ('Brazil', 'Brasil', 91)]
```

### The Resolution Strategy

```python
def deduplicate_with_strategy(df, key_columns, strategy='first'):
    """
    Deduplicate with explicit strategy.
    
    Strategies:
    - 'first': Keep first occurrence
    - 'last': Keep last occurrence  
    - 'max': Keep row with max value in specified column
    """
    if strategy in ['first', 'last']:
        return df.drop_duplicates(subset=key_columns, keep=strategy)
    elif strategy == 'max':
        # Keep the row with the maximum value (e.g., most recent update)
        idx = df.groupby(key_columns)['updated_at'].idxmax()
        return df.loc[idx]
```

---

## 6. The Merge Explosion Problem

Joining tables is fundamental, but unexpected duplicates can explode your row count.

### The Problem

```python
left = pd.DataFrame({'key': ['A', 'A', 'B'], 'value': [1, 2, 3]})
right = pd.DataFrame({'key': ['A', 'A', 'B'], 'data': ['x', 'y', 'z']})

result = left.merge(right, on='key')
print(len(result))  # Expected 3? You get 5!
```

When both sides have duplicate keys, you get a Cartesian product:
- A-1 matches with A-x and A-y (2 rows)
- A-2 matches with A-x and A-y (2 rows)
- B-3 matches with B-z (1 row)
- Total: 5 rows

### Detecting the Problem

```python
def safe_merge(left, right, on, how='inner', expected_growth=1.1):
    """Merge with safety checks for unexpected row explosion."""
    left_dupes = left[on].duplicated().any()
    right_dupes = right[on].duplicated().any()
    
    if left_dupes and right_dupes:
        print("WARNING: Both tables have duplicate keys - expect row multiplication")
    
    result = left.merge(right, on=on, how=how)
    
    growth_ratio = len(result) / max(len(left), len(right))
    if growth_ratio > expected_growth:
        print(f"WARNING: Merge increased rows by {growth_ratio:.1f}x")
        print(f"  Left rows: {len(left)}, Right rows: {len(right)}, Result rows: {len(result)}")
    
    return result
```

### The validate Parameter

```python
# Pandas can check this for you
result = left.merge(right, on='key', validate='one_to_one')  # Raises if not 1:1
result = left.merge(right, on='key', validate='many_to_one')  # Left can have dupes
result = left.merge(right, on='key', validate='one_to_many')  # Right can have dupes
```

---

## 7. The Silent NaN Propagation

NaN (Not a Number) has special behavior that causes subtle bugs.

### NaN Comparisons

```python
np.nan == np.nan  # False! NaN is not equal to itself
np.nan != np.nan  # True!

# This means:
df[df['value'] == np.nan]  # Returns nothing, even if NaN exists
df[pd.isna(df['value'])]   # Correct way to find NaN
```

### NaN in Aggregations

```python
df = pd.DataFrame({'value': [1, 2, np.nan, 4]})

df['value'].sum()   # 7.0 (NaN is skipped)
df['value'].mean()  # 2.33 (NaN is skipped, n=3)
df['value'].count() # 3 (NaN is not counted)
len(df)             # 4 (NaN is counted)
```

### NaN in Groupby

```python
df = pd.DataFrame({
    'group': ['A', 'A', None, 'B'],
    'value': [1, 2, 3, 4]
})

df.groupby('group')['value'].sum()
# group
# A    3
# B    4
# Note: The row with group=None is silently dropped!

# To include NaN as a group:
df.groupby('group', dropna=False)['value'].sum()
```

### The fillna Before Groupby Pattern

```python
# Replace NaN with a sentinel before grouping
df['group_clean'] = df['group'].fillna('UNKNOWN')
df.groupby('group_clean')['value'].sum()
```

---

## 8. Building a Data Quality Report

Validation should produce actionable reports, not just pass/fail.

### The Comprehensive Quality Report

```python
def generate_quality_report(df, name="Dataset"):
    """Generate a comprehensive data quality report."""
    report = {
        'dataset_name': name,
        'total_rows': len(df),
        'total_columns': len(df.columns),
        'columns': {}
    }
    
    for col in df.columns:
        col_report = {
            'dtype': str(df[col].dtype),
            'non_null_count': df[col].count(),
            'null_count': df[col].isna().sum(),
            'null_percentage': round(df[col].isna().sum() / len(df) * 100, 2),
            'unique_count': df[col].nunique(),
            'unique_percentage': round(df[col].nunique() / len(df) * 100, 2),
        }
        
        if pd.api.types.is_numeric_dtype(df[col]):
            col_report.update({
                'min': df[col].min(),
                'max': df[col].max(),
                'mean': round(df[col].mean(), 4),
                'std': round(df[col].std(), 4),
                'zeros': (df[col] == 0).sum(),
                'negative': (df[col] < 0).sum()
            })
        
        if pd.api.types.is_string_dtype(df[col]):
            col_report.update({
                'empty_strings': (df[col] == '').sum(),
                'max_length': df[col].str.len().max(),
                'sample_values': df[col].dropna().head(3).tolist()
            })
        
        report['columns'][col] = col_report
    
    return report

# Usage
report = generate_quality_report(df, "Crop Production Data")

# Pretty print
import json
print(json.dumps(report, indent=2, default=str))
```

### Automated Issue Detection

```python
def detect_data_issues(df):
    """Detect common data quality issues."""
    issues = []
    
    for col in df.columns:
        # High null percentage
        null_pct = df[col].isna().sum() / len(df) * 100
        if null_pct > 20:
            issues.append(f"HIGH_NULLS: {col} has {null_pct:.1f}% missing values")
        
        # Constant column (only one value)
        if df[col].nunique() == 1:
            issues.append(f"CONSTANT: {col} has only one unique value")
        
        # Potential ID column stored as float
        if df[col].dtype == 'float64' and col.lower().endswith('_id'):
            issues.append(f"TYPE_SUSPECT: {col} looks like an ID but is float64")
        
        # Numeric column with suspiciously round values
        if pd.api.types.is_numeric_dtype(df[col]):
            if df[col].dropna().apply(lambda x: x == int(x)).all():
                if df[col].dtype == 'float64':
                    issues.append(f"TYPE_SUGGEST: {col} contains only integers but stored as float")
    
    # Check for duplicate rows
    dupe_count = df.duplicated().sum()
    if dupe_count > 0:
        issues.append(f"DUPLICATES: {dupe_count} duplicate rows found")
    
    return issues

# Usage
issues = detect_data_issues(df)
for issue in issues:
    print(f"  ⚠️ {issue}")
```

---

## Summary: The Wrangling Mindset

Data wrangling is not just about transforming data. It is about understanding data deeply enough to transform it correctly.

Key principles:

1. **Types matter:** Use categories for memory, explicit numeric types for precision
2. **Time is complicated:** Always store in UTC, localize only for display
3. **Strings lie:** Normalize unicode, watch for invisible characters
4. **Floats approximate:** Never use `==` for float comparison
5. **NaN is special:** It propagates silently and disappears in groupby
6. **Joins multiply:** Validate cardinality before merging
7. **Document everything:** Generate quality reports, not just clean data

The goal is not just to make data work with your code. It is to make data trustworthy for decisions.

---

## Practice Exercise

Create a data quality function that:
1. Checks for duplicate keys in your Assignment 1 crop data
2. Validates that all numeric columns are within reasonable ranges
3. Detects any unicode normalization issues in country names
4. Produces a JSON report of all findings

This is the kind of validation that runs automatically before any analysis in production systems.
