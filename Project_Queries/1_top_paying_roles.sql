/*
Question 1: What are the top-paying remote Data Analyst / BI Analyst jobs?
- Keep only remote postings (job_work_from_home = TRUE).
- Include Data Analyst roles plus Business Intelligence (BI) analyst titles.
- Keep only postings with an annual salary (salary_year_avg IS NOT NULL).
- Return the 10 highest-paying jobs.
Why it matters: shows the salary ceiling for remote analyst roles and which
companies are paying it.
*/

SELECT
    jpf.job_id,
    jpf.job_title,
    jpf.job_location,
    cd.name                    AS company_name,
    jpf.salary_year_avg,
    jpf.job_posted_date::DATE  AS job_posted_date
FROM
    job_postings_fact AS jpf
    -- LEFT JOIN keeps the posting even if its company is missing from company_dim
    LEFT JOIN company_dim AS cd
        ON jpf.company_id = cd.company_id
WHERE
    (
        jpf.job_title_short = 'Data Analyst'
        -- BI roles have no dedicated job_title_short, so they are matched by title
        OR jpf.job_title ILIKE '%business intelligence%'
        OR jpf.job_title ILIKE '%BI analyst%'
    )
    AND jpf.job_work_from_home = TRUE
    AND jpf.salary_year_avg IS NOT NULL
ORDER BY
    jpf.salary_year_avg DESC
LIMIT 10;
