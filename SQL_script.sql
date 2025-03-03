-- Tvorba prvního datasetu
CREATE TABLE t_Martina_Kudelova_project_SQL_primary_final AS
    SELECT 
        cpay.payroll_year AS year,
        cpib.name AS industry,
        AVG(cpay.value) AS avg_salary,
        cpc.name AS food,
        AVG(cpr.value) AS avg_price
    FROM czechia_payroll cpay
    FULL OUTER JOIN czechia_price cpr 
        ON cpay.payroll_year = date_part('year', cpr.date_from)
    LEFT JOIN czechia_payroll_industry_branch cpib 
        ON cpay.industry_branch_code = cpib.code
    LEFT JOIN czechia_price_category cpc 
        ON cpr.category_code = cpc.code
    WHERE cpay.value_type_code = 5958
    GROUP BY 
        cpay.payroll_year,
        cpib.name,
        cpc.name
ORDER BY year;



-- Tvorba druhého datasetu
CREATE TABLE t_Martina_Kudelova_project_SQL_secondary_final AS
    SELECT 
        country,
        YEAR,
        gdp,
        population,
        gini
    FROM economies
    WHERE YEAR IN (
    	SELECT
    		year
    	FROM t_Martina_Kudelova_project_SQL_primary_final
    		)
    ORDER BY country, year;




---------------------------------------- 1. otázka
-- Tvorba temp tabulky
CREATE TEMP TABLE temp_question_1 AS
    SELECT 
    	average_salaries.industry,  
    	average_salaries.year,
    	average_salaries.avg_salary,
        LAG(average_salaries.avg_salary) OVER (PARTITION BY average_salaries.industry ORDER BY average_salaries.year) AS prev_year_salary,
        CASE
            WHEN LAG(average_salaries.avg_salary) OVER (PARTITION BY average_salaries.industry ORDER BY average_salaries.year) > average_salaries.avg_salary THEN 'Decreased'
            WHEN LAG(average_salaries.avg_salary) OVER (PARTITION BY average_salaries.industry ORDER BY average_salaries.year) < average_salaries.avg_salary THEN 'Increased'
            ELSE 'Same'
        END AS salary_change
    FROM (
        SELECT 
            industry,
            year,
            AVG(avg_salary) AS avg_salary
        FROM t_Martina_Kudelova_project_SQL_primary_final
        GROUP BY 
            industry,
            year
    ) AS average_salaries
    ORDER BY year ASC;

-- Temp tabulka Select a DROP
SELECT *
FROM temp_question_1
-- DROP TABLE IF EXISTS temp_otazka_1

-- Počet odvětví a časové rozmezí
SELECT 
    COUNT(DISTINCT industry) AS industry_count, 
    MIN(year) AS first_year,
    MAX(year) AS last_year
FROM temp_question_1;

-- Roky, v kterých se nejčastěji snižovaly mzdy
SELECT year, count(industry) AS industry_count
FROM temp_question_1
WHERE salary_change = 'Decreased'
GROUP BY year
ORDER BY industry_count DESC;

-- Odvětví, kterým se nejčastěji snižovaly mzdy, mimo rok 2013
SELECT industry, COUNT(*) AS occurrences
FROM temp_question_1
WHERE salary_change = 'Decreased'
AND year != '2013'
GROUP BY industry
ORDER BY occurrences DESC, industry;

-- Odvětví, kterým v roce 2013 mzdy neklesly 
SELECT industry
FROM temp_question_1
WHERE year = '2013'
AND salary_change = 'Increased'
ORDER BY industry;

-- Odvětví, kterým mzdy neklesly v roce 2013 a zároveň ani v roce 2021
SELECT industry
FROM (
    SELECT industry 
    FROM temp_question_1
    WHERE year = '2013'
      AND salary_change = 'Increased'
    INTERSECT
    SELECT industry 
    FROM temp_question_1
    WHERE year = '2021'
      AND salary_change = 'Increased'
)
ORDER BY industry;

-- Odvětví, kterým mzdy pouze rostly
SELECT industry
FROM temp_question_1
GROUP BY industry
HAVING COUNT(CASE WHEN salary_change = 'Decreased' THEN 1 END) = 0
ORDER BY industry;




---------------------------------------- 2. otázka
-- Přesná jména potravin
SELECT food 
FROM t_Martina_Kudelova_project_SQL_primary_final
WHERE food ILIKE '%chléb%' OR food ILIKE '%chleba%' OR food ILIKE '%mléko%'
GROUP BY food;

-- Společný nejnižší a nejvyšší rok a počet kilogramů chleba nebo počet litrů mléka, které lze koupit za mzdy v těchto letech
SELECT 
    year,
    FLOOR(AVG(CASE WHEN food = 'Chléb konzumní kmínový' THEN avg_year_salary / avg_year_price END)) AS bread,
    FLOOR(AVG(CASE WHEN food = 'Mléko polotučné pasterované' THEN avg_year_salary / avg_year_price END)) AS milk
FROM (
    SELECT 
        year,
        food,
        AVG(avg_salary) AS avg_year_salary,
        AVG(avg_price) AS avg_year_price
    FROM t_Martina_Kudelova_project_SQL_primary_final
    WHERE food IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
      AND avg_salary IS NOT NULL 
    GROUP BY year, food
) AS yearly_data
WHERE year IN (
    SELECT MIN(year) 
    FROM t_Martina_Kudelova_project_SQL_primary_final
    WHERE food IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
      AND avg_salary IS NOT NULL 
    UNION
    SELECT MAX(year) 
    FROM t_Martina_Kudelova_project_SQL_primary_final
    WHERE food IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
      AND avg_salary IS NOT NULL 
)
GROUP BY year
ORDER BY year;




---------------------------------------- 3. otázka
-- Celkový trend
WITH price_changes AS (
	SELECT
		food,
		year,
		((avg(avg_price) - LAG(avg(avg_price)) OVER (PARTITION BY food ORDER BY year)) / LAG(avg(avg_price)) OVER (PARTITION BY food ORDER BY year)) * 100 AS percentage_growth
	FROM t_Martina_Kudelova_project_SQL_primary_final
	GROUP BY food, year
)
SELECT
    food,
    SUM(percentage_growth) AS total_percentage_growth
FROM price_changes
GROUP BY food
ORDER BY total_percentage_growth ASC;





---------------------------------------- 4. otázka
-- Roky, kde byl meziroční nárůst cen o 10% vyšší než meziroční nárůst mezd
WITH yearly_data AS (
    SELECT 
        year,
        AVG(avg_price) AS avg_price,
        AVG(avg_salary) AS avg_salary
    FROM t_Martina_Kudelova_project_SQL_primary_final
    WHERE food IS NOT NULL AND industry IS NOT NULL
    GROUP BY year
),
percent_changes AS (
    SELECT 
        year,
        ((avg_price - LAG(avg_price) OVER (ORDER BY year)) / 
          LAG(avg_price) OVER (ORDER BY year)) * 100 AS price_growth,
        ((avg_salary - LAG(avg_salary) OVER (ORDER BY year)) / 
          LAG(avg_salary) OVER (ORDER BY year)) * 100 AS wage_growth,
        (
            (
                (avg_price - LAG(avg_price) OVER (ORDER BY year)) / 
                 LAG(avg_price) OVER (ORDER BY year)
            ) - 
            (
                (avg_salary - LAG(avg_salary) OVER (ORDER BY year)) / 
                 LAG(avg_salary) OVER (ORDER BY year)
            )
        ) * 100 AS growth_difference
    FROM yearly_data
)
SELECT *
FROM percent_changes
WHERE growth_difference > 10
ORDER BY growth_difference DESC;

--  Výsledky pro kontrolu
WITH yearly_data AS (
    SELECT 
        year,
        AVG(avg_price) AS avg_price,
        AVG(avg_salary) AS avg_salary
    FROM t_Martina_Kudelova_project_SQL_primary_final
    WHERE food IS NOT NULL AND industry IS NOT NULL
    GROUP BY year
)
SELECT 
    year,
    ((avg_price - LAG(avg_price) OVER (ORDER BY year)) / 
      LAG(avg_price) OVER (ORDER BY year)) * 100 AS price_growth,
    ((avg_salary - LAG(avg_salary) OVER (ORDER BY year)) / 
      LAG(avg_salary) OVER (ORDER BY year)) * 100 AS wage_growth,
    (
        (
            (avg_price - LAG(avg_price) OVER (ORDER BY year)) / 
             LAG(avg_price) OVER (ORDER BY year)
        ) - 
        (
            (avg_salary - LAG(avg_salary) OVER (ORDER BY year)) / 
             LAG(avg_salary) OVER (ORDER BY year)
        )
    ) * 100 AS growth_difference
FROM yearly_data
ORDER BY growth_difference DESC;





---------------------------------------- 5. otázka
-- Příprava na úpravu datasetu
SELECT country, YEAR, avg(GDP)
FROM economies
WHERE
	country IN ('Czechia', 'Czech Republic', 'Česko', 'Česká republika')
	AND GDP IS NOT null
GROUP BY YEAR, country
ORDER BY YEAR;

-- Vložení prázdného sloupce
ALTER TABLE t_Martina_Kudelova_project_SQL_primary_final 
ADD COLUMN GDP NUMERIC;

-- Vložení dat do datasetu
UPDATE t_Martina_Kudelova_project_SQL_primary_final AS t
SET GDP = e.GDP
FROM (
    SELECT YEAR, AVG(GDP) AS GDP
    FROM economies
    WHERE country = 'Czech Republic'
    AND GDP IS NOT NULL
    GROUP BY year
) AS e
WHERE t.year = e.year;

-- Updatovaný dataset
SELECT *
FROM t_Martina_Kudelova_project_SQL_primary_final; 

-- Meziroční nárůsty HDP, cen a mezd
WITH yearly_data AS (
    SELECT 
        year,
        GDP,
        AVG(avg_price) AS avg_price,
        AVG(avg_salary) AS avg_salary
    FROM t_Martina_Kudelova_project_SQL_primary_final
    WHERE food IS NOT NULL AND industry IS NOT NULL
    GROUP BY year, GDP
),
percent_changes AS (
    SELECT 
        year,
        GDP,
        ((GDP - LAG(GDP) OVER (ORDER BY year)) / 
          LAG(GDP) OVER (ORDER BY year)) * 100 AS GDP_growth,
        ((avg_price - LAG(avg_price) OVER (ORDER BY year)) / 
          LAG(avg_price) OVER (ORDER BY year)) * 100 AS price_growth,
        ((avg_salary - LAG(avg_salary) OVER (ORDER BY year)) / 
          LAG(avg_salary) OVER (ORDER BY year)) * 100 AS wage_growth
    FROM yearly_data
)
SELECT *
FROM percent_changes;

