# Introduction
📊 This project explores the data job market through advanced SQL analysis, aiming to answer a key question: which roles and skills offer the best opportunities? It examines role demand, salaries, work arrangements (remote, on-site, hybrid), and the most in-demand and highest-paying skills for each position.

🔍 SQL queries: [Project_Queries](Project_Queries/)

# Background
The data job market is crowded and fast-moving, so it's hard to know which skills to learn first. This project uses real 2023 job postings to find the roles and skills that pay best and are most in demand, so you can make that choice based on data.

# The Analysis

## 1. Top-Paying Remote Data / BI Analyst Jobs
**Question:** Which remote Data Analyst / BI Analyst jobs pay the most?

**Approach**
- Filtered remote postings with `job_work_from_home = TRUE`.
- Included `Data Analyst` roles plus BI titles. The dataset has no dedicated BI category, so BI roles were matched by title with `ILIKE`.
- Excluded postings without an annual salary (`salary_year_avg IS NOT NULL`).
- Used a `LEFT JOIN` to `company_dim` to show the hiring company without dropping postings that have no company match.

```sql
SELECT
    jpf.job_id,
    jpf.job_title,
    jpf.job_location,
    cd.name                    AS company_name,
    jpf.salary_year_avg,
    jpf.job_posted_date::DATE  AS job_posted_date
FROM
    job_postings_fact AS jpf
    LEFT JOIN company_dim AS cd
        ON jpf.company_id = cd.company_id
WHERE
    (
        jpf.job_title_short = 'Data Analyst'
        OR jpf.job_title ILIKE '%business intelligence%'
        OR jpf.job_title ILIKE '%BI analyst%'
    )
    AND jpf.job_work_from_home = TRUE
    AND jpf.salary_year_avg IS NOT NULL
ORDER BY
    jpf.salary_year_avg DESC
LIMIT 10;
```

**Results**

| # | Job Title | Company | Annual Salary | Posted |
|---|---|---|---:|---|
| 1 | Data Analyst | Mantys | $650,000 | 2023-02-20 |
| 2 | Director of Analytics | Meta | $336,500 | 2023-08-23 |
| 3 | Associate Director - Data Insights | AT&T | $255,830 | 2023-06-18 |
| 4 | Data Analyst, Marketing | Pinterest Job Advertisements | $232,423 | 2023-12-05 |
| 5 | Lead Business Intelligence Engineer | Noom | $220,000 | 2023-08-29 |
| 6 | Data Analyst (Hybrid/Remote) | Uclahealthcareers | $217,000 | 2023-01-17 |
| 7 | Principal Data Analyst (Remote) | SmartAsset | $205,000 | 2023-08-09 |
| 8 | Director, Data Analyst - HYBRID | Inclusively | $189,309 | 2023-12-07 |
| 9 | Principal Data Analyst, AV Performance Analysis | Motional | $189,000 | 2023-01-05 |
| 10 | Principal Data Analyst | SmartAsset | $186,000 | 2023-07-11 |

**Insights**
- **Wide salary range: $186K to $650K.** The #1 posting ($650K for a plain "Data Analyst" title) is almost **2x the next highest** and looks like an outlier or a data-entry error. Without it, the top 9 range from $186K to $336.5K, with a **median of $218.5K** for the top 10.
- **Seniority drives pay.** 7 of the 10 titles are senior or leadership roles (Director, Associate Director, Principal, Lead). The highest-paying analyst jobs are senior roles, not entry-level ones.
- **High pay is not limited to Big Tech.** Besides Meta and Pinterest, the list includes telecom (AT&T), healthcare (UCLA Health), fintech (SmartAsset), health tech (Noom) and autonomous vehicles (Motional). SmartAsset appears twice.
- **"Remote" is not always fully remote.** Two postings flagged as remote say "Hybrid" in the title, so the `job_work_from_home` flag should be read with care.


