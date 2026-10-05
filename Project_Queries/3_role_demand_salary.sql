/*
Question 3: How do the 3 main data roles compare in demand and salary?
- Roles: Data Analyst, Data Engineer, Data Scientist.
- Demand = number of job postings per role (all postings, remote or not).
- Salary = average annual salary, using only postings that include one.
- Ordered by demand (most postings first).
Why it matters: shows which role has the most openings and how pay changes
between the three paths.
*/

SELECT
    job_title_short                                 AS job_role,
    COUNT(*)                                        AS demand_count,
    -- How many postings the salary figures are based on
    COUNT(salary_year_avg)                          AS postings_with_salary,
    -- AVG ignores NULLs, so only postings with a salary are averaged
    ROUND(AVG(salary_year_avg), 0)                  AS avg_salary,
    -- Median is less affected by extreme salaries (like the $650K outlier in Query 1)
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
