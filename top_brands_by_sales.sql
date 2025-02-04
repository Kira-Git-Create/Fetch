/*Question: What are the top 5 brands by sales among users that have had their account for at least six months?
Assumptions:
* “Top 5 brands by sales”: We are counting sold quantity and not revenue.
Both could be valuable, however due to data constraints, a calculation would be provided only for sold quantities.
FINAL_SALE value is not on the brand level, but on the transaction level, meaning might include additional items. 
FINAL_QUANTITY is on the barcode level, and would point to the brand.
* When ranking the brands by sold quantity, more than 5 brands could share the same count. 
From a business perspective, I assume it would make more sense to return all brands instead of just selecting 5 out of them. This will allow us to make more informed decisions.
* FINAL_QUANTITY is stored correctly as a numerical value.
* Account Age: created_date contains valid values and is populated. Users without ‘created_date’ would be excluded from the analysis.
*/


/* find user's age based on the provided birth date*/
WITH user_age AS (
    SELECT ID,
           (strftime('%Y', 'now') - strftime('%Y', BIRTH_DATE)) AS age
    FROM USER_TAKEHOME
)
 
 /*1. rank all brands by number of receipts
  2. use only data for users 21 or older
  3. remove rows that contain empty brand values*/
, ranked_recipts as(      
      SELECT p.BRAND, COUNT(t.SCAN_DATE) AS total_scanned,
        row_number() over(order by COUNT(t.SCAN_DATE) desc) scan_rank
    FROM TRANSACTION_TAKEHOME t
    JOIN user_age u
    ON t.USER_ID = u.ID
    JOIN PRODUCTS_TAKEHOME p
    ON t.BARCODE = p.BARCODE
    WHERE u.age >= 21 and brand != ''
    GROUP BY p.BRAND)
   
/* return the brands that have the top 5 receipt count. In case more than 5 brands are in the top 5 receipts count, all brands will be returned*/      
SELECT brand as top_receipt_scanned_brands
from ranked_recipts
where total_scanned >= (select total_scanned from ranked_recipts where scan_rank =5)
