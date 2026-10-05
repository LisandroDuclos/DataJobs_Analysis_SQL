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
| 1 | Data Analyst | Mantys | $650,000 | 2023 |
| 2 | Director of Analytics | Meta | $336,500 | 2023 |
| 3 | Associate Director - Data Insights | AT&T | $255,830 | 2023 |
| 4 | Data Analyst, Marketing | Pinterest Job Advertisements | $232,423 | 2023 |
| 5 | Lead Business Intelligence Engineer | Noom | $220,000 | 2023 |
| 6 | Data Analyst (Hybrid/Remote) | Uclahealthcareers | $217,000 | 2023 |
| 7 | Principal Data Analyst (Remote) | SmartAsset | $205,000 | 2023 |
| 8 | Director, Data Analyst - HYBRID | Inclusively | $189,309 | 2023 |
| 9 | Principal Data Analyst, AV Performance Analysis | Motional | $189,000 | 2023 |
| 10 | Principal Data Analyst | SmartAsset | $186,000 | 2023 |

**Insights**
- **Wide salary range: $186K to $650K.** The #1 posting ($650K for a plain "Data Analyst" title) is almost **2x the next highest** and looks like an outlier or a data-entry error. Without it, the top 9 range from $186K to $336.5K, with a **median of $218.5K** for the top 10.
- **Seniority drives pay.** 7 of the 10 titles are senior or leadership roles (Director, Associate Director, Principal, Lead). The highest-paying analyst jobs are senior roles, not entry-level ones.
- **High pay is not limited to Big Tech.** Besides Meta and Pinterest, the list includes telecom (AT&T), healthcare (UCLA Health), fintech (SmartAsset), health tech (Noom) and autonomous vehicles (Motional). SmartAsset appears twice.
- **"Remote" is not always fully remote.** Two postings flagged as remote say "Hybrid" in the title, so the `job_work_from_home` flag should be read with care.

## 2. Skills Required by the Top-Paying Jobs
**Question:** What skills do the 10 top-paying remote Data / BI Analyst jobs ask for?

**Approach**
- Reused Query 1 as a **CTE** (`top_paying_jobs`) so both analyses use exactly the same 10 jobs.
- Joined the bridge table `skills_job_dim` and `skills_dim` to get skill names. Used `LEFT JOIN` so jobs with no listed skills are still shown.
- Used `STRING_AGG(... ORDER BY ...)` with `GROUP BY` to return **one row per job** with all its skills in one cell, plus `COUNT` for the number of skills.

```sql
WITH top_paying_jobs AS (
    SELECT
        jpf.job_id,
        jpf.job_title,
        cd.name             AS company_name,
        jpf.salary_year_avg
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
    LIMIT 10
)

SELECT
    tpj.job_id,
    tpj.job_title,
    tpj.company_name,
    tpj.salary_year_avg,
    COUNT(sd.skill_id)                              AS skill_count,
    STRING_AGG(sd.skills, ', ' ORDER BY sd.skills)  AS required_skills
FROM
    top_paying_jobs AS tpj
    LEFT JOIN skills_job_dim AS sjd
        ON tpj.job_id = sjd.job_id
    LEFT JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
GROUP BY
    tpj.job_id,
    tpj.job_title,
    tpj.company_name,
    tpj.salary_year_avg
ORDER BY
    tpj.salary_year_avg DESC;
```

**Results**

| # | Job Title | Company | Annual Salary | # Skills | Required Skills |
|---|---|---|---:|---:|---|
| 1 | Data Analyst | Mantys | $650,000 | 0 | — |
| 2 | Director of Analytics | Meta | $336,500 | 0 | — |
| 3 | Associate Director - Data Insights | AT&T | $255,830 | 13 | aws, azure, databricks, excel, jupyter, pandas, power bi, powerpoint, pyspark, python, r, sql, tableau |
| 4 | Data Analyst, Marketing | Pinterest Job Advertisements | $232,423 | 5 | hadoop, python, r, sql, tableau |
| 5 | Lead Business Intelligence Engineer | Noom | $220,000 | 6 | chef, excel, looker, python, sql, tableau |
| 6 | Data Analyst (Hybrid/Remote) | Uclahealthcareers | $217,000 | 5 | crystal, flow, oracle, sql, tableau |
| 7 | Principal Data Analyst (Remote) | SmartAsset | $205,000 | 9 | excel, gitlab, go, numpy, pandas, python, snowflake, sql, tableau |
| 8 | Director, Data Analyst - HYBRID | Inclusively | $189,309 | 14 | atlassian, aws, azure, bitbucket, confluence, jenkins, jira, oracle, power bi, python, sap, snowflake, sql, tableau |
| 9 | Principal Data Analyst, AV Performance Analysis | Motional | $189,000 | 8 | atlassian, bitbucket, confluence, git, jira, python, r, sql |
| 10 | Principal Data Analyst | SmartAsset | $186,000 | 9 | excel, gitlab, go, numpy, pandas, python, snowflake, sql, tableau |

**Most frequent skills** (across the 8 jobs that list skills)

| Skill | Jobs | Share |
|---|---:|---:|
| SQL | 8 | 100% |
| Python | 7 | 88% |
| Tableau | 7 | 88% |
| Excel | 4 | 50% |
| R | 3 | 38% |
| Pandas | 3 | 38% |
| Snowflake | 3 | 38% |

**Insights**
- **SQL is a must.** Every top-paying job that lists skills asks for SQL.
- **Python + Tableau are the next layer.** Both appear in 7 of 8 jobs. A profile with SQL, Python and a BI tool covers what almost all of these roles ask for. Tableau appears far more often than Power BI (7 vs. 2) and Looker (1).
- **Excel still matters at senior level.** Half of these jobs, all paying $186K or more, still list it.
- **Cloud and collaboration tools set senior roles apart.** Snowflake, AWS/Azure and Databricks, plus Git/Bitbucket and Jira/Confluence, show up in Director and Principal roles. These roles expect working inside an engineering team, not just doing analysis.
- **More skills does not mean more pay.** The 14-skill job pays $189K, while a 5-skill job pays $232K. Seniority (Query 1) explains salary better than the number of skills.

**Data quality notes**
- The 2 highest-paying jobs (Mantys and Meta) list **no skills**, so they don't contribute to the skill counts. This also supports treating the $650K posting as an outlier.
- Some tags look like keyword-matching errors (`chef`, `go`, `flow`, `crystal`). They may come from the job description text rather than real tool requirements.
- The two SmartAsset jobs list the same 9 skills (likely the same role posted twice), so their skills are counted twice.


