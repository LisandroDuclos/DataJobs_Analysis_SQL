/*
Question 2: What skills do the top-paying remote Data / BI Analyst jobs require?
- Reuse Query 1 as a CTE to get the 10 highest-paying remote jobs.
- Join the skills tables to list the skills each job asks for.
- One row per job, ordered by salary (highest first).
Why it matters: shows which skills the best-paid remote analyst roles
actually ask for, so you know what to learn first.
*/

WITH top_paying_jobs AS (
    -- Same logic as Query 1
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
    -- Puts all of a job's skills in one cell, sorted alphabetically
    STRING_AGG(sd.skills, ', ' ORDER BY sd.skills)  AS required_skills
FROM
    top_paying_jobs AS tpj
    -- LEFT JOINs keep jobs that list no skills (they show skill_count = 0)
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
