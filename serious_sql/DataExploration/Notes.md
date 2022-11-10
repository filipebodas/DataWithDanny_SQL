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

Use the ```sql WHERE ``` clause to see what happens to the ```sql measure ``` column when ```sql measure_value = 0 ``` and ```sql systolic IS NULL ``` and ```sql diastolic IS NULL ``` 

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

+ Most of the ```sql measure_value = 0 ``` occur when ```sql measure = 'blood_pressure' ```

```sql
SELECT *
FROM
  health.user_logs
WHERE
  measure_value = 0
  AND measure = 'blood_pressure';
```

+ When the blood pressure is measured and the ```sql measure_value = 0 ```, ```sql systolic ``` and ```sql diastolic ``` fields are populated with the valid records. The next question would be **what happened to the records where ```sql measure = 'blood_pressure' ``` but the ```sql measure_value != 0 ```?**

```sql
SELECT *
FROM
  health.user_logs
WHERE
  measure_value != 0
  AND measure = 'blood_pressure';
```

+ Systolic values are populating both ```sql measure_value ``` and ```sql systolic ``` columns

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


+ Most of null values for systolic occur when ```sql measure = 'blood_glucose' ```


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

+ The same happens when ```sql diastolic IS NULL ```

