CREATE DATABASE SQL_RETAIL;

USE SQL_RETAIL;

SELECT * FROM [dbo].[Customer]
SELECT * FROM [dbo].[prod_cat_info]
SELECT * FROM [dbo].[Transactions]

 --DATA PREPRATION AND UNDERSTANDING

--1) TOTAL NO. OF ROWS IN EACH OF THE 3 TABLES
 SELECT 'Customer' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Customer
 UNION ALL
 SELECT 'prod_cat_info' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM prod_cat_info
 UNION ALL
 SELECT 'Transactions' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Transactions;

--2)total number of transactions that have a return
SELECT * FROM Transactions 
WHERE CONVERT(float,total_amt) < 0;

--3)conversion of date into correct format
select tran_date,
CONVERT(Date,tran_date,105) as transaction_date
from Transactions;

--4) show output in no. of days, months, years
 select
CONVERT(Date,tran_date,105) as transaction_date,
datepart(day, CONVERT(Date,tran_date,105)) as day_transaction_date,
datepart(month,CONVERT(Date,tran_date,105)) as month_transaction_date,
datepart(year,CONVERT(Date,tran_date,105)) as year_transaction_date
from Transactions

--5) which prod_cat does the sub_cat 'DIY' belongs to
select prod_cat from prod_cat_info
where prod_subcat = 'DIY'

-- DATA ANALYSIS
--1) Which channel is most used for transactions?
SELECT TOP 1 Store_type FROM(
SELECT 
count(transaction_id) as no_of_transactions,
Store_type
FROM Transactions
group by Store_type) AS T1
order by no_of_transactions desc;

--2) count of male and female customers 
SELECT 
COUNT(customer_Id) as no_of_male_female, Gender
FROM Customer
GROUP BY Gender
ORDER BY no_of_male_female DESC;

--3) which city have maximum no of customers and how many
SELECT TOP 1 * FROM (
SELECT 
COUNT(city_code) as no_of_cities, city_code
FROM Customer
GROUP BY city_code ) AS T1
ORDER BY no_of_cities DESC;

--4) how many sub-categories under the book category
SELECT
count(prod_subcat) as no_subcat
FROM prod_cat_info
WHERE prod_cat = 'Books'

--5)maximum quantity of products ever ordered
select max(Qty) as maximum_qty
from Transactions;

--6)net total revenue generated in electronics and books
select 
prod_cat_code,
sum(cast(total_amt as float)) as net_revenue
from Transactions
where prod_cat_code in ( 
select 
prod_cat_code
from prod_cat_info
where prod_cat in ('Electronics', 'Books'))
group by prod_cat_code

--7) how many customers have greater than 10 transactions
select count(cust_id) as no_of_customers from (
select cust_id, count(transaction_id) as no_of_transactions
from Transactions
group by cust_id
having count(transaction_id) > 10 ) as t1

--8)combined revenue earned from electronics and clothing from flagships store
select sum(convert(float,total_amt)) as combined_revenue from Transactions where prod_cat_code in (
select prod_cat_code from prod_cat_info
where prod_cat in ('Clothing', 'Electronics')) and Store_type = 'Flagship store'

--9) total revenue generated from male customers in electronics category. output should be displayed by prod_subcat
select 
prod_subcat,
sum(cast(total_amt as float)) as total_revenue
from Transactions tbl1
inner join prod_cat_info tbl2 on
tbl1.prod_cat_code = tbl2.prod_cat_code and tbl1.prod_subcat_code = tbl2.prod_sub_cat_code
where prod_cat = 'Electronics' and cust_id in ( select customer_Id from Customer where Gender = 'M')
group by prod_subcat

--10) percentage of sales and return by prod_subcat, display top 5 in terms of sales
select prod_subcat,
sum(convert(float,abs(total_amt)))/(select sum(convert(float,abs(total_amt))) from Transactions where Qty > 0) as percentage_sales,
sum(convert(float,abs(total_amt)))/(select sum(convert(float,abs(total_amt))) from Transactions where Qty < 0) as percentage_returns
from Transactions as t1 inner join prod_cat_info as t2 
on t1.prod_cat_code = t2.prod_cat_code and t1.prod_subcat_code = t2.prod_sub_cat_code
group by prod_subcat
order by percentage_sales

select prod_subcat,
sum(convert(float,abs(total_amt)))/(select sum(convert(float,abs(total_amt))) from Transactions)  as percentage_sales
from Transactions as t1 inner join prod_cat_info as t2 
on t1.prod_cat_code = t2.prod_cat_code and t1.prod_subcat_code = t2.prod_sub_cat_code
where Qty > 0
group by prod_subcat

select prod_subcat,
sum(convert(float,abs(total_amt)))/(select sum(convert(float,abs(total_amt))) from Transactions)  as returns_sales
from Transactions as t1 inner join prod_cat_info as t2 
on t1.prod_cat_code = t2.prod_cat_code and t1.prod_subcat_code = t2.prod_sub_cat_code
where Qty < 0
group by prod_subcat

--11) 
select 
sum(convert(float, total_amt)) as total_revenue
from Customer as t1 left join Transactions as t2 on t1.customer_Id = t2.cust_id
where
DATEDIFF(year,convert(date,DOB,105),GETDATE()) >= 25 and DATEDIFF(year,convert(date,DOB,105),GETDATE()) <= 35
AND
DATEDIFF(DAY,convert(date,tran_date,105),(select max(convert(date,tran_date,105)) from Transactions)) <=30

--12)
select top 1 prod_cat from (
select prod_cat, sum(convert(int,Qty)) as returns_qty
from prod_cat_info as t1 inner join Transactions as t2
on t1.prod_cat_code = t2.prod_cat_code and t1.prod_sub_cat_code = t2.prod_subcat_code
where Qty < 0 and
DATEDIFF(MONTH,CONVERT(date,tran_date,105),month(getdate()))< 3
group by prod_cat) as t1
order by returns_qty asc

--13) which store-type sells maximum product, by value of sales amount and by quantity sold
select top 1 Store_type from (
select 
Store_type, sum(convert(float,total_amt)) as sales_amount, count(Qty) as quanity_sold
from Transactions
group by Store_type ) as tbl1
order by sales_amount desc, quanity_sold desc

--14) categories for which  average revenue is above the overall average.
select prod_cat, avg(convert(float,total_amt)) as average_revenue 
from prod_cat_info as t1 left join Transactions as t2 
on t1.prod_cat_code = t2.prod_cat_code and t1.prod_sub_cat_code = t2.prod_subcat_code
group by prod_cat
having avg(convert(float,total_amt)) > (select avg(convert(float,total_amt)) from Transactions)

--15) find avg revenue & total revenue by each sub category for the categories which are among top 5 categories in terms of quantity sold.
select prod_subcat, avg(convert(float,total_amt)) as average_revenue, sum(convert(float,total_amt)) as total_revenue
from prod_cat_info as t3 inner join Transactions as t4 
on t3.prod_cat_code = t4.prod_cat_code and t3.prod_sub_cat_code = t4.prod_subcat_code
where prod_cat in (select top 5 prod_cat
from prod_cat_info as t1 inner join Transactions as t2 
on t1.prod_cat_code = t2.prod_cat_code and t1.prod_sub_cat_code = t2.prod_subcat_code
group by prod_cat
order by sum(convert(int,Qty)) desc)
group by prod_subcat