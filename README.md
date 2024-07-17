# README

This is the web scraping API for  Y Combinator's publicly listed companies

This accepts POST request to ```/scrape``` URL with filters passed as JSON with the request body:

```
{
  "n": 10,
  "filters": {
    "batch": "W21",
    "industry": "Healthcare",
    "region": "United States",
    "tag": "Top Companies",
    "company_size": "1-10",
    "is_hiring": true,
    "nonprofit": false,
    "black_founded": true,
    "hispanic_latino_founded": false,
    "women_founded": true
  }
}
```