-- Total customers who made their first purchase in a given period
WITH first_time_customers AS (
  SELECT CustomerID, MIN(OrderDate) AS FirstPurchase
  FROM customer_journey
  GROUP BY CustomerID
),

-- Customers who made repeat purchases
repeat_customers AS (
  SELECT cj.CustomerID
  FROM customer_journey cj
  JOIN first_time_customers ftc ON cj.CustomerID = ftc.CustomerID
  WHERE cj.OrderDate > ftc.FirstPurchase
  GROUP BY cj.CustomerID
)

SELECT 
  (SELECT COUNT(*) FROM repeat_customers) * 1.0 / COUNT(*) AS RetentionRate
FROM first_time_customers;


-- Products frequently purchased by customers who never come back
WITH purchase_counts AS (
  SELECT CustomerID, COUNT(*) AS NumPurchases
  FROM customer_journey
  GROUP BY CustomerID
),
one_time_buyers AS (
  SELECT CustomerID
  FROM purchase_counts
  WHERE NumPurchases = 1
)
SELECT 
  p.ProductName,
  COUNT(*) AS OneTimePurchases
FROM customer_journey cj
JOIN products p ON cj.ProductID = p.ProductID
WHERE cj.CustomerID IN (SELECT CustomerID FROM one_time_buyers)
GROUP BY p.ProductName
ORDER BY OneTimePurchases DESC
LIMIT 5;
