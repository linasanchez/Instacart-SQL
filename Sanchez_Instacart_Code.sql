#Preparation: Joining order_products_train and order_products__ prior tables
create view Totalreordered as
(
select order_id, product_id, add_to_cart_order, reordered
from (
select order_id, product_id, add_to_cart_order, reordered
from order_products_train
UNION ALL
select order_id, product_id, add_to_cart_order, reordered
from order_products__prior
)subquery
order by order_id, product_id, add_to_cart_order, reordered);

create table Totreorder
select * from Totalreordered;

#Q1. Which weekday (including weekends) has the highest number of orders? Which weekday has the lowest number of orders? 
With T1 as
(
Select order_dow, count(order_id) as NumOrders,
RANK() OVER(ORDER BY count(order_id) desc) as highestnumber,
RANK() OVER(ORDER BY count(order_id)) as lowestnumber
From orders
group by order_dow
)
Select *
FROM T1
Where highestnumber = 1 or lowestnumber = 1;

#Q2. What percentage of orders are made during daytime (8am-5pm)? Round the result to 2 digits to decimal.
With OrdersDaytime as
(
select order_hour_of_day, count(order_id) as NumDayOrders
from orders
where order_hour_of_day>=08 and order_hour_of_day<17
),
TotOrders as 
(
select order_hour_of_day, count(order_id) as TotNumOrders
from orders
)
select round(100*NumDayOrders/ (TotNumOrders),2) as OrdersPercentage
from OrdersDaytime o join TotOrders t on o.order_hour_of_day = t.order_hour_of_day;

#Q3. (a) If the company wants to give discount for customers’ reorders. At what time should the company launch the discount event? 
#Find the top 3 prime times for re-orders. Prime time is measured by the reorder counts. Your results should look like Wednesday 3am, etc.
Create view TimeEvent as
(
select order_dow, order_hour_of_day, count(*) as Treorder
from orders
where days_since_prior>=0
group by order_dow, order_hour_of_day
order by Treorder desc limit 3);

select order_hour_of_day,
case when order_dow = 0 then 'Saturday'
when order_dow = 1 then 'Sunday'
when order_dow = 2 then 'Monday'
when order_dow = 3 then 'Tuesday'
when order_dow = 4 then 'Wednesday'
when order_dow = 5 then 'Thursday'
when order_dow = 6 then 'Friday'
else '' end,
case when order_hour_of_day= 0 then concat((order_hour_of_day+12), 'am')
when order_hour_of_day=12 then concat((order_hour_of_day), 'pm')
when order_hour_of_day>12 then concat((order_hour_of_day-12), 'pm')
when order_hour_of_day<12 then concat((order_hour_of_day), 'am')
else '' end
from TimeEvent;

#(b). The company wants to attract new customers by launching promotion events. 
#At what time should the company launch the promotion to customers who place his/her first order? Find the top 3 prime times for customers’ first orders
Create view FirstOrders as
(
select order_dow, order_hour_of_day,count(user_id) as CustFirstOrder
from orders
where order_number = 1
group by order_dow, order_hour_of_day
order by CustFirstOrder desc limit 3);

select order_hour_of_day,
case when order_dow = 0 then 'Saturday'
when order_dow = 1 then 'Sunday'
when order_dow = 2 then 'Monday'
when order_dow = 3 then 'Tuesday'
when order_dow = 4 then 'Wednesday'
when order_dow = 5 then 'Thursday'
when order_dow = 6 then 'Friday'
else '' end,
case when order_hour_of_day= 0 then concat((order_hour_of_day+12), 'am')
when order_hour_of_day=12 then concat((order_hour_of_day), 'pm')
when order_hour_of_day>12 then concat((order_hour_of_day-12), 'pm')
when order_hour_of_day<12 then concat((order_hour_of_day), 'am')
else '' end
from FirstOrders;

#Q4. How often do the users reorder items? To answer this question, you need to show the number of users reorder items for each days_since_prior
select days_since_prior, count(*) as ReorderedItems 
from orders
where days_since_prior <> ''
group by days_since_prior
order by days_since_prior;

#Q5. Show how many customers reorder once in every week, two weeks, three weeks, or once in every month, etc. 
select 'reorder once in every week' as TimesReorder, count(*)
from orders
where days_since_prior between 0 and 7
union 
select 'reorder once in every two weeks' as TimesReorder, count(*)
from orders
where days_since_prior between 8 and 14
union
select 'reorder once in every three weeks' as TimesReorder, count(*)
from orders
where days_since_prior between 15 and 21
union
select 'reorder once in every month' as TimesReorder, count(*)
from orders
where days_since_prior>21;

#Q6 The company wants to know on average how many items and how many products users buy. Round the results to Integer. 
#Do you see the distributions are comparable between the train and prior order set? 
with Productsavg as
(
select order_id, count(distinct product_id) as Numproducts
from Totreorder
group by order_id
),
Itemsavg as
(
select order_id, max(add_to_cart_order) as Numitems
from Totreorder
group by order_id
)
select round(avg(Numproducts)) as AvgProductsBought,
		round(avg(Numitems)) as AvgitemsBought
from Productsavg p join Itemsavg i on p.order_id=i.order_id;

with ProductItemsavg as
(
select order_id, max(add_to_cart_order) as Numitems, count(distinct product_id) as Numproducts
from order_products_train
group by order_id
)
select round(avg(Numproducts)) as AvgProductsBought,
		round(avg(Numitems)) as AvgitemsBought
from ProductItemsavg;

with ProductItemsavg as
(
select order_id, max(add_to_cart_order) as Numitems, count(distinct product_id) as Numproducts
from order_products__prior
group by order_id
)
select round(avg(Numproducts)) as AvgProductsBought,
		round(avg(Numitems)) as AvgitemsBought
from ProductItemsavg;

#Q7. What are the top 10 products most often ordered? Show the product names of these products. 
#Note: You need to add the results order_products_prior and order_products_train tables. 
With T1 as
(
select product_id, count(*) as TimesOrdered
from order_products_train
group by product_id
order by TimesOrdered desc
),
T2 as (
select product_id, count(*) as TimesOrdered
from order_products__prior
group by product_id
order by TimesOrdered desc
)
select product_name, T1.TimesOrdered+T2.TimesOrdered as TotTimesOrdered
from T1 join products p on T1.product_id=p.product_id join T2 on p.product_id=T2.product_id
group by product_name
order by TotTimesOrdered desc limit 10;

#Q8. For each of the top 5 users who placed the highest number of orders, what is the average days interval of this user’s orders? 
with Top5Users as
(
select user_id, count(*) as NumOrders
from orders
group by user_id
order by NumOrders desc limit 5
)
select t.user_id, round(avg(days_since_prior),2) as AvgInterval
from Top5Users t join orders o on t.user_id=o.user_id
where days_since_prior <> ''
group by t.user_id;

#Q9. Show days_since_prior and the average reorder rate of each days_since_prior. 
#Round the average of reordered as 2 digits to decimal. Sort the result set by days_since_prior
With NumberReorders as 
(
select order_id, days_since_prior, count(*) as ReorderedItems 
from orders
where days_since_prior <> '' and eval_set = 'prior'
group by days_since_prior
order by days_since_prior
),
TotalOrders as
(
select order_id, days_since_prior, count(*) as TotItems 
from orders
group by days_since_prior
order by days_since_prior
)
select n.days_since_prior, round(avg(ReorderedItems/TotItems),2) as AvgReorderRate
from NumberReorders n join TotalOrders t on n.order_id=t.order_id
group by n.days_since_prior
order by n.days_since_prior;

#Q10. We want to know which product people put into the cart first if they buy products? 
#To answer this question, find the product_id, product_name, and the highest percentage of this product’s put-into-the-cart-first.
With FirstProd as
(
select product_id, count(*) as NumFirstProdCart
from totreorder
where add_to_cart_order = 1
group by product_id
order by NumFirstProdCart desc limit 1
)
select p.product_id, product_name, (100*NumFirstProdCart/count(p.product_id)) as highestpercentage
from FirstProd fp join products p on fp.product_id=p.product_id join totreorder tr on fp.product_id=tr.product_id;

#Q11. Are the top 5 products with the highest number of orders more likely to be reordered? 
#Note that if the proportion of reordered is >70%, then this product is more likely to be reordered. 
With T1 as
(
select product_id, count(*) as Numorders
from order_products_train
group by product_id
order by Numorders desc
),
T2 as
(
select product_id, count(*) as Numorders
from order_products__prior
group by product_id
order by Numorders desc
),
T3 as
(
select product_id, count(*) as Numreorders
from order_products_train
where reordered=1
group by product_id
),
T4 as
(
select product_id, count(*) as Numreorders
from order_products__prior
where reordered=1
group by product_id
)
Select T1.product_id, ((T3.Numreorders+T4.Numreorders)/(T1.NumOrders+T2.NumOrders))*100 as Prop_Reordered
from T1 join T2 on T1.product_id=T2.product_id join T3 on T1.product_id=T3.product_id join T4 on T1.product_id=T4.product_id 
order by T1.NumOrders+T2.NumOrders desc limit 5;

#Q12. Are organic products sold more often than non-organic products? You can solve this question by showing the percentage of orders that have organic products? 
#Product_name describes whether a product is organic or not. 
With Organic as
(
select product_name, count(t.product_id) as OrganicProducts
from products p join totreorder t on p.product_id=t.product_id
where product_name like '%organic%'
)
select (OrganicProducts/count(t.product_id))*100 as PercentagePurchOrganic
from Organic, totreorder t;

#Q13 How many unique products are offered in each department/aisle?
select department_id, aisle_id, count(product_id) as ProdsDeptAisle
from products
group by department_id, aisle_id
order by department_id, aisle_id;

#Q14 Find the top 10 best-sellers in each department.
with T1 as
(
select product_id, count(*) as Qsold
from order_products_train
group by product_id
),
T2 as
(
select product_id, count(*) as Qsold
from order_products__prior
group by product_id
),
T3 as
(
select department_id, T1.product_id, product_name, (T1.Qsold+T2.Qsold) as TotSold,
		rank() over(partition by department_id order by (T1.Qsold+T2.Qsold) desc) as TopPerDept
from T1 join products p on T1.product_id=p.product_id join T2 on T2.product_id=p.product_id
)
select department_id, product_id, product_name, TotSold, TopPerDept
from T3
where TopPerDept <= 10
order by department_id;

#Q15. Find the top 10 best-sellers in each aisle
with T1 as
(
select product_id, count(*) as Qsold
from order_products_train
group by product_id
),
T2 as
(
select product_id, count(*) as Qsold
from order_products__prior
group by product_id
),
T3 as
(
select aisle_id, T1.product_id, product_name, (T1.Qsold+T2.Qsold) as TotSold,
		rank() over(partition by aisle_id order by (T1.Qsold+T2.Qsold) desc) as TopPerAisle
from T1 join products p on T1.product_id=p.product_id join T2 on T2.product_id=p.product_id
)
select aisle_id, product_id, product_name, TotSold, TopPerAisle
from T3
where TopPerAisle <= 10
order by aisle_id;

#Q16. Show the number of new users (i.e., customers place the first orders), and the number of existing users, and the ratio of new users to existing users in each weekday.
#Which day has the highest ratio?
With NewUsers as 
(
select order_dow, count(*) as TotNewUsers
from orders
where order_number = 1
group by order_dow
),
OldUsers as 
(
select order_dow, count(*) as TotOldUsers
from orders
where order_number > 1
group by order_dow
)
select n.order_dow, TotNewUsers, TotOldUsers, (TotNewUsers/TotOldUsers) as RatioNewOld
from NewUsers n join OldUsers o on n.order_dow=o.order_dow
order by RatioNewOld desc;

#Q17. How many customers always reorder the same products all the time?
#To search the users you need to look at all orders (excluding the first order), where the percentage of reordered items is exactly 1. 
With UserOrders as 
(
select product_id, user_id, max(order_number)-1 as NumReorders, count(distinct o.order_id) as NumProducts
from orders o join totreorder tr on o.order_id=tr.order_id
where order_number>1 and reordered=1
group by product_id, user_id
)
select count(distinct user_id) as NumUsers
from UserOrders
where NumReorders=NumProducts;

#Q18. Segment the customers based on their average days of interval of reordering into 4 segments. Count the number of users in each segment.
With CustomerSegment as
(
select user_id, ntile(4) over(order by avg(days_since_prior)) as AvgDaysInterval
from orders
where days_since_prior <> ''
group by user_id
)
select AvgDaysInterval, count(*) as NumberOfUsers
from CustomerSegment
group by AvgDaysInterval;

#Q19 For those customers who reordered within 7 days, what are the most frequently reordered products? Show the top 5 products' product_id and product_name.
select p.product_id, product_name, count(*) as ReorderedProds
from orders o join Totreorder t on o.order_id=t.order_id join products p on t.product_id=p.product_id
where days_since_prior between 0 and 7 and reordered = 1
group by p.product_id, product_name
order by ReorderedProds desc limit 5;

#Q20. The manager thinks that the longer the length of days interval between reorders, the more users will purchase in the next reorder. Do you agree with the manager? Explain why.
With QTrain as
(
select days_since_prior, o.order_id, max(add_to_cart_order) as O_Quantity
from order_products_train ot join orders o on ot.order_id=o.order_id
where days_since_prior <> ''
group by o.order_id
),
QPrior as
(
select days_since_prior, o.order_id, max(add_to_cart_order) as O_Quantity
from order_products__prior op join orders o on op.order_id=o.order_id
where days_since_prior <> ''
group by o.order_id
),
QPriorTrain as
(
select days_since_prior, order_id, O_Quantity
from QTrain
union
select days_since_prior, order_id, O_Quantity
from QPrior
),
QPriorTrain_2 as
(
select days_since_prior, O_Quantity, count(order_id) as NumOrders
from QPriorTrain
group by days_since_prior, O_Quantity
)
select days_since_prior, (sum(O_Quantity*NumOrders)/sum(NumOrders)) as AvgQPurchased
from QPriorTrain_2
group by days_since_prior
order by days_since_prior;







