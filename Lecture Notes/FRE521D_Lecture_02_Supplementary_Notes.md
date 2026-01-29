# FRE 521D: Lecture Notes - 12-01-2026

---

## Table of Contents

1. [Setting Up Your Environment](#1-setting-up-your-environment)
2. [Git and GitHub Essentials](#2-git-and-github-essentials)
3. [SQL Fundamentals](#3-sql-fundamentals)
4. [Data Definition Language (DDL)](#4-data-definition-language-ddl)
5. [Primary Keys and Foreign Keys](#5-primary-keys-and-foreign-keys)
6. [Table Relationships and Joins](#6-table-relationships-and-joins)
7. [Working with External Data](#7-working-with-external-data)
8. [References](#8-references)

---

## 1. Setting Up Your Environment

### 1.1 Running Your Development Environment

Before working with SQL and databases, you need to set up your environment properly.

**Step-by-Step Process:**

1. **Open your code editor**
   - Use either Jupyter Notebook or VS Code
   - Both work well for this course

2. **Start Docker Desktop**
   - Open the Docker Desktop application
   - Wait for it to fully start (the whale icon stops animating)

3. **Start your MySQL container**
   - Open a terminal (Command Prompt on Windows, Terminal on Mac)
   - Navigate to your course folder where `docker-compose.yml` is located
   - Run the command:
   ```bash
   docker-compose up -d
   ```
   - The `-d` flag runs it in "detached" mode (background)

4. **Verify the container is running**
   ```bash
   docker ps
   ```
   - You should see `fre521d_mysql` in the list

5. **Return to your notebook and run your code**

### 1.2 Troubleshooting Common Issues

| Problem | Solution |
|---------|----------|
| Container not starting | Restart Docker Desktop |
| Port already in use | Stop other MySQL instances |
| Connection refused | Wait 30 seconds for MySQL to initialize |

---

## 2. Git and GitHub Essentials

### 2.1 What is Git?

**Git** is a distributed version control system that tracks changes in your files. Think of it as an "unlimited undo" system that also lets multiple people work on the same project.

**Key Concepts:**

| Term | Definition |
|------|------------|
| **Repository (Repo)** | A folder tracked by Git containing your project files |
| **Commit** | A snapshot of your files at a specific point in time |
| **Branch** | A parallel version of your repository |
| **Remote** | A version of your repository hosted online (e.g., GitHub) |
| **Origin** | The default name for your remote repository |

### 2.2 What is a Fork?

A **fork** is a personal copy of someone else's repository that lives on your GitHub account.

```
┌─────────────────────────────────────────────────────────────────┐
│                         FORKING                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   INSTRUCTOR'S REPO                    YOUR FORK                 │
│   (Original)                           (Your Copy)               │
│   ┌─────────────┐      Fork            ┌─────────────┐          │
│   │ Course      │ ──────────────────>  │ Course      │          │
│   │ Materials   │                      │ Materials   │          │
│   │             │                      │ (your copy) │          │
│   └─────────────┘                      └─────────────┘          │
│         │                                    │                   │
│         │                                    │ Clone             │
│         │                                    ▼                   │
│         │                              ┌─────────────┐          │
│         │                              │ Your Local  │          │
│         │                              │ Computer    │          │
│         └──────────────────────────────│             │          │
│              (Sync updates)            └─────────────┘          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Why Fork?**

- Creates a copy attached to the original repository
- You can make changes without affecting the original
- You can pull updates from the original (upstream)
- You can submit changes back via Pull Requests

**How to Fork:**

1. Go to the instructor's repository on GitHub
2. Click the "Fork" button (top right)
3. Select your account as the destination
4. Clone your fork to your local machine

### 2.3 What is Stash?

**Stash** is a way to temporarily save changes that you're not ready to commit. Think of it as a clipboard for your code changes.

**When to Use Stash:**

- You have uncommitted changes
- You need to pull updates from the remote
- You want to switch branches but aren't ready to commit
- You want to save work-in-progress without making a commit

**How Stash Works:**

```
┌─────────────────────────────────────────────────────────────────┐
│                         STASHING                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   WORKING DIRECTORY          STASH             CLEAN STATE      │
│   (with changes)             (storage)         (ready to pull)  │
│                                                                  │
│   ┌─────────────┐           ┌─────────────┐   ┌─────────────┐  │
│   │ Your notes  │  ──────>  │ Saved       │   │ Original    │  │
│   │ Your edits  │   stash   │ temporarily │   │ files       │  │
│   │ Your code   │           │             │   │             │  │
│   └─────────────┘           └─────────────┘   └─────────────┘  │
│                                    │                 │          │
│                                    │    stash pop    │          │
│                                    └────────────────>│          │
│                                    (restore changes) │          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.4 Solving the Pull Conflict Problem

**The Problem:**

You have added your own notes to the lecture files. Now the I have pushed updates, and you want to:
1. Keep your personal notes
2. Get the new updates from me

**Solution for Windows Users (Command Line):**

```bash
# Step 1: Save your changes to stash
git stash

# Step 2: Pull the latest updates
git pull origin main

# Step 3: Restore your changes
git stash pop

# Step 4: If there are conflicts, Git will mark them
# Open the file and look for:
# <<<<<<< (your changes)
# =======
# >>>>>>> (incoming changes)

# Step 5: Manually edit the file to keep both changes
# Then add and commit
git add .
git commit -m "Merged my notes with instructor updates"
```

**Solution for Mac Users (Command Line):**

```bash
# Step 1: Save your changes to stash
git stash

# Step 2: Pull the latest updates
git pull origin main

# Step 3: Restore your changes
git stash pop

# Step 4: If conflicts exist, resolve them manually
# Look for conflict markers in files

# Step 5: Add and commit the resolved files
git add .
git commit -m "Merged my notes with instructor updates"
```

**Solution Using GitHub Desktop (Windows & Mac):**

1. **If GitHub Desktop shows uncommitted changes:**
   - Click "Fetch origin" to check for updates
   - If it asks to commit or stash, choose one:
     - **Commit**: If your changes are complete and you want to save them
     - **Stash**: If your changes are temporary

2. **To Stash in GitHub Desktop:**
   - Go to Branch menu → Stash All Changes
   
3. **To Pull Updates:**
   - Click "Fetch origin"
   - Click "Pull origin" if updates are available

4. **To Restore Your Stashed Changes:**
   - Go to Branch menu → View Stashed Changes
   - Click "Restore"

5. **If Conflicts Occur:**
   - GitHub Desktop will show conflicted files
   - Click on each file to open in your editor
   - Resolve conflicts manually
   - Return to GitHub Desktop and commit

**Visual Guide - Resolving Conflicts:**

When you see conflict markers in a file:

```
<<<<<<< HEAD
# Your notes: This query finds all foods with high protein
=======
# Instructor update: This query demonstrates the WHERE clause
>>>>>>> origin/main
```

**How to resolve:**

Keep both by editing the file:

```
# Your notes: This query finds all foods with high protein
# Instructor update: This query demonstrates the WHERE clause
```

Then save, add, and commit.

### 2.5 Best Practices for Managing Course Materials

1. **Keep your notes in separate files** when possible
2. **Commit frequently** with meaningful messages
3. **Pull updates before starting work** each day
4. **Use branches** for experimental changes

---

## 3. SQL Fundamentals

**SQL Command Categories:**

| Category | Full Name | Purpose | Commands |
|----------|-----------|---------|----------|
| **DDL** | Data Definition Language | Define database structure | CREATE, ALTER, DROP |
| **DML** | Data Manipulation Language | Manipulate data | INSERT, UPDATE, DELETE |
| **DQL** | Data Query Language | Query data | SELECT |
| **DCL** | Data Control Language | Control access | GRANT, REVOKE |

### 3.2 Case Sensitivity in SQL

Understanding case sensitivity is crucial to avoid errors.

**Rules:**

| Element | Case Sensitive? | Example |
|---------|-----------------|---------|
| SQL Keywords (CREATE, SELECT, INSERT) | No/Yes, only Yes for older SQL DBs | `CREATE` = `create` = `Create` |
| Table Names | Depends on OS* | `Students` vs `students` |
| Column Names | Depends on OS* | `FirstName` vs `firstname` |
| String Data | Yes | `'John'` ≠ `'john'` |
| Date/Time Data | No | `'Jan 01'` = `'JAN 01'` |

*On Linux/Mac, table names are case-sensitive. On Windows, they are not.

**Best Practice:** Always use lowercase with underscores for table and column names.

```sql
-- Good
CREATE TABLE student_records (
    student_id INT,
    first_name VARCHAR(50)
);

-- Avoid
CREATE TABLE StudentRecords (
    StudentID INT,
    FirstName VARCHAR(50)
);
```

### 3.3 Basic SQL Syntax

**Column Definition Syntax:**

```
COLUMN_NAME DATA_TYPE [OPTIONAL_CONSTRAINTS]
```

**Examples:**

```sql
-- Basic column
student_id INT

-- Column with NOT NULL constraint
first_name VARCHAR(50) NOT NULL

-- Column with default value
enrollment_date DATE DEFAULT CURRENT_DATE

-- Column as primary key
id INT PRIMARY KEY AUTO_INCREMENT
```

**Common Data Types:**

| Type | Description | Example |
|------|-------------|---------|
| `INT` | Integer numbers | 1, 42, -100 |
| `DECIMAL(p,s)` | Precise decimals | 123.45 |
| `VARCHAR(n)` | Variable-length string | 'Hello' |
| `TEXT` | Long text | Long descriptions |
| `DATE` | Date only | '2026-01-15' |
| `DATETIME` | Date and time | '2026-01-15 14:30:00' |
| `BOOLEAN` | True/False | TRUE, FALSE |

---

## 4. Data Definition Language (DDL)

### 4.1 CREATE TABLE

The `CREATE TABLE` statement defines a new table structure.

**Syntax:**

```sql
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    ...
    table_constraints
);
```

### 4.2 Example: Student and Faculty Tables

Let's design two related tables for a university database.

**Student Table (Schema):**

| Column | Type | Description |
|--------|------|-------------|
| s_id | INT | Student ID (Primary Key) |
| s_fn | VARCHAR(50) | First Name |
| s_ln | VARCHAR(50) | Last Name |
| dob | DATE | Date of Birth |
| dept | VARCHAR(50) | Department |
| faculty_id | INT | Advisor's ID (Foreign Key) |

**SQL:**

```sql
CREATE TABLE student (
    s_id INT PRIMARY KEY,
    s_fn VARCHAR(50) NOT NULL,
    s_ln VARCHAR(50) NOT NULL,
    dob DATE,
    dept VARCHAR(50),
    faculty_id INT
);
```

**Faculty Table (Schema):**

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Faculty ID (Primary Key) |
| f_fn | VARCHAR(50) | First Name |
| f_ln | VARCHAR(50) | Last Name |
| dept | VARCHAR(50) | Department |
| supervisor | VARCHAR(50) | Supervisor Name |

**SQL:**

```sql
CREATE TABLE faculty (
    id INT PRIMARY KEY,
    f_fn VARCHAR(50) NOT NULL,
    f_ln VARCHAR(50) NOT NULL,
    dept VARCHAR(50),
    supervisor VARCHAR(50)
);
```

**Sample Data:**

```sql
-- Insert faculty
INSERT INTO faculty (id, f_fn, f_ln, dept, supervisor)
VALUES (1, 'AA', 'BB', 'MFRE', 'KW');

-- Insert student
INSERT INTO student (s_id, s_fn, s_ln, dob, dept, faculty_id)
VALUES (1, 'A', 'B', '2000-01-01', 'MFRE', 1);
```

---

## 5. Primary Keys and Foreign Keys

### 5.1 What is a Primary Key?

A **Primary Key** (PK) is a column (or combination of columns) that uniquely identifies each row in a table.

**Rules:**
- Must be unique for every row
- Cannot contain NULL values
- Each table can have only one primary key

### 5.2 What is a Foreign Key?

A **Foreign Key** (FK) is a column that creates a link between two tables by referencing the primary key of another table.

**Relationship Diagram:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    TABLE RELATIONSHIPS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   FACULTY TABLE                      STUDENT TABLE               │
│   ┌─────────────────┐               ┌─────────────────┐         │
│   │ id (PK)     [1] │◄──────────────│ faculty_id (FK) │         │
│   │ f_fn            │               │ s_id (PK)       │         │
│   │ f_ln            │               │ s_fn            │         │
│   │ dept            │               │ s_ln            │         │
│   │ supervisor      │               │ dob             │         │
│   └─────────────────┘               │ dept            │         │
│                                     └─────────────────┘         │
│                                                                  │
│   The foreign key (faculty_id) in Student references            │
│   the primary key (id) in Faculty                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Creating Tables with Foreign Keys:**

```sql
-- First, create the parent table (Faculty)
CREATE TABLE faculty (
    id INT PRIMARY KEY,
    f_fn VARCHAR(50),
    f_ln VARCHAR(50),
    dept VARCHAR(50),
    supervisor VARCHAR(50)
);

-- Then, create the child table with foreign key (Student)
CREATE TABLE student (
    s_id INT PRIMARY KEY,
    s_fn VARCHAR(50),
    s_ln VARCHAR(50),
    dob DATE,
    dept VARCHAR(50),
    faculty_id INT,
    FOREIGN KEY (faculty_id) REFERENCES faculty(id)
);
```

### 5.3 Creating Primary Keys When None is Obvious

Sometimes your data doesn't have a natural unique identifier. Here are strategies:

**Strategy 1: Sequential ID (Auto-increment)**

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

-- MySQL automatically assigns 1, 2, 3, ...
INSERT INTO products (product_name, price) VALUES ('Apple', 1.50);
INSERT INTO products (product_name, price) VALUES ('Banana', 0.75);
```

**Strategy 2: Composite Key (Multiple Columns)**

When a single column isn't unique, combine columns:

```sql
-- Country-Year data where each country appears multiple times
CREATE TABLE country_metrics (
    country_code VARCHAR(3),
    year INT,
    gdp DECIMAL(15,2),
    population BIGINT,
    PRIMARY KEY (country_code, year)  -- Composite key
);
```

**Strategy 3: Mapping Table with Generated Keys**

For complex scenarios, create a mapping:

| country | c_code | value |
|---------|--------|-------|
| China | 1 | ... |
| China | 1_1 | ... |

```sql
CREATE TABLE country_data (
    record_id VARCHAR(10) PRIMARY KEY,  -- '1', '1_1', '1_2', etc.
    country VARCHAR(100),
    c_code INT,
    value DECIMAL(15,2)
);
```

---

## 6. Table Relationships and Joins

### 6.1 Understanding Joins

When data is split across multiple tables, you use **joins** to combine them.

**Types of Joins:**

| Join Type | Description | Returns |
|-----------|-------------|---------|
| INNER JOIN | Matching rows only | Rows that exist in both tables |
| LEFT JOIN | All left + matching right | All rows from left table |
| RIGHT JOIN | All right + matching left | All rows from right table |
| FULL OUTER JOIN | All rows from both | Everything (MySQL uses UNION) |
| CROSS JOIN | Cartesian product | Every combination (A × B) |

### 6.2 Join Analogy: Vector Multiplication

Think of joins like mathematical operations:

**Cross Join (Cartesian Product) = A × B**

Every row from A combined with every row from B.

```
Table A: [1, 2]
Table B: [a, b]

A × B = [(1,a), (1,b), (2,a), (2,b)]
```

```sql
SELECT * FROM table_a CROSS JOIN table_b;
```

**Inner Join (Matching) = A · B (Dot Product)**

Only matching elements combined.

```sql
SELECT s.s_fn, s.s_ln, f.f_fn AS advisor
FROM student s
INNER JOIN faculty f ON s.faculty_id = f.id;
```

### 6.3 Abstract View vs Physical View

**Physical View:**
- The actual data stored in tables
- How data is organized on disk
- Includes all columns and rows

**Abstract View (Logical View):**
- A simplified representation of data
- Created using `VIEW` statements
- Hides complexity from users

```sql
-- Create an abstract view that hides complexity
CREATE VIEW student_advisor_view AS
SELECT 
    s.s_id,
    CONCAT(s.s_fn, ' ', s.s_ln) AS student_name,
    s.dept,
    CONCAT(f.f_fn, ' ', f.f_ln) AS advisor_name
FROM student s
LEFT JOIN faculty f ON s.faculty_id = f.id;

-- Users can query the view simply
SELECT * FROM student_advisor_view;
```

**Benefits of Abstract Views:**
- Simplifies complex queries
- Provides security (hide sensitive columns)
- Maintains consistency
- Easier for non-technical users

---

## 7. Working with External Data

### 7.1 Reading Data from Files

Before loading external data (CSV, Excel, etc.) into your database, ensure it is clean.

**Data Cleaning Checklist:**

| Check | Problem | Solution |
|-------|---------|----------|
| Null columns | Entirely empty columns | Remove before loading |
| Special characters | Symbols like #, @, & in names | Remove or replace |
| Empty values | Blank cells in required fields | Fill or mark as NULL |
| Duplicate columns | Same column name twice | Rename or remove |
| Inconsistent types | Numbers stored as text | Convert to proper type |
| Header issues | Multiple header rows | Keep only one |

**Example: Loading CSV with Python:**

```python
import pandas as pd

# Load CSV
df = pd.read_csv('food_data.csv')

# Check for issues
print("Columns:", df.columns.tolist())
print("Missing values:\n", df.isnull().sum())
print("Duplicates:", df.duplicated().sum())

# Clean column names
df.columns = [col.lower().replace(' ', '_') for col in df.columns]

# Remove empty columns
df = df.dropna(axis=1, how='all')
```

### 7.2 Sharing Data and Code

**Option 1: GitHub (Recommended for Code)**

- Share repository access with collaborators
- Upload CSV files (if small, < 100MB)
- Upload notebook files (.ipynb)
- Track changes over time

**Option 2: Direct File Sharing**

For large files or non-Git users:
- Google Drive
- OneDrive
- Dropbox

**Best Practices:**

1. **Always include a README** explaining your data
2. **Document data sources** and collection dates
3. **Include data dictionaries** explaining each column
4. **Version your data files** (data_v1.csv, data_v2.csv)

---

## 8. References

### SQL Documentation

1. **MySQL Official Documentation**
   - https://dev.mysql.com/doc/
   - Comprehensive reference for all MySQL features

2. **W3Schools SQL Tutorial**
   - https://www.w3schools.com/sql/
   - Beginner-friendly with interactive examples

3. **SQLBolt**
   - https://sqlbolt.com/
   - Interactive SQL lessons

### Git and GitHub

4. **Git Official Documentation**
   - https://git-scm.com/doc
   - Complete Git reference

5. **GitHub Docs**
   - https://docs.github.com/
   - Guides for GitHub features including forking

6. **Atlassian Git Tutorials**
   - https://www.atlassian.com/git/tutorials
   - Visual explanations of Git concepts

### Database Design

7. **Database Design Fundamentals**
   - Elmasri & Navathe, "Fundamentals of Database Systems"
   - Standard textbook for database concepts

8. **Entity-Relationship Modeling**
   - Chen, P. "The Entity-Relationship Model" (1976)
   - Original paper on ER diagrams

### Course-Specific Resources

9. **Docker Documentation**
   - https://docs.docker.com/
   - Container management reference

10. **Pandas Documentation**
    - https://pandas.pydata.org/docs/
    - Python data manipulation library

---

## Quick Reference Card

### Git Commands

```bash
# Check status
git status

# Stage changes
git add .

# Commit changes
git commit -m "Your message"

# Pull updates
git pull origin main

# Stash changes
git stash

# Restore stashed changes
git stash pop

# View stash list
git stash list
```

### SQL Quick Reference

```sql
-- Create table
CREATE TABLE table_name (
    column_name TYPE CONSTRAINTS
);

-- Insert data
INSERT INTO table_name (col1, col2) VALUES (val1, val2);

-- Select data
SELECT col1, col2 FROM table_name WHERE condition;

-- Join tables
SELECT * FROM table1 
JOIN table2 ON table1.key = table2.key;

-- Create view
CREATE VIEW view_name AS SELECT ...;
```

### Docker Commands

```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# View running containers
docker ps

# View logs
docker logs container_name
```

---

*Last Updated: January 2026*  
*FRE 521D - UBC Master of Food and Resource Economics*
