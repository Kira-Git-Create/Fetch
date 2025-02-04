/*Question: At what percent has Fetch grown year over year?
Answer:
Year over year growth can be used to calculate the growth of different business metrics, including: revenue, user acquisition, transaction volume etc. 
Given the limitations of the provided data, I will focus on measuring YoY for user acquisition. 
Assumptions:
* Calculation - Yearly growth is calculated as the percentage increase in new users compared to the previous year.
* User acquisition is measured based on CREATED_DATE (the date when a user signed up) .If any CREATED_DATE is missing, those users are excluded from the analysis
* Any inactive or churned users are not considered—I only focus on new sign-ups per year
* Time Frame - Annual user acquisition trends are meaningful. It could be that shorter term trends (monthly / quarterly) make more sense for fetch.
* If CREATED_DATE is missing, the user is excluded from the analysis.
* Since there is no prior year to compare to, the first recorded year is excluded from the final results
* The dataset contains users from multiple years, allowing a valid YoY comparison.
* User acquisition - Counting ids  per year accurately represents new users acquire, IDs are unique 
* Granularity - This is a high level YoY growth metric, ignoring different segmentation such as - geo, user age and active users. The breakdowns could add valuable information.
*/

-- count newly acquired users per year
WITH User_Yearly_Count AS (
    SELECT strftime('%Y', CREATED_DATE) AS Year, COUNT(ID) AS New_Users
    FROM USER_TAKEHOME
    WHERE CREATED_DATE IS NOT NULL
    GROUP BY Year
),
--Calculate yearly growth
Growth_Calculation AS (
    SELECT Year,
           New_Users,
           LAG(New_Users) OVER (ORDER BY Year) AS Previous_Year_Users,
           CASE
               WHEN LAG(New_Users) OVER (ORDER BY Year) IS NULL THEN NULL  -- First year has no comparison
               WHEN LAG(New_Users) OVER (ORDER BY Year) = 0 THEN NULL  -- Previous year had zero users, growth could be viewed as Null or infinite  
    ELSE ROUND((New_Users - LAG(New_Users) OVER (ORDER BY Year)) * 100.0 / LAG(New_Users) OVER (ORDER BY Year), 2)
           END AS YoY_Growth_Percentage
    FROM User_Yearly_Count
)
SELECT round(avg(YoY_Growth_Percentage),2) Avg_YoY_Growth -- round YoY to 2 decimal places
FROM
  (SELECT Year, New_Users, Previous_Year_Users, YoY_Growth_Percentage
  FROM Growth_Calculation
   -- Show only results from the second year onward, since first year has no prior comparison 
  WHERE Previous_Year_Users IS NOT NULL)subq
