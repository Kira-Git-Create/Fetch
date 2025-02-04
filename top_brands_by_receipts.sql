/*Question: What are the top 5 brands by receipts scanned among users 21 and over?
Answer:
Assumptions
* When ranking the brands by Receipts Scanned count, more than 5 brands could share the same count. 
From a business perspective, I assume it would make more sense to return all brands instead of just selecting 5 out of them. This will allow us to make more informed decisions. 
* "Receipts scanned" is determined by counting transactions (i.e., SCAN_DATE) per brand.
* Birth Date: If BIRTH_DATE is missing, that user is excluded from age-based calculations.
* Receipts scanned should have a date in the TRANSACTION_TAKEHOME table.
*/

/*Calculating account's age*/
WITH account_age AS (
    SELECT id,
           (strftime('%Y-%m-%d', 'now') - strftime('%Y-%m-%d', created_date)) AS account_age_months
    FROM USER_TAKEHOME
)

 /*1. rank all brands by number total sales
  2. use only data of users with account >= 6 month
  3. remove rows that contain empty brand values or final_quantity ='zero'*/
, ranked_sales as(
    SELECT p.BRAND, SUM(t.FINAL_QUANTITY) AS total_sales,
         row_number() over(order by SUM(t.FINAL_QUANTITY) desc) sels_rank
    FROM TRANSACTION_TAKEHOME t
    JOIN account_age u ON t.USER_ID = u.id
    JOIN PRODUCTS_TAKEHOME p ON t.BARCODE = p.BARCODE
    WHERE u.account_age_months >= 6 and brand != '' and final_quantity != 'zero'
    GROUP BY p.BRAND
)

/* return the brands that have the top 5 total sales. In case more than 5 brands are in the top 5, all brands will be returned*/      
SELECT brand as top_selling_brands
from ranked_sales
where total_sales>= (select total_sales from ranked_sales where sels_rank =5)

