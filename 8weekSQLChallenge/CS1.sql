/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

/*
	- Group by customer_id and 
	- SUM the price spend by each customer and 
*/

SELECT 
	customer_id
    , SUM (price) as Total_Amount
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
GROUP BY customer_id;

/*
| customer_id | Total_Amount |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |
*/


-- 2. How many days has each customer visited the restaurant?

/*
	- Group by customer_id 
	- COUNT DISTINTCT to avoid double count visits on the same day
*/

SELECT 
	customer_id
    , COUNT (DISTINCT order_date) as VisitsInOneDay
FROM dannys_diner.sales
GROUP BY customer_id;

/*
| customer_id | VisitsInOneDay |
| ----------- | -------------- |
| A           | 4              |
| B           | 6              |
| C           | 2              |
*/


-- 3. What was the first item from the menu purchased by each customer?


--- CTE APPROACH ---
WITH orders_rank_cte AS (
  	SELECT 
      customer_id
      , order_date
      , product_name
      , DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date asc) AS item_rank
	FROM dannys_diner.sales
	LEFT JOIN dannys_diner.menu
		ON sales.product_id = menu.product_id
	)
SELECT
	customer_id
    , product_name
FROM orders_rank_cte
WHERE item_rank = 1;



--- SUB-QUERIES APPROACH ----
SELECT 
	customer_id
    , product_name
FROM (
    SELECT 
		customer_id
        , order_date
        , product_name
        , DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS item_rank
   FROM dannys_diner.sales
   LEFT JOIN dannys_diner.menu 
		ON sales.product_id = menu.product_id) AS oldest_item
WHERE item_rank = 1;



--- SUB-QUERIES APPROACH 1 ---
SELECT
	DISTINCT (customer_id)
  	, product_name 
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
WHERE s.order_date IN (
                      SELECT 
                          MIN (order_date)
                      FROM dannys_diner.sales
                      GROUP BY customer_id
                    );

/*
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |
| C           | ramen        |
*/


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	product_name
    , COUNT(s.product_id) as item_count
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id 
GROUP BY product_name
ORDER BY item_count desc
LIMIT 1;

/*
| product_name | item_count |
| ------------ | ---------- |
| ramen        | 8          |
*/


-- 5. Which item was the most popular for each customer?

--- CTE & DENSE_RANK() ---
WITH item_count_cte AS (
  SELECT
  	sales.customer_id
  	, menu.product_name
  	, COUNT (sales.product_id) as item_count
  	, DENSE_RANK () OVER (PARTITION BY sales.customer_id ORDER BY COUNT (sales.product_id) desc) AS item_count_rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu
  	ON sales.product_id = menu.product_id
  GROUP BY sales.customer_id, menu.product_name
  )
SELECT 
	customer_id
    , product_name
    , item_count
FROM item_count_cte
WHERE item_count_rank = 1;

/*
| customer_id | product_name | item_count |
| ----------- | ------------ | ---------- |
| A           | ramen        | 3          |
| B           | curry        | 2          |
| B           | sushi        | 2          |
| B           | ramen        | 2          |
| C           | ramen        | 3          |
*/


-- 6. Which item was purchased first by the customer after they became a member?

/*
	- DENSE_RANK by customer to rank the orders_date by earlist ones.
	- The SELECT statement is the last to be execute. Only after the WHERE filters the order_date > join_date does the DENSE_RANK starts to rank
	- Put all this in a CTE and then select only the ones where the rank = 1 to identify the first ordered product_id
	- Product_id, order_date and join_date appear in the final table just to visualize the logic of the query
*/

WITH order_date_ranks AS (
  SELECT 
  	sales.customer_id
    , sales.product_id
    , product_name
    , order_date
    , join_date
    , DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date) as order_date_rank
	FROM dannys_diner.sales
	JOIN dannys_diner.members
		ON sales.customer_id = members.customer_id
	JOIN dannys_diner.menu
		ON sales.product_id = menu.product_id
	WHERE order_date > join_date
	) 
SELECT *
FROM order_date_ranks
WHERE order_date_rank = 1;

/*
| customer_id | product_id | product_name | order_date | join_date  | order_date_rank |
| ----------- | ---------- | ------------ | ---------- | ---------- | --------------- |
| A           | 3          | ramen        | 2021-01-10 | 2021-01-07 | 1               |
| B           | 1          | sushi        | 2021-01-11 | 2021-01-09 | 1               |
*/


-- 7. Which item was purchased just before the customer became a member?

/*
Same approach as before with slight changes: 
	- order_date < join_date to filter the orders before the customer became a member 
	- ORDER BY must be DESC to get the lastest date prior to the join_date
*/

WITH order_date_ranks AS (
  SELECT 
  	sales.customer_id
    , sales.product_id
    , product_name
    , order_date
    , join_date
    , DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC) as order_date_rank
	FROM dannys_diner.sales
	JOIN dannys_diner.members
		ON sales.customer_id = members.customer_id
	JOIN dannys_diner.menu
		ON sales.product_id = menu.product_id
	WHERE order_date < join_date
) 
SELECT *
FROM order_date_ranks
WHERE order_date_rank = 1;

/*
| customer_id | product_id | product_name | order_date | join_date  | order_date_rank |
| ----------- | ---------- | ------------ | ---------- | ---------- | --------------- |
| A           | 1          | sushi        | 2021-01-01 | 2021-01-07 | 1               |
| A           | 2          | curry        | 2021-01-01 | 2021-01-07 | 1               |
| B           | 1          | sushi        | 2021-01-04 | 2021-01-09 | 1               |
*/


-- 8. What is the total items and amount spent for each member before they became a member?

/*
	- join the three tables
	- aggregate function to calculate the total items and total amount 
	- have the order_date < join_date
	- group by customer_id
*/ 

SELECT
	s.customer_id
    , COUNT (s.product_id) as total_items
    , SUM (menu.price) as total_amount
   -- , s.order_date
    -- , m.join_date
FROM dannys_diner.sales s
JOIN dannys_diner.menu menu
	ON s.product_id = menu.product_id
JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

/*
| customer_id | total_items | total_amount |
| ----------- | ----------- | ------------ |
| B           | 3           | 40           |
| A           | 2           | 25           |
*/


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

/*
	- join sales table and menu table
	- group by customer_id
	- case when to double the points when item is sushi
*/
SELECT
	s.customer_id
    ,SUM(
      	CASE WHEN m.product_name = "sushi"
    		THEN (m.price * 10 * 2)
            ELSE m.price * 10
          END
      ) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;


--- CTE APPROACH ---
WITH points_cte AS (
	SELECT *,
		CASE WHEN m.product_name = 'sushi' 
			THEN price * 20
			ELSE price * 10
		END AS total_points
	FROM dannys_diner.menu m
)
SELECT 
	customer_id
	,SUM(total_points) AS total_points
FROM dannys_diner.sales s
JOIN points_cte p 
	ON p.product_id = s.product_id
GROUP BY s.customer_id

/*  
| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |
*/


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

/*
	- join all 3 tables  
	- where order_date >= join_date & <= '2021-01-31'
	- order_date >= join_date + 7 days: all points double. Besides that I assume the system returns as it was in the previous question and only sushi x2
	- group by customer_id having customer_id = A or B
*/

SELECT 
	s.customer_id,
    SUM(
      	CASE WHEN (s.order_date >= mb.join_date) 
     				AND 
        	  		(s.order_date <= DATE_ADD(mb.join_date, INTERVAL 7 DAY))
        	THEN m.price * 10 * 2
         WHEN m.product_name = "sushi"
          	THEN m.price * 10 * 2
         ELSE m.price * 10
         END
      ) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.members mb
	ON s.customer_id = mb.customer_id
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id
HAVING s.customer_id IN ('A','B');

/*
| customer_id | total_points |
| ----------- | ------------ |
| B           | 940          |
| A           | 1370         |
*/


/*********************
	BONUS QUESTIONS
*********************/

-- B1. Recreate the following table output
/*
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | Y      |
| C           | 2021-01-07 | ramen        | 12    | Y      |
*/

SELECT
	s.customer_id
    , s.order_date
    , m.product_name
    , m.price
    , CASE WHEN
    			s.order_date < mb.join_date
                THEN "N"
                ELSE "Y"
      END AS member
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members mb
	ON s.customer_id = mb.customer_id
ORDER BY s.customer_id, s.order_date, m.product_name

/*
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | Y      |
| C           | 2021-01-07 | ramen        | 12    | Y      |
*/


-- B2. Rank All Things: Expects null ranking values for the records when customers are not yet part of the loyalty program

/*
| customer_id | order_date | product_name | price | member | ranking |
| ----------- | ---------- | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01 | curry        | 15    | N      | NULL    |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | NULL    |
| B           | 2021-01-02 | curry        | 15    | N      | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | Y      | 1       |
| C           | 2021-01-01 | ramen        | 12    | Y      | 1       |
| C           | 2021-01-07 | ramen        | 12    | Y      | 3       |
*/

WITH full_table_cte AS (
  SELECT
      s.customer_id
      , s.order_date
      , m.product_name
      , m.price
      , CASE WHEN
                  s.order_date < mb.join_date
                  THEN "N"
                  ELSE "Y"
        END AS member
  FROM dannys_diner.sales s
  LEFT JOIN dannys_diner.menu m
      ON s.product_id = m.product_id
  LEFT JOIN dannys_diner.members mb
      ON s.customer_id = mb.customer_id
  ORDER BY s.customer_id, s.order_date, m.product_name
)
SELECT
	customer_id
    , order_date
    , product_name
    , price
    , member
    , CASE WHEN
    			member = "N" 
                THEN NULL
                ELSE
                	RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date) 
      END AS ranking
FROM full_table_cte;

/*
| customer_id | order_date | product_name | price | member | ranking |
| ----------- | ---------- | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01 | curry        | 15    | N      | NULL    |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | NULL    |
| B           | 2021-01-02 | curry        | 15    | N      | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | Y      | 1       |
| C           | 2021-01-01 | ramen        | 12    | Y      | 1       |
| C           | 2021-01-07 | ramen        | 12    | Y      | 3       |
*/