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

```

2. Which log_date value had the most duplicate records after removing the max duplicate id value from question 1?

```sql

```

3. Which measure_value had the most occurences in the health.user_logs value when measure = 'weight'?

```sql

```

4. How many single duplicated rows exist when measure = 'blood_pressure' in the health.user_logs? How about the total number of duplicate records in the same table?

```sql

```

5. What percentage of records measure_value = 0 when measure = 'blood_pressure' in the health.user_logs table? How many records are there also for this same condition?

```sql

```

6. What percentage of records are duplicates in the health.user_logs table?

```sql

```
