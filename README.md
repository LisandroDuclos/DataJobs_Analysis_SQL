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

## 3. Demand and Salary of the 3 Main Data Roles
**Question:** How do Data Analyst, Data Engineer and Data Scientist compare in demand and pay across the whole market (remote and on-site)?

**Approach**
- Filtered the 3 roles with `IN` and grouped by `job_title_short`.
- Measured demand with `COUNT(*)` over all postings.
- Used `COUNT(salary_year_avg)` to show how many postings the salary figures are based on. `AVG` skips `NULL`s, so there was no need for a filter that would also have reduced the demand count.
- Added the **median** with `PERCENTILE_CONT(0.5) WITHIN GROUP (...)`, which outliers like the $650K posting from Query 1 can't push up.

```sql
SELECT
    job_title_short                                 AS job_role,
    COUNT(*)                                        AS demand_count,
    COUNT(salary_year_avg)                          AS postings_with_salary,
    ROUND(AVG(salary_year_avg), 0)                  AS avg_salary,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_year_avg)::NUMERIC,
        0
    )                                               AS median_salary
FROM
    job_postings_fact
WHERE
    job_title_short IN ('Data Analyst', 'Data Engineer', 'Data Scientist')
GROUP BY
    job_title_short
ORDER BY
    demand_count DESC;
```

**Results**

| Role | Postings (Demand) | Share of Demand | Postings with Salary | Avg Salary | Median Salary |
|---|---:|---:|---:|---:|---:|
| Data Analyst | 196,593 | 35.4% | 5,463 | $93,876 | $90,000 |
| Data Engineer | 186,679 | 33.6% | 4,509 | $130,267 | $125,000 |
| Data Scientist | 172,726 | 31.1% | 5,926 | $135,929 | $127,500 |

*Share of demand is calculated over the 555,998 postings for these 3 roles.*

**Insights**
- **Demand is high for all 3 roles.** Demand is spread almost evenly (35% / 34% / 31%). Data Analyst leads with about 24K more postings than Data Scientist (+14%).
- **Higher demand does not mean higher pay.** The order by demand is the opposite of the order by salary. Data Analyst has the most openings but the lowest pay, and Data Scientist has the fewest openings but the highest pay.
- **There is a large pay gap between analysts and the other two roles.** Data Scientists earn **~45% more** than Data Analysts on average ($135.9K vs. $93.9K), and Data Engineers **~39% more** ($130.3K). Engineers and Scientists are close to each other (about 4% apart).
- **Data Engineer has the best balance of demand and pay.** It has the 2nd-highest demand and pays only $2.5K less than Data Scientist at the median.
- **A few high salaries pull the averages up.** The average is above the median for all 3 roles, by the most for Data Scientist (+$8.4K). That means a small number of very high salaries pull the average up, so the median is the more realistic number to expect.
- **The top of the market pays much more than a typical job.** The top-10 remote analyst salaries from Query 1 ($186K+) are about **2x the Data Analyst median** ($90K).

**Data quality notes**
- Only **~3% of postings include a salary** (2.4%–3.4% depending on the role). Salary numbers are based on 4.5K–5.9K postings per role, which is still a solid sample but may not represent every posting.

# Conclusions

### What the data says
1. **Data Analyst is the easiest way into the field.** It is the most in-demand role (196K postings), so it has the most openings for people starting out.
2. **Seniority and role path drive salary.** Moving from Analyst to Principal or Director level (Query 1), or to Data Engineering or Data Science (Query 3), is where the biggest salary increases are, up to roughly +40% at the median.
3. **SQL is the foundation.** It appeared in **100%** of the top-paying jobs that list skills. **Python** and **Tableau** follow (88% each).
4. **Senior roles go beyond analysis.** The best-paid jobs add cloud data platforms (Snowflake, AWS, Azure, Databricks) and engineering tools (Git, Jira).
5. **Remote analyst jobs can pay at senior level.** Remote Data Analyst / BI roles reached $186K–$336K, excluding the outlier.

### A learning path based on these results
**SQL → Excel + Tableau / Power BI → Python (pandas) → a cloud warehouse (Snowflake / AWS / Azure) → Git**

This path covers the requirements of an entry-level Data Analyst role and builds toward the skills that the highest-paying analyst roles ask for, or toward a move into Data Engineering.

### SQL techniques used
- `JOIN`s on a star schema, including a many-to-many **bridge table**, with `LEFT JOIN` used on purpose to avoid losing rows
- **CTEs** to reuse one query's logic in another
- Aggregations: `COUNT`, `AVG`, `GROUP BY`, `STRING_AGG(... ORDER BY ...)`
- Statistical functions: `PERCENTILE_CONT ... WITHIN GROUP` for medians
- Text filters with `ILIKE` and `IN`, type casting with `::`, and `NULL` handling

### Limitations
- Salary is reported in only ~3% of postings, and some values look like outliers (e.g., $650K).
- Skill tags come from keyword matching and include some noise (`chef`, `go`).
- The `job_work_from_home` flag includes some hybrid postings.
- Data covers 2023 postings, so current market conditions may differ.


