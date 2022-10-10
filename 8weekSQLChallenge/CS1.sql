/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
	customer_id
    , SUM (price) as Total_Amount
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
GROUP BY customer_id;


-- 2. How many days has each customer visited the restaurant?

SELECT 
	customer_id
    , COUNT (DISTINCT order_date) as VisitsInOneDay
FROM dannys_diner.sales
GROUP BY customer_id;


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


-- 6. Which item was purchased first by the customer after they became a member?




-- 7. Which item was purchased just before the customer became a member?




-- 8. What is the total items and amount spent for each member before they became a member?




-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?




-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

