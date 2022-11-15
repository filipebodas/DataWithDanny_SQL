## NULL VALUES ANALYSIS

```sql
SELECT
  COUNT (*) as count_rows,
  COUNT (DISTINCT id) as unique_ids
FROM
  health.user_logs;
```
|count_rows|unique_ids|
|---|---|
|43891|554|


**Check the frequency for individual columns: measure, measure_value, systolic and diastolic**

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

**Methods**

+ A CTE or Common Table Expression is a SQL query that manipulates existing data and stores the data outputs as a new reference.

```sql
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT COUNT(*)
FROM deduped_logs;
```

+ Temporary Tables

```sql
CREATE TEMP TABLE deduplicated_user_logs AS
SELECT DISTINCT *
FROM health.user_logs;

SELECT COUNT(*)
FROM deduplicated_user_logs;
```

**Will I need to use the deduplicated data later?**
 + **Yes** - Temporary tables
 + **No** - CTEs


### IDENTIFYING DUPLICATED VALUES

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

**TEMP TABLE**
```sql
DROP TABLE IF EXISTS unique_duplicate_records;

CREATE TEMPORARY TABLE unique_duplicate_records AS
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