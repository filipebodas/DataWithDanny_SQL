## RECORD COUNTS AND NULL VALUES ANALYSIS

Common analysis 
  + **total number of records**
  + **total unique ids**

```sql
SELECT
  COUNT (*) as count_rows,
  COUNT (DISTINCT id) as unique_ids
FROM
  health.user_logs;
```
|count_records|unique_ids|
|---|---|
|43891|554|


**Check the frequency for individual columns; total frequency and percentage:** 
+ measure
+ measure_value
+ systolic
+ diastolic

```sql
SELECT
  measure,
  COUNT (*) AS frequency,
  SUM (COUNT (*)) OVER () AS total_frequency,
  ROUND (
    100 * COUNT (*) / SUM (COUNT (*)) OVER (),
    2
  ) AS frequency_percentage
FROM
  health.user_logs
GROUP BY
  measure
ORDER BY
  2 DESC;
```
|measure|frequency|total_frequency|frequency_percentage|
|---|---|---|---|
|blood_glucose|38692|43891|88.15|
|weight|2782|43891|6.34|
|blood_pressure|2417|43891|5.51|


```sql
SELECT
  measure_value,
  COUNT(*) AS frequency
FROM
  health.user_logs
GROUP BY
  1
ORDER BY
  2 DESC;
```
|measure_value|frequency|
|---|---|
|**0**|**572**|
|401|433|
|117|390|
|118|346|
|123|342|
|122|331|
|126|326|
|120|323|
|128|319|
|115|319|

```sql
SELECT
  systolic,
  COUNT(*) AS frequency
FROM
  health.user_logs
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT 10  ;
```
|systolic|frequency|
|---|---|
|**null**|**26023**|
|**0**|**15451**|
|120|71|
|123|70|
|128|66|
|127|64|
|130|60|
|119|60|
|135|57|
|124|55|


```sql
SELECT
  diastolic,
  COUNT(*) AS frequency
FROM
  health.user_logs
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT 10;
```
|diastolic|frequency|
|---|---|
|**null**|**26023**|
|**0**|**15449**|
|80|156|
|79|124|
|81|119|
|78|110|
|77|109|
|73|109|
|83|106|
|76|102|

Use the ```WHERE``` clause to see what happens to the ```measure``` column when ```measure_value = 0``` and ```systolic IS NULL``` and ```diastolic IS NULL``` 

```sql
SELECT
  measure,
  COUNT(*) AS frequency
FROM
  health.user_logs
WHERE
  measure_value = 0
GROUP BY
  1;
```
|measure|frequency|
|---|---|
|blood_glucose|8|
|blood_pressure|562|
|weight|2|

+ Most of the ```measure_value = 0``` occur when ```measure = 'blood_pressure'```

```sql
SELECT *
FROM
  health.user_logs
WHERE
  measure_value = 0
  AND measure = 'blood_pressure';
```

+ When the blood pressure is measured and the ```measure_value = 0```, ```systolic``` and ```diastolic``` fields are populated with the valid records. The next question would be **what happened to the records where ```measure = 'blood_pressure'``` but the ```measure_value != 0```?**

```sql
SELECT *
FROM
  health.user_logs
WHERE
  measure_value != 0
  AND measure = 'blood_pressure';
```

| id                                       | log_date                 | measure        | measure_value | systolic | diastolic |
|------------------------------------------|--------------------------|----------------|---------------|----------|-----------|
| d14df0c8c1a5f172476b2a1b1f53cf23c6992027 | 2020-10-15T00:00:00.000Z | blood_pressure | 140           | 140      | 113       |
| 9fef7a7b06dea13eac08b2b609a008d6a178d0b7 | 2020-10-02T00:00:00.000Z | blood_pressure | 114           | 114      | 80        |
| 0b494d455a27f8a2709d7da6c98796ea0e629690 | 2020-10-19T00:00:00.000Z | blood_pressure | 132           | 132      | 94        |
| ee653a96022cc3878e76d196b1667d95beca2db6 | 2020-10-09T00:00:00.000Z | blood_pressure | 105           | 105      | 68        |
| 46d921f1111a1d1ad5dd6eb6e4d0533ab61907c9 | 2020-04-12T00:00:00.000Z | blood_pressure | 149           | 149      | 85        |
| 46d921f1111a1d1ad5dd6eb6e4d0533ab61907c9 | 2020-04-10T00:00:00.000Z | blood_pressure | 156           | 156      | 88        |
| 46d921f1111a1d1ad5dd6eb6e4d0533ab61907c9 | 2020-04-29T00:00:00.000Z | blood_pressure | 142           | 142      | 84        |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-04-07T00:00:00.000Z | blood_pressure | 131           | 131      | 71        |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-04-08T00:00:00.000Z | blood_pressure | 128           | 128      | 77        |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 2020-03-09T00:00:00.000Z | blood_pressure | 114           | 114      | 76        |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 2020-03-05T00:00:00.000Z | blood_pressure | 111           | 111      | 77        |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-03-11T00:00:00.000Z | blood_pressure | 125           | 125      | 78        |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 2020-03-01T00:00:00.000Z | blood_pressure | 116           | 116      | 80        |
| 46d921f1111a1d1ad5dd6eb6e4d0533ab61907c9 | 2020-03-16T00:00:00.000Z | blood_pressure | 137           | 137      | 78        |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 2020-03-09T00:00:00.000Z | blood_pressure | 99            | 99       | 68        |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 2020-03-17T00:00:00.000Z | blood_pressure | 113           | 113      | 80        |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 2020-03-06T00:00:00.000Z | blood_pressure | 123           | 123      | 83        |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 2020-03-06T00:00:00.000Z | blood_pressure | 124           | 124      | 83        |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 2020-03-06T00:00:00.000Z | blood_pressure | 138           | 138      | 90        |
| 981197b530b9ec5032abb0ffe4b69dba3649f467 | 2020-03-29T00:00:00.000Z | blood_pressure | 108           | 108      | 65        |
| 0a3be7bf5f8166b9eb410e4a728cb8db07c9f07f | 2020-03-11T00:00:00.000Z | blood_pressure | 144           | 144      | 79        |
|...|...|...|...|...|...|


+ Systolic values are populating both ```measure_value``` and ```systolic``` columns

+ Look now for the systolic and diastolic null values

```sql
SELECT 
  measure,
  COUNT (*) AS frequency
FROM 
  health.user_logs
WHERE 
  systolic IS NULL
GROUP BY 
  measure;
```
|measure|frequency|
|---|---|
|weight|443|
|blood_glucose|25580|


+ Most of null values for systolic occur when ```measure = 'blood_glucose'```


```sql
SELECT 
  measure,
  COUNT (*) AS frequency
FROM 
  health.user_logs
WHERE 
  diastolic IS NULL
GROUP BY 
  measure;
```

|measure|frequency|
|---|---|
|weight|443|
|blood_glucose|25580|

+ The same happens when ```diastolic IS NULL```

******

## DUPLICATED VALUES ANALYSIS

### DEAL WITH DUPLICATED VALUES

How to deal with duplicated rows:
+ Remove them in a SELECT statement
+ Recreating a “clean” version of our dataset
+ Identify exactly which rows are duplicated for further investigation or
+ Simply ignore the duplicates and leave the dataset alone


**Dected Duplicate Values**

```sql
SELECT COUNT(*)
FROM health.user_logs
```
| count  |
|--------|
| 43891  |

+ This returns the total number of records in the table. Adding a DISTINCT to the query will tells us how many **unique records** exist.

```sql
SELECT COUNT(DISTINCT *)
FROM health.user_logs
```

Since we are using PostgreSQL, the syntax needs to be a bit different because COUNT(DISTINCT *) does not work.

**Number of unique records with PostgreSQL**

+ A CTE or Common Table Expression is a SQL query that manipulates existing data and stores the data outputs as a new reference.

```sql
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT COUNT(*)
FROM deduped_logs;
```

**```SELECT DISTINCT *```**
| id                                       | log_date                 | measure        | measure_value | systolic | diastolic |
|------------------------------------------|--------------------------|----------------|---------------|----------|-----------|
| 576fdb528e5004f733912fae3020e7d322dbc31a | 2019-12-15T00:00:00.000Z | blood_pressure | 0             | 124      | 72        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-04-15T00:00:00.000Z | blood_glucose  | 267           |          |           |
| 8b130a2836a80239b4d1e3677302709cea70a911 | 2019-12-31T00:00:00.000Z | blood_glucose  | 109.799995    |          |           |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-05-07T00:00:00.000Z | blood_glucose  | 189           |          |           |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-08-18T00:00:00.000Z | weight         | 68.49244787   | 0        | 0         |

**```SELECT COUNT(*)```**
| count  |
|--------|
| 31004  |

We retrieve all the unique records with the CTE and them we count how many exist. **Note that this is to identify how many unique records are, not how many times they repeat themselves**.


+ Temporary Tables

```sql
DROP TABLE IF EXISTS deduplicated_user_logs; 

CREATE TEMP TABLE deduplicated_user_logs AS
SELECT DISTINCT *
FROM health.user_logs;

SELECT COUNT(*)
FROM deduplicated_user_logs;
```

Same principle but using a Temporary Table. Which one to use? **Will I need to use the deduplicated data later?**
 + **Yes** - Temporary tables
 + **No** - CTEs


**RESULTS:** 43.891 records and 31.004 unique records


### IDENTIFYING DUPLICATED VALUES

By using a `GROUP BY` with all the columns and a `COUNT` aggregate function we get the same result as the `DISTINCT` statement from earlier plus the frequency for each unique combination.

```sql
SELECT
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic
ORDER BY frequency DESC
```
**TOTAL ROWS: 31.004**
| id                                       | log_date                 | measure        | measure_value | systolic | diastolic | frequency |
|------------------------------------------|--------------------------|----------------|---------------|----------|-----------|-----------|
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-06T00:00:00.000Z | blood_glucose  | 401           |          |           | 104       |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-05T00:00:00.000Z | blood_glucose  | 401           |          |           | 77        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-04T00:00:00.000Z | blood_glucose  | 401           |          |           | 72        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-07T00:00:00.000Z | blood_glucose  | 401           |          |           | 70        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-09-30T00:00:00.000Z | blood_glucose  | 401           |          |           | 39        |


Now, to obtain the final table that has all the duplicate records, we just need to filter the `GROUP BY` with a `HAVING COUNT (*) > 1`. This narrows the records that only have a frequency > 1. 

```sql
SELECT *
FROM health.user_logs
GROUP BY
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic
HAVING COUNT(*) > 1;
```

**TOTAL ROWS: 6.562**
| id                                       | log_date                 | measure        | measure_value | systolic | diastolic |
|------------------------------------------|--------------------------|----------------|---------------|----------|-----------|
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-04-15T00:00:00.000Z | blood_glucose  | 267           |          |           |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-08-18T00:00:00.000Z | weight         | 68.49244787   | 0        | 0         |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-01-04T00:00:00.000Z | blood_glucose  | 113           |          |           |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-01-12T00:00:00.000Z | blood_glucose  | 121           |          |           |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-05-11T00:00:00.000Z | blood_glucose  | 76            |          |           |


Finally, besides knowing which records are duplicate, we also want to know their **frequency**. We keep the `COUNT` aggregate function and we make use of a **CTE** to filter the rows where the frequency count is bigger than 1.

**CTE**
```sql
WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT *
FROM groupby_counts
WHERE frequency > 1
ORDER BY frequency DESC
LIMIT 10;
```

**CTE - TOTAL ROWS: 31.004**
| id                                       | log_date                 | measure        | measure_value | systolic | diastolic | frequency |
|------------------------------------------|--------------------------|----------------|---------------|----------|-----------|-----------|
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-06T00:00:00.000Z | blood_glucose  | 401           |          |           | 104       |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-05T00:00:00.000Z | blood_glucose  | 401           |          |           | 77        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-04T00:00:00.000Z | blood_glucose  | 401           |          |           | 72        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-07T00:00:00.000Z | blood_glucose  | 401           |          |           | 70        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-09-30T00:00:00.000Z | blood_glucose  | 401           |          |           | 39        |

**```SELECT *```**

| id                                       | log_date                 | measure       | measure_value | systolic | diastolic | frequency |
|------------------------------------------|--------------------------|---------------|---------------|----------|-----------|-----------|
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-06T00:00:00.000Z | blood_glucose | 401           |          |           | 104       |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-05T00:00:00.000Z | blood_glucose | 401           |          |           | 77        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-04T00:00:00.000Z | blood_glucose | 401           |          |           | 72        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-07T00:00:00.000Z | blood_glucose | 401           |          |           | 70        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-09-30T00:00:00.000Z | blood_glucose | 401           |          |           | 39        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-09-29T00:00:00.000Z | blood_glucose | 401           |          |           | 24        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-10-02T00:00:00.000Z | blood_glucose | 401           |          |           | 18        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-10T00:00:00.000Z | blood_glucose | 140           |          |           | 12        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-11T00:00:00.000Z | blood_glucose | 220           |          |           | 12        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-04-15T00:00:00.000Z | blood_glucose | 236           |          |           | 12        |


******

## SUMMARY STATISTICS ANALYSIS

### Arithmetic Mean or Average

```sql
SELECT
  measure,
  COUNT(*) as frequency,
  ROUND(
    SUM (measure_value),
    2) AS sum_total,
  ROUND(
    AVG (measure_value),
    2) AS average
FROM
  health.user_logs
GROUP BY
  measure;
```

The average of the `weight` measure is out of the ordinary. 


### Median & Mode

Look other central statistics when `measure = weight`.

```sql
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS median_value,
  MODE() WITHIN GROUP (ORDER BY measure_value) AS mode_value,
  AVG(measure_value) as mean_value
FROM health.user_logs
WHERE measure = 'weight';
```

The `WITHIN GROUP` allows to sort rows ang group them making use of an aggregate function. In the example above, we use both `PERCENTILE_CONT` and the `MODE`. 
We make use of the `ORDER BY` clause to specify the column on which to sort the grouped rows.


### Min, Max & Range

```sql
EXPLAIN ANALYZE
SELECT
  MIN(measure_value) AS minimum_value,
  MAX(measure_value) AS maximum_value,
  MAX(measure_value) - MIN(measure_value) AS range_value
FROM health.user_logs
WHERE measure = 'weight';
```
**Execution Time:** 15.913 ms

The query below will have a better performance because:
- It is calculating the `MIN` and `MAX` just one time
- Reduce the number down from the total size of the health.user_logs down to just 2 numbers

```sql
EXPLAIN ANALYZE
WITH min_max_values AS (
  SELECT
    MIN(measure_value) AS minimum_value,
    MAX(measure_value) AS maximum_value
  FROM health.user_logs
  WHERE measure = 'weight'
)
SELECT
  minimum_value,
  maximum_value,
  maximum_value - minimum_value AS range_value
FROM min_max_values;
```
**Execution Time:** 13.388 ms


### Variance & Standard Deviation

The standard deviation and the variance explain how the data is spread around the mean.

An increase in standard deviation value sees a subsequent “spread”. This is exactly what we’d expect when we apply the same standard deviation metrics to our data - even though they might not be normal distributions!

If the data follows a normal distribution, there are general boundaries about how much percentage of the total lies between different ranges related to our standard deviation values.

|Percentage of Values	|Range of Values
|---|---|
|68% |	μ±σ |
|95% |	μ±2×σ |
|99.7% |	μ±3×σ |

If:
+ Mode < Median < Mean - Distribution is **Positive Skew or Left Skew**

+ Mode = Median = Mean - Symmetrical Distribution

+ Mode > Median > Mean - Distribution is **Negative Skew or Right Skew**


```sql
SELECT 
  'weight' AS measure,
  ROUND( MIN(measure_value), 2) AS min_value,
  ROUND( MAX(measure_value), 2) AS max_value,
  ROUND( AVG(measure_value), 2) AS average,
  ROUND(
    CAST( PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY measure_value ASC) AS NUMERIC),
    2) AS median,
  ROUND( 
    MODE() WITHIN GROUP (ORDER BY measure_value ASC),
    2) AS mode,
  ROUND( VARIANCE(measure_value), 2) AS variance,
  ROUND( STDDEV(measure_value), 2) AS standard_deviation
FROM
  health.user_logs
WHERE
  measure = 'weight';
```

| measure | min_value | max_value | average | median | mode | variance | standard_deviation |
|---|---|---|---|---|---|---|---|
| weight | 0.00 | 39642120.00 | 28786.85 | 75.98 | 68.49 | 1129457862383.41 | 1062759.55 |

Notes:
+ The min and max values do not make much sense
+ The median value is at 76kg but the average is at 28787kg
+ The std is too large, with a value at 1062760kg

> What to do? **CUMULATIVE DISTRIBUTION FUNCTIONS**

******

## CUMULATIVE DISTRIBUTION

A CDF takes a value and returns the percentile. The same as saying what is the probability of any value between the min_value and the value that the function took.

```sql
WITH percentile_values AS (
  SELECT
    measure_value,
    NTILE(100) OVER( ORDER BY measure_value) AS percentile
  FROM
    health.user_logs
  WHERE
    measure = 'weight'
)
SELECT
  percentile,
  MIN(measure_value) AS floor,
  MAX(measure_value) AS celling,
  COUNT(*) AS percentile_counts
FROM 
  percentile_values
GROUP BY 
  percentile
ORDER BY
  percentile ASC;
```

Looking at the 1 percentile and at the 100 percentile, we see that
+ There are 28 records between 0kg and 29kg
    + Values around 29kg could make sense if they are refering to children;
    + There could be incorrected measures replace by 0;
+ There are 27 records between 137kg and 39642120kg (which is absurd)

Use WINDON FUNCTIONS `ROW_NUMBER`, `RANK` and `DENSE_RANK` to sort the values of the `measure_value` column.

+ **ROW_NUMBER** orders the rows incrementally with the top row begining at 1 and so on
+ **RANK** assigns the rows in groups and the next number is equal to the total of rows already assigned + 1
+ **DENSE_RANK** keeps the rows in buckets that are ordered sequentially. 

> 100th Percentile
```sql
WITH percentile_values AS (
  SELECT
    measure_value,
    NTILE(100) OVER( ORDER BY measure_value) AS percentile
  FROM
    health.user_logs
  WHERE
    measure = 'weight'
)
SELECT
  measure_value,
  ROW_NUMBER() OVER (ORDER BY measure_value DESC) AS row_number_order,
  RANK() OVER (ORDER BY measure_value DESC) AS rank_order,
  DENSE_RANK() OVER (ORDER BY measure_value DESC) AS dense_rank_order
FROM
  percentile_values
WHERE
  percentile = 100
ORDER BY
  measure_value DESC;
```

3 values are out of the ordinary: 39642120, 39642120 and 576484. The next one, 200.49 although it is a huge value it is acceptable.

> 1th Percentile
```sql
WITH percentile_values AS (
  SELECT
    measure_value,
    NTILE(100) OVER( ORDER BY measure_value) AS percentile
  FROM
    health.user_logs
  WHERE
    measure = 'weight'
)
SELECT
  measure_value,
  ROW_NUMBER() OVER (ORDER BY measure_value DESC) AS row_number_order,
  RANK() OVER (ORDER BY measure_value DESC) AS rank_order,
  DENSE_RANK() OVER (ORDER BY measure_value DESC) AS dense_rank_order
FROM
  percentile_values
WHERE
  percentile = 1
ORDER BY
  measure_value ASC;

The values 0 are weird but the other ones above 1.5 kg are valid because they can be referring to babies.