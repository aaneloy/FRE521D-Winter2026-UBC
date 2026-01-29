# FRE 521D: Supplementary Notes
## Lecture 4: ETL Pipeline II - The Real World of APIs

**Instructor:** Asif Ahmed Neloy  
**Program:** UBC Master of Food and Resource Economics

---

These notes cover practical API considerations that go beyond the basics covered in lecture.

---

## 1. The Two Timeouts You Must Understand

In lecture, we discussed retry logic. But before you can retry, you need to understand why requests fail. There are two distinct timeouts, and confusing them causes debugging nightmares.

### Connection Timeout vs Read Timeout

| Timeout Type | What It Means | Typical Cause |
|--------------|---------------|---------------|
| **Connection** | Could not establish connection to server | Server is down, network issues, wrong URL |
| **Read** | Connected but server took too long to respond | Server overloaded, query too complex |

### Setting Both Timeouts

```python
import requests

# BAD: Single timeout value
response = requests.get(url, timeout=30)  # Ambiguous

# GOOD: Explicit tuple (connection_timeout, read_timeout)
response = requests.get(url, timeout=(5, 30))
# 5 seconds to connect, 30 seconds to receive response
```

### Why This Matters

Imagine calling a climate data API that runs complex queries:
- Connection should be fast (5 seconds max)
- But generating 50 years of data might take 60 seconds

If you set a single 10-second timeout, you will never get large responses. If you set 60 seconds for everything, you will wait a full minute before discovering the server is down.

### Timeout Strategy by Use Case

| Scenario | Connection | Read | Reasoning |
|----------|------------|------|-----------|
| Quick lookups | 3s | 10s | Fast data, fast failure |
| Large queries | 5s | 120s | Complex server-side processing |
| Health checks | 2s | 5s | Just checking if alive |
| File downloads | 5s | 300s | Large data transfer |

---

## 2. The Session Pattern: Stop Creating New Connections

Every time you call `requests.get()`, Python creates a new TCP connection. For APIs you call repeatedly, this is wasteful.

### The Problem

```python
# INEFFICIENT: New connection each time
for country in countries:
    response = requests.get(f"{base_url}?country={country}")
    # Connection opened, data transferred, connection closed
    # Repeat 100+ times = slow
```

### The Solution: Session Objects

```python
# EFFICIENT: Reuse connections
session = requests.Session()
session.headers.update({'Authorization': 'Bearer YOUR_KEY'})

for country in countries:
    response = session.get(f"{base_url}?country={country}")
    # First call opens connection, subsequent calls reuse it
```

### Performance Comparison

For 100 API calls to the same server:
- Without session: ~15 seconds (connection overhead each time)
- With session: ~5 seconds (connection reused)

### Session Best Practices

```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def create_robust_session():
    """Create a session with retry logic and connection pooling."""
    session = requests.Session()
    
    # Configure retry strategy
    retry_strategy = Retry(
        total=3,
        backoff_factor=1,  # 1s, 2s, 4s delays
        status_forcelist=[429, 500, 502, 503, 504]
    )
    
    # Apply to both HTTP and HTTPS
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    
    return session

# Usage
session = create_robust_session()
response = session.get(url)  # Automatic retries built in
```

---

## 3. Understanding API Response Compression

Most APIs compress responses to reduce bandwidth. Your code might be ignoring this optimization.

### How It Works

```
Your Request:
  GET /data HTTP/1.1
  Accept-Encoding: gzip, deflate  <-- "I can handle compressed data"

Server Response:
  HTTP/1.1 200 OK
  Content-Encoding: gzip  <-- "Data is compressed"
  Content-Length: 1024    <-- Compressed size (original might be 10KB)
  [compressed bytes]
```

### The Good News

The `requests` library handles this automatically. But you should verify:

```python
response = requests.get(url)

# Check if compression was used
print(response.headers.get('Content-Encoding'))  # 'gzip' if compressed

# requests automatically decompresses
print(len(response.content))  # Decompressed size
```

### When Compression Matters

| Response Size | Without Compression | With Compression | Savings |
|---------------|--------------------|--------------------|---------|
| 1 KB | 1 KB | 0.8 KB | 20% |
| 100 KB | 100 KB | 15 KB | 85% |
| 1 MB | 1 MB | 100 KB | 90% |

For APIs returning JSON (highly compressible), you often see 80-90% size reduction.

### Forcing Compression

Some APIs only compress if you explicitly ask:

```python
headers = {
    'Accept-Encoding': 'gzip, deflate',
    'Accept': 'application/json'
}
response = requests.get(url, headers=headers)
```

---

## 4. The Circuit Breaker Pattern

Exponential backoff handles temporary failures. But what if an API is down for hours? You do not want to keep hammering it.

### The Problem with Pure Retry Logic

```
10:00 - API down, retry in 1s
10:00 - Fail, retry in 2s  
10:00 - Fail, retry in 4s
10:00 - Fail, retry in 8s
... continues for hours, wasting resources
```

### The Circuit Breaker Solution

Think of it like an electrical circuit breaker:
- **Closed:** Normal operation, requests flow through
- **Open:** Too many failures, reject requests immediately
- **Half-Open:** Test if service recovered

```python
import time
from datetime import datetime, timedelta

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures = 0
        self.last_failure_time = None
        self.state = 'CLOSED'
    
    def call(self, func, *args, **kwargs):
        if self.state == 'OPEN':
            if datetime.now() - self.last_failure_time > timedelta(seconds=self.recovery_timeout):
                self.state = 'HALF-OPEN'
            else:
                raise Exception("Circuit breaker is OPEN - API unavailable")
        
        try:
            result = func(*args, **kwargs)
            self.failures = 0
            self.state = 'CLOSED'
            return result
        except Exception as e:
            self.failures += 1
            self.last_failure_time = datetime.now()
            
            if self.failures >= self.failure_threshold:
                self.state = 'OPEN'
                print(f"Circuit breaker OPENED after {self.failures} failures")
            
            raise e

# Usage
breaker = CircuitBreaker(failure_threshold=3, recovery_timeout=300)

def fetch_data(url):
    return requests.get(url, timeout=(5, 30))

try:
    response = breaker.call(fetch_data, api_url)
except Exception as e:
    print(f"Request failed: {e}")
```

### When to Use Circuit Breakers

- Long-running ETL jobs that call external APIs
- Production systems where you need to fail fast
- When you have fallback data sources

---

## 5. Webhook vs Polling: Two Paradigms

In lecture, we focused on polling (you ask the API for data). But modern APIs often support webhooks (the API tells you when data is ready).

### Polling Pattern

```
You: "Any new data?"
API: "No"
You: "Any new data?"
API: "No"  
You: "Any new data?"
API: "Yes, here it is"
```

**Pros:** Simple, works everywhere
**Cons:** Wasteful, delays between polls

### Webhook Pattern

```
You: "Notify me at https://myserver.com/webhook when data changes"
API: "OK"
... time passes ...
API: "POST https://myserver.com/webhook {new_data}"
You: "Got it, thanks"
```

**Pros:** Real-time, efficient
**Cons:** Requires you to run a server, security considerations

### Practical Example: Data Availability Notifications

Some data providers (like statistics agencies) offer email or webhook notifications when new datasets are published. Instead of checking every hour:

```python
# Polling approach - check every hour
while True:
    response = requests.get(f"{api}/datasets/latest")
    if response.json()['updated'] > last_check:
        process_new_data(response.json())
        last_check = response.json()['updated']
    time.sleep(3600)  # Wait 1 hour
```

With webhooks, you only act when notified. For Assignment 2, we use polling because Open-Meteo does not support webhooks, but know that webhooks exist for production systems.

---

## 6. API Versioning: The Breaking Change Problem

APIs evolve. When they do, your pipeline can break.

### How APIs Handle Versions

| Method | Example | Pros | Cons |
|--------|---------|------|------|
| URL path | `/v1/data`, `/v2/data` | Explicit, clear | URL changes required |
| Query param | `/data?version=1` | Easy to change | Easy to forget |
| Header | `Accept: application/vnd.api+json;version=1` | Clean URLs | Hidden, complex |

### Protecting Your Pipeline

```python
API_VERSION = 'v2'
BASE_URL = f"https://api.example.com/{API_VERSION}"

def fetch_with_version_check(endpoint):
    response = requests.get(f"{BASE_URL}/{endpoint}")
    
    # Some APIs include version info in response
    api_version = response.headers.get('X-API-Version')
    if api_version and api_version != API_VERSION:
        print(f"WARNING: API version mismatch. Expected {API_VERSION}, got {api_version}")
    
    return response
```

### The Deprecation Warning

Good APIs warn you before breaking changes:

```python
response = requests.get(url)

# Check for deprecation warnings
if 'X-API-Deprecated' in response.headers:
    print(f"WARNING: This API endpoint is deprecated!")
    print(f"Sunset date: {response.headers.get('X-API-Sunset')}")
```

Always check API documentation for deprecation policies. Most give 6-12 months notice.

---

## 7. Handling Partial Failures in Batch Requests

When fetching data for 100 countries, what happens if 3 fail?

### The Naive Approach (Fragile)

```python
results = []
for country in countries:
    response = requests.get(f"{url}?country={country}")
    response.raise_for_status()  # Raises exception on any error
    results.append(response.json())
# If country #50 fails, you lose all progress
```

### The Robust Approach

```python
def fetch_with_partial_failure(countries, url):
    """Fetch data for multiple countries, handling partial failures."""
    results = {}
    failures = {}
    
    for country in countries:
        try:
            response = requests.get(f"{url}?country={country}", timeout=(5, 30))
            response.raise_for_status()
            results[country] = response.json()
        except requests.RequestException as e:
            failures[country] = str(e)
            print(f"Failed to fetch {country}: {e}")
    
    # Report summary
    print(f"Successfully fetched: {len(results)}/{len(countries)}")
    if failures:
        print(f"Failed countries: {list(failures.keys())}")
    
    return results, failures

# Usage
data, errors = fetch_with_partial_failure(countries, api_url)

# Decide what to do with partial results
if len(errors) / len(countries) > 0.1:  # More than 10% failed
    raise Exception("Too many failures, aborting pipeline")
else:
    # Proceed with available data, log failures for retry
    save_for_retry(errors)
```

### The Checkpoint Pattern

For very long jobs, save progress:

```python
import json

def fetch_with_checkpoints(countries, url, checkpoint_file='checkpoint.json'):
    # Load checkpoint if exists
    try:
        with open(checkpoint_file, 'r') as f:
            checkpoint = json.load(f)
        results = checkpoint.get('results', {})
        completed = set(checkpoint.get('completed', []))
    except FileNotFoundError:
        results = {}
        completed = set()
    
    for country in countries:
        if country in completed:
            continue  # Skip already fetched
        
        try:
            response = requests.get(f"{url}?country={country}")
            results[country] = response.json()
            completed.add(country)
            
            # Save checkpoint every 10 countries
            if len(completed) % 10 == 0:
                with open(checkpoint_file, 'w') as f:
                    json.dump({'results': results, 'completed': list(completed)}, f)
                print(f"Checkpoint saved: {len(completed)}/{len(countries)}")
                
        except Exception as e:
            print(f"Failed {country}: {e}")
    
    return results
```

If your job crashes after fetching 80 countries, you can restart and it will skip the 80 already done.

---

## 8. The Hidden Cost of JSON Parsing

For large API responses, JSON parsing can be slow.

### The Problem

```python
response = requests.get(url)
data = response.json()  # This can be slow for large responses
```

For a 50 MB JSON response, parsing might take 5-10 seconds.

### Streaming for Large Responses

```python
import ijson  # Streaming JSON parser

def stream_large_json(url):
    """Process large JSON without loading entirely into memory."""
    response = requests.get(url, stream=True)
    
    # Parse items one at a time
    for item in ijson.items(response.raw, 'data.item'):
        yield item  # Process one item at a time

# Usage
for record in stream_large_json(api_url):
    process_record(record)
```

### When to Use Streaming

| Response Size | Approach |
|---------------|----------|
| < 10 MB | Normal `response.json()` |
| 10-100 MB | Consider streaming |
| > 100 MB | Definitely stream |

---

## Summary: The API Mindset

When working with APIs, always consider:

1. **Timeouts:** Set both connection and read timeouts appropriately
2. **Sessions:** Reuse connections for multiple requests to same server
3. **Failures:** Plan for partial failures, not just complete success or failure
4. **Versions:** Track API versions and watch for deprecation warnings
5. **Scale:** Use streaming for large responses, checkpoints for long jobs
6. **Resilience:** Implement circuit breakers for production systems

The difference between a junior and senior data engineer is not knowing how to call an API. It is knowing how to call an API reliably at 3 AM when you are asleep and the API is having a bad day.

---

## Practice Exercise

Enhance your Assignment 2 pipeline with:
1. A session object that persists across all API calls
2. Explicit connection and read timeouts
3. A checkpoint system that saves progress every 10 countries
4. A summary report of successes and failures at the end

These patterns will serve you well in any data engineering role.
