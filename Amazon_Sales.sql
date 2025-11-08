/* AMAZON SALES ANALYSIS
   Objective: Perform end-to-end SQL analysis on Amazon sales data to uncover insights on
   sales performance, customer behavior, returns, and satisfaction trends.
*/

 


# DATA LOADING AND UNDERSTANDING
SELECT * FROM amazon_sales

# ️DATA CLEANING AND VALIDATION
# --- Check for missing values ---
SELECT 
  SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS Null_Order_ID,
  SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS Null_Date,
  SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Null_Customer_ID,
  SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END) AS Null_Product_Category,
  SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS Null_Product_Name,
  SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
  SUM(CASE WHEN Unit_Price IS NULL THEN 1 ELSE 0 END) AS Null_Unit_Price,
  SUM(CASE WHEN Total_Sales IS NULL THEN 1 ELSE 0 END) AS Null_Total_Sales,
  SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS Null_Payment_Method,
  SUM(CASE WHEN Delivery_Status IS NULL THEN 1 ELSE 0 END) AS Null_Delivery_Status,
  SUM(CASE WHEN Review_Rating IS NULL THEN 1 ELSE 0 END) AS Null_Review_Rating,
  SUM(CASE WHEN Review_Text IS NULL THEN 1 ELSE 0 END) AS Null_Review_Text,
  SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS Null_State
FROM amazon_sales;
# No Missing Values found


# --- Check for duplicate Order IDs ---
SELECT Order_ID, COUNT(*)
FROM amazon_sales
GROUP BY Order_ID
HAVING COUNT(*) > 1;
# No duplicates in order_id column


# --- Check total sales calculation ---
SELECT Order_ID, Quantity, Unit_Price, Total_Sales,
ROUND(Quantity * Unit_Price, 2) AS Total_amount
FROM amazon_sales
WHERE ROUND(Quantity * Unit_Price, 2) <> Total_Sales;
# No mismatches found

# --- Date Foratting ---
UPDATE amazon_sales
SET Date = STR_TO_DATE(Date, '%d-%m-%Y');


# --- Check for future dates ---
SELECT Order_ID, Date
FROM amazon_sales
WHERE Date > CURRENT_DATE()
AND Year(Date) <> 2025;
# No future or past dates other than year 2025


# OVERALL PERFORMANCE KPIs	 
SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Total_Sales), 2) AS Total_Sales,
    ROUND(AVG(Total_Sales), 2) AS Avg_Order_Value,
    ROUND(AVG(Review_Rating), 2) AS Avg_Rating,
    ROUND(100*SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END)/COUNT(*),2) AS Return_Rate_Percent
FROM amazon_sales;
#Insights:
# - 15,000 orders generated around 1.12 Billion INR in revenue.
# - Average order value is 74.5k INR, which is quite high which suggests either high-value products or bulk purchases.
# - Average rating is 3.04 indicating moderate customer satisfaction, leaving room for improvement.
# - 32.54% return rate is high nearly 1 in 3 orders is returned.
# - This points to potential issues in product quality, descriptions vs reality, delivery or customer expectations.


# CATEGORY WISE PERFORMANCE
SELECT Product_Category,
	   ROUND(SUM(Total_Sales),2) AS Total_Sales,
       SUM(Quantity) AS Total_Quantity,
       ROUND(AVG(Review_Rating), 2) AS Avg_Rating,
       ROUND(100*SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END)/COUNT(*),2) AS Return_Rate
FROM amazon_sales
GROUP BY Product_Category
ORDER BY Total_Sales DESC;
# Insights:
# - Beauty leads in sales and orders, indicating strong demand.
# - Electronics and Books have the highest return rates (~33%), pointing to product or delivery issues.
# - Avg ratings are around 3/5 for all categories, suggesting room for improvement in customer satisfaction.


# TOP PRODUCTS
SELECT Product_Name, Product_Category,
	   ROUND(SUM(Total_Sales),2) AS Total_Sales,
       SUM(Quantity) AS Total_Quantity,
       ROUND(AVG(Review_Rating), 2) AS Avg_Rating,
       ROUND(100*SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END)/COUNT(*),2) AS Return_Rate
FROM amazon_sales
GROUP BY Product_Name, Product_Category
ORDER BY Total_Sales DESC
LIMIT 10;
# Insights:
# - Lipstick, Children’s Book, and Headphones are top 3 revenue products but also have high return rates.
# - Headphones have the highest return rate (35%) which might be due to quality issues/packaging review.
# - Hair Dryer has moderate sales but low rating (2.87) likely due to lack of cusomer service - focus on customer experience.
# - Beauty products dominate top sales, Electronics have higher returns.


# SALES TREND
SELECT DATE_FORMAT(Date, '%Y-%m') AS Month,
       ROUND(SUM(total_sales), 2) AS Monthly_Sales,
       COUNT(*) AS Orders
FROM amazon_sales
GROUP BY Month
ORDER BY Month ASC;
# Insights:
# - Peak sales in May, August and December.
# - High Orders in July and August


# --- monthly sales trend per product category ---
SELECT 
    Product_Category,
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    ROUND(SUM(Total_Sales), 2) AS Monthly_Sales,
    COUNT(Order_ID) AS Orders,
    ROUND(AVG(Review_Rating),2) AS Avg_Rating,
    ROUND(100*SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END)/COUNT(*),2) AS Return_Rate
FROM amazon_sales
GROUP BY Product_Category, Month
ORDER BY Product_Category, Month;
# Insights:
# - Beauty products show consistently high monthly sales, peaking during festive months (May, August, December), indicating strong seasonal demand.
# - Electronics have uneven monthly sales, with spikes in mid-year, likely corresponding to promotions or new launches.
# - Books and Clothing display steady sales, but return rates for Clothing are higher in peak months — possibly due to sizing issues or expectations mismatch.


# RETURN ROOT CAUSE ANALYSIS
SELECT Product_Name, Product_Category,
       COUNT(*) AS Orders,
       SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END) AS Returns,
       ROUND(100*SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END)/COUNT(*),2) AS Return_Rate
FROM amazon_sales
GROUP BY Product_Name, Product_Category
HAVING Return_Rate > 20
ORDER BY Return_Rate DESC;
# Insights
# - Smartwatch, Science Textbook, and T-Shirt have the highest return rates (~35%), indicating potential quality, sizing, or expectation mismatches.
# - Electronics and Clothing dominate the top return list, suggesting issues like defective items or incorrect fit.
# - Beauty products such as Lipstick and Perfume show moderate return rates (31–33%), reflecting stable but improvable performance.
# - Home & Kitchen products (Air Fryer, Cookware, Water Purifier) have lower return rates (<32%), signaling strong customer satisfaction.
# - Overall, returns cluster between 30–36%, showing a need for better product descriptions, quality control, or after-sales support.

# --- monthly return trend per category ---
SELECT 
    Product_Category,
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    ROUND(SUM(Total_Sales), 2) AS Monthly_Sales,
    COUNT(Order_ID) AS Orders,
    SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END) AS Returns,
    ROUND(100*SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END)/COUNT(*),2) AS Return_Rate
FROM amazon_sales
GROUP BY Product_Category, Month
ORDER BY Product_Category, Month;
# Insights:
# - Beauty shows moderate returns (24–35%), peaking in festive months (Dec).  
# - Books have variable returns (28–39%), with highest in Mar/Jul.  
# - Clothing returns are high (28–40%), likely due to sizing issues, peaking Mar/Oct.  
# - Electronics returns are consistently high (30–39%), with peak in Aug.  
# - Home & Kitchen returns are stable (29–35%), slightly higher in Dec.  
# - Overall, returns spike during peak/festive months; focus on quality, sizing, and handling for high-return categories.



# PAYMENT METHOD ANALYSIS
SELECT Payment_Method,
       ROUND(SUM(total_sales), 2) AS Total_Sales,
       COUNT(*) AS Orders,
       ROUND(AVG(Review_Rating),2) AS Avg_Rating,
       ROUND(100*SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END)/COUNT(*),2) AS Return_Rate
FROM amazon_sales
GROUP BY Payment_Method
ORDER BY Total_Sales DESC;
# Insights
# - Credit Card and COD are the top contributors to sales, each generating ~287M INR.
# - Ratings are consistent (~3.0) across payment types, showing neutral satisfaction.
# - Return rates are highest for Credit Card (33.3%), possibly due to easier refund processes.
# - UPI has lowest return rate (32.1%), indicating higher buyer confidence in instant payments.


# DELIVERY STATUS ANALYSIS
SELECT Delivery_Status,
       COUNT(*) AS Orders,
       SUM(total_sales) AS Total_Sales,
       ROUND(AVG(Review_Rating),2) AS Avg_Rating
FROM amazon_sales
GROUP BY Delivery_Status;
# Insights:
# - Sales are evenly distributed across each delivery status.
# - About one-third of orders are still pending or returned, which may affect revenue realization.
# - Delivered orders have slightly lower average rating (3.00), hinting at post-delivery dissatisfaction.
# - Monitoring return and pending orders can improve customer retention and logistics efficiency.


# STATE WISE PERFORMANCE
SELECT State,
       COUNT(DISTINCT Customer_ID) as Total_Customers,
       ROUND(SUM(total_sales), 2) AS Total_Sales,
       COUNT(*) AS Orders,
       ROUND(AVG(Review_Rating),2) AS Avg_Rating,
       ROUND(100*SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END)/COUNT(*),2) AS Return_Rate
FROM amazon_sales
GROUP BY State
ORDER BY Total_Sales DESC;
# Insights
# - Sikkim, Rajasthan, and Chhattisgarh lead in total sales.
# - Ratings remain stable (~3.0) across most states, showing consistent customer sentiment.
# - Uttar Pradesh and Assam have higher return rates (>35%), indicating potential delivery or product issues.
# - Maharashtra and Andhra Pradesh show lower return rates (<30%), suggesting efficient logistics or better product quality.
# - Regional performance differences can guide targeted improvements in supply chain, product offerings, and after-sales service.


# CUSTOMER BEHAVIOUR ANALYSIS
SELECT Customer_ID,
       ROUND(SUM(total_sales), 2) AS Total_Spend,
       COUNT(Order_ID) AS Orders,
       ROUND(AVG(Review_Rating),2) AS Avg_Rating
FROM amazon_sales
GROUP BY Customer_ID
ORDER BY Total_Spend DESC
LIMIT 10;
# Insights
# - Top customers each contributed over ₹700K–₹875K, showing strong repeat purchasing.
# - CUST7903 is the highest spender, placing 7 orders with ₹875K spent and 3.14 rating.
# - CUST2764 stands out with the highest satisfaction (3.67) among top spenders.
# - Some high-value customers gave low ratings, signaling potential issues with product experience.
# - These customers can be targeted for loyalty programs or personalized offers to increase retention.


# CUSTOMER SEGMENTATION
WITH customer_summary AS (
    SELECT 
        Customer_ID,
        ROUND(SUM(Total_Sales), 2) AS Total_Spend,
        COUNT(Order_ID) AS Total_Orders,
        ROUND(AVG(Review_Rating), 2) AS Avg_Rating
    FROM amazon_sales
    GROUP BY Customer_ID
),
customer_ranked AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY Total_Spend DESC) AS Spend_Quartile
    FROM customer_summary
),
segmented_customers AS (
    SELECT 
        Customer_ID,
        Total_Spend,
        Total_Orders,
        Avg_Rating,
        CASE 
            WHEN Spend_Quartile = 1 THEN 'Top 25% High Value'
            WHEN Spend_Quartile = 2 THEN 'Upper-Mid 25%'
            WHEN Spend_Quartile = 3 THEN 'Lower-Mid 25%'
            ELSE 'Bottom 25% Low Value'
        END AS Customer_Segment
    FROM customer_ranked
)
SELECT
    Customer_Segment,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    ROUND(AVG(Total_Spend), 2) AS Avg_Spend,
    ROUND(AVG(Total_Orders), 2) AS Avg_Orders,
    ROUND(AVG(Avg_Rating), 2) AS Avg_Rating
FROM segmented_customers
GROUP BY Customer_Segment
ORDER BY Avg_Spend DESC;
# Insights:
# -  25% High Value customers are driving most of the revenue, with significantly higher average spend and orders.
# - Lower-Mid and Bottom segments contribute relatively little to revenue, though they form a substantial customer base.
# - The Top 25% segment could be targeted with premium offers, personalized promotions, or loyalty programs.
# - The Bottom segments may benefit from engagement campaigns, discounts, or educational content to boost orders and spend.


# ADVANCED ANALYSIS

# --- Product Category vs Payment Method ---
SELECT Product_Category, Payment_Method,
       COUNT(*) AS Orders,
       ROUND(SUM(Total_Sales),2) AS Total_Sales
FROM amazon_sales
GROUP BY Product_Category, Payment_Method
ORDER BY Total_Sales DESC;
# Insights:
# - Books (Credit Card) tops revenue for a category-payment pair.
# - Electronics (Cash on Delivery) also performs strongly — COD remains important for big-ticket electronics.
# - Beauty shows strong performance across Credit Card, COD and Debit — demand is broad across payment types.
# - Clothing has high spend via COD, UPI and Debit — multiple payment preferences.
# - verall, no single payment method dominates every category; payment preference is category-dependent.

# -- Category x Payment Method: Return rate + Orders + Sales
SELECT
  Product_Category,
  Payment_Method,
  COUNT(*) AS Orders,
  ROUND(SUM(Total_Sales), 2) AS Total_Sales,
  SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END) AS Returns,
  ROUND(100 * SUM(CASE WHEN Delivery_Status='Returned' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Return_Rate
FROM amazon_sales
GROUP BY Product_Category, Payment_Method
ORDER BY Return_Rate DESC, Total_Sales DESC;
# Insights
# - Books (UPI, Debit Card, Credit Card) have the highest return rates (~34–35%), signaling issues with product expectations or delivery.
# - Electronics (Credit Card, COD) also show high return rates (~33–35%), likely due to defective products or shipping problems.
# - Clothing shows moderate return rates (~32–33%), across Credit Card, Debit Card, and COD, suggesting sizing or quality issues.
# - Beauty and Home & Kitchen have slightly lower return rates (~30–32%), indicating better customer satisfaction.
# - Overall, high sales do not always correlate with low returns — category-specific strategies are needed:
# - Focus on Books and Electronics to reduce returns (better QC, accurate descriptions, or improved packaging).
# - Maintain Beauty and Home & Kitchen quality to sustain low return rates.
# - Payment method matters: COD and Credit Card orders tend to have slightly higher return rates than UPI, possibly due to refund ease.


# --- State-level Customer Value ---
SELECT 
    State,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    ROUND(SUM(Total_Sales), 2) AS Total_Sales,
    ROUND(SUM(Total_Sales) / COUNT(DISTINCT Customer_ID), 2) AS Avg_Order_Value
FROM amazon_sales
GROUP BY State
ORDER BY Avg_Order_Value DESC;
# Insights:
# - Chhattisgarh (₹80.5K), Goa (₹80.4K), and Himachal Pradesh (₹80.0K) lead in average order value, showing higher purchasing power or preference for premium products.
# - Eastern and Southern states like Assam, Nagaland, and Telangana have lower AOV (<₹75K), possibly reflecting budget-conscious buying behavior or smaller orders.

       
# --- Rating Distribution ---
SELECT Review_Rating, COUNT(*) AS Review_Count
FROM amazon_sales
GROUP BY Review_Rating
ORDER BY Review_Rating;
# Insights
# - Ratings are relatively evenly distributed across 1–5 stars.
# - Slightly higher 5-star count (3128) suggests a positive sentiment, but the presence of many 1–2 star ratings (2839 + 2998) shows notable dissatisfaction.
# - Average rating around 3.0 aligns with earlier insights — moderate overall customer satisfaction.
# - Actionable takeaway: focus on improving product quality, delivery, or customer support to shift more 3-star and lower ratings toward 4–5 stars.


# --- Delivery Status vs Rating Correlation ---
SELECT 
    Delivery_Status,
    ROUND(AVG(Review_Rating), 2) AS Avg_Rating,
    COUNT(*) AS Orders
FROM amazon_sales
GROUP BY Delivery_Status
ORDER BY Orders DESC;
# Insights
# - Delivered orders have the lowest average rating (3.00) — might indicate post-delivery issues like product dissatisfaction or delayed delivery.
# - Returned and Pending orders have slightly higher ratings (3.06), suggesting that customers may rate higher when interacting with support/refunds or before receiving the product.
# - The order count is almost equal across all statuses, highlighting that a significant portion of orders are not successfully delivered or returned.
# - Actionable takeaway: improve delivery efficiency, product quality, and post-sales support to increase delivered order satisfaction.


/* CONCLUSION
The analysis reveals strong revenue but high returns and moderate customer satisfaction.
Focused strategies in product quality, customer experience, regional logistics,
and high-value customer engagement can boost revenue, reduce returns, and improve loyalty.
*/

