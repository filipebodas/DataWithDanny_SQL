## SELECT & SORT DATA - Exercises

1. What is the name of the category with the highest category_id in the dvd_rentals.category table?

```sql
SELECT
  name,
  category_id
FROM
  dvd_rentals.category
ORDER BY
  category_id DESC;
```

2. For the films with the longest length, what is the title of the “R” rated film with the lowest replacement_cost in dvd_rentals.film table?

```sql
SELECT
  title,
  rating,
  length,
  replacement_cost
FROM
  dvd_rentals.film
WHERE
  rating = 'R'
ORDER BY
  length DESC,
  replacement_cost ASC
LIMIT 1;
```

3. Who was the manager of the store with the highest total_sales in the dvd_rentals.sales_by_store table?

```sql
SELECT
  manager,
  total_sales
FROM
  dvd_rentals.sales_by_store
ORDER BY 
  total_sales DESC
LIMIT 1;
```

4. What is the postal_code of the city with the 5th highest city_id in the dvd_rentals.address table?

```sql
WITH city_rank AS (
  SELECT
    postal_code,
    city_id,
    DENSE_RANK() OVER(
      ORDER BY
        city_id DESC
    ) id_rank
  FROM
    dvd_rentals.address
)
SELECT
  postal_code,
  city_id,
  id_rank
FROM
  city_rank
WHERE
  id_rank = 5;
```


## RECORD COUNT & DISTINCT VALUES - Exercises

1. Which actor_id has the most number of unique film_id records in the dvd_rentals.film_actor table?

```sql
SELECT
  actor_id,
  COUNT (DISTINCT film_id) AS nr_films
FROM
  dvd_rentals.film_actor
GROUP BY
  actor_id
ORDER BY
  2 DESC
LIMIT 1;
```

2. How many distinct fid values are there for the 3rd most common price value in the dvd_rentals.nicer_but_slower_film_list table?

```sql
SELECT
  price,
  COUNT(DISTINCT fid) as nr_fid
FROM
  dvd_rentals.nicer_but_slower_film_list
GROUP BY
  price
ORDER BY
  2 DESC;
```

3. How many unique country_id values exist in the dvd_rentals.city table?

```sql
SELECT
  COUNT (DISTINCT country_id) as unique_country_ids
FROM
  dvd_rentals.city;
```

4. What percentage of overall total_sales does the Sports category make up in the dvd_rentals.sales_by_film_category table?

```sql
WITH sales_perc AS (
  SELECT
    category,
    ROUND(
      100 * total_sales::NUMERIC / SUM(total_sales) OVER (),
      2
    ) as sales_percentage
  FROM
    dvd_rentals.sales_by_film_category
)
SELECT
  category,
  sales_percentage
FROM
  sales_perc
WHERE
  category = 'Sports';
```

+ When you divide an INT data type with another INT data type - the SQL engine automatically returns you the floor division!
+ So how do we get around this? Simply cast either the top or the bottom of the division terms as a NUMERIC data type and you’re set. The shortened form of casting a column or a value is column_name::<new-data-type> or the long form is CAST(column_name AS <new-data-type>)

[**Notes taken from Danny's SeriousSQL Course**](https://www.datawithdanny.com/)


5. What percentage of unique fid values are in the Children category in the dvd_rentals.film_list table? 

```sql
SELECT 
  category,
  COUNT (DISTINCT fid) AS unique_fid_per_category,
  SUM (COUNT (DISTINCT fid)) OVER() AS total_unique_fids ,
  ROUND (
    100 * COUNT (DISTINCT fid)::NUMERIC
    / 
    SUM (COUNT (DISTINCT fid)) OVER(),
  2) AS percentage_fid_per_category
FROM 
  dvd_rentals.film_list
GROUP BY 
  category;
```


## IDENTIFYING DUPLICATE RECORDS - Exercises

1. Which id value has the most number of duplicate records in the health.user_logs table?

```sql
WITH logs_counts AS (
/*Use a CTE to see how many times a unique row appears in the dataset*/
  SELECT 
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM 
    health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
  )
SELECT 
  id,
  SUM (frequency) AS nr_logs
FROM 
  logs_counts
WHERE 
  frequency > 1 
/*filters the logs that are duplicates before grouped them and sum their frequency*/
GROUP BY
  id
ORDER BY 
  nr_logs DESC;
```

2. Which log_date value had the most duplicate records after removing the max duplicate id value from question 1?

```sql
WITH logs_counts AS (
--How many times a unique row appears in the dataset
  SELECT 
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM 
    health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
  ),
--Retrieve the id with the most number of duplicates
max_id AS (
  SELECT 
    id,
    SUM (frequency) AS nr_logs
  FROM 
    logs_counts
  WHERE 
    frequency > 1 
  --filters the logs that are duplicates before grouped them and sum their frequency
  GROUP BY
    id
  ORDER BY 
    nr_logs DESC
  LIMIT 1
  )
/*
Aggregate by log_date excluding the id with most duplicated logs
*/
SELECT 
  log_date,
  SUM (frequency) AS nr_logs
FROM
  logs_counts
WHERE 
  frequency > 1
  AND id NOT IN (
              SELECT
                id
              FROM max_id
              )
GROUP BY 
  log_date
ORDER BY
  nr_logs DESC;
```

3. Which measure_value had the most occurences in the health.user_logs value when measure = 'weight'?

```sql
SELECT
  measure_value,
  COUNT (*) AS frequency
FROM
  health.user_logs
WHERE
  measure = 'weight'
GROUP BY
  measure_value
ORDER BY
  frequency DESC;
```

4. How many single duplicated rows exist when measure = 'blood_pressure' in the health.user_logs? How about the total number of duplicate records in the same table?

```sql
WITH logs_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM 
    health.user_logs
  WHERE 
    measure = 'blood_pressure'
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT 
  COUNT (*) AS unique_records,
  SUM (frequency) AS total_duplicated_records
FROM 
  logs_counts
WHERE 
  frequency > 1;
```

5. What percentage of records measure_value = 0 when measure = 'blood_pressure' in the health.user_logs table? How many records are there also for this same condition?

```sql
SELECT
  measure_value,
  COUNT (*) AS frequency,
  SUM (COUNT (*)) OVER() AS total_frequency,
  ROUND (
    100 * COUNT (*)::NUMERIC / 
    SUM (COUNT (*)) OVER(),
    2) AS percentage
FROM
  health.user_logs
WHERE
  measure = 'blood_pressure'
GROUP BY
  measure_value
ORDER BY 
  frequency DESC;
```

**OR**

```sql
WITH frequency_table AS (
  SELECT
    measure_value,
    COUNT (*) AS frequency,
    SUM (COUNT (*)) OVER() AS total_frequency
  FROM
    health.user_logs
  WHERE
    measure = 'blood_pressure'
  GROUP BY
    measure_value
  )
SELECT 
  measure_value,
  frequency,
  total_frequency,
  ROUND (
    100 * frequency::NUMERIC /
    total_frequency,
    2) AS percentage
FROM
  frequency_table
WHERE
  measure_value = 0;
```



6. What percentage of records are duplicates in the health.user_logs table?

```sql
WITH logs_counts AS (
  SELECT
    id,
    measure,
    measure_value,
    log_date,
    diastolic,
    systolic,
    COUNT (*) AS frequency
  FROM
    health.user_logs
  GROUP BY
    id,
    measure,
    measure_value,
    log_date,
    diastolic,
    systolic
  )
SELECT 
  SUM (CASE
    WHEN frequency > 1 THEN frequency - 1 -- this counts which ones are in fact duplicates
    ELSE 0 -- it is a unique log
      END) AS number_of_duplicates,
  SUM (frequency) as total_logs,
  ROUND (
    100 * SUM (CASE
            WHEN frequency > 1 THEN frequency - 1 -- this counts which ones are in fact duplicates
            ELSE 0 -- it is a unique log
              END)::NUMERIC /
          SUM (frequency),
    2
  ) AS duplicates_percentage
FROM 
  logs_counts;
```

**OR**

```sql
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT
  ROUND(
    100 * (
      (SELECT COUNT(*) FROM health.user_logs) -
      (SELECT COUNT(*) FROM deduped_logs)
    )::NUMERIC /
    (SELECT COUNT(*) FROM health.user_logs),
    2
  ) AS duplicate_percentage;
```