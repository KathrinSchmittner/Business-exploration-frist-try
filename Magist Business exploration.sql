USE magist;

#Check out all tables:
select *
from customers;

select *
from geo;

select *
from order_items;
#shipping limit date? 
#freight value? -> price paid or payable to the exporter for the cargo when it is unloaded from the shipper at the port when imported
#price

select *
from order_payments;
#payment value? -> Payment Value means the dollar amount assigned to a Performance Share which shall be 
#equal to the Fair Market Value per Share on the close of business on the last day of a Performance Cycle.

select *
from order_reviews;
#review score

select *
from orders;
#order status
#order_id

select *
from product_category_name_translation;

select *
from products;
# product_category_name

select *
from sellers;


### In relation to the products:

##What categories of tech products does Magist have? -> eletronicos, informatica_acessorios, pcs, telefonia, consoles_games, pc_gamer
select count(*)
from product_category_name_translation;

##How many products of these tech categories have been sold (within the time window of the database snapshot)? -> 16488 tech products products
#Using order_id to count sold products
#join products table (for product cathegories) with order_items table (order_id)

#By cathegory:
select 
p.product_category_name, 
count(order_id) as tech_products_sold
from products p
left join order_items oi 
on p.product_id=oi.product_id
where p.product_category_name="consoles_games" 
or p.product_category_name="eletronicos" 
or p.product_category_name="pcs"
or p.product_category_name="informatica_acessorios"
or p.product_category_name="telefonia"
or p.product_category_name="pc_gamer"
group by p.product_category_name
order by tech_products_sold desc;

#Total tech sold:
select 
count(order_id) as tech_products_sold
from products p
left join order_items oi 
on p.product_id=oi.product_id
where p.product_category_name="consoles_games" 
or p.product_category_name="eletronicos" 
or p.product_category_name="pcs"
or p.product_category_name="informatica_acessorios"
or p.product_category_name="telefonia"
or p.product_category_name="pc_gamer";

##What percentage does that represent from the overall number of products sold? -> 15%
#Total tech sold from last quiery: 16488 items
#Total items sold:
select 
count(order_id) as total_products_sold
from products p
left join order_items oi 
on p.product_id=oi.product_id;
#112650 items sold total 

#Calculate percentage:
select
round((16488*100)/112650) AS percentage;

##What’s the average price of the products being sold? -> 121€
select 
round(avg(price)) as average_price
from order_items;

##Are expensive tech products popular? (function CASE when) -> YES
#1. Define "expensive tech", exclude categories below 100€ average -> categories "informatica_acessorios", "telefonia", "eletronicos" remain
#2. Popular? 
#2.1 Attempt 1: Make "popular and "unpopular" columns for high-tech reviews, add up counts and compare with total reviews (Did not work)
#2.2 Attempt 2: Check high-tech reviews and compare with potential highest review score 

#1.Define "expensive tech" -> Exclude cathegories with <100€ average
select
p.product_category_name,
round(avg(price)) as tech_products_avg_price
from products p
left join order_items oi 
on p.product_id=oi.product_id
where p.product_category_name="consoles_games" 
or p.product_category_name="eletronicos" 
or p.product_category_name="pcs"
or p.product_category_name="informatica_acessorios"
or p.product_category_name="telefonia"
or p.product_category_name="pc_gamer"
group by p.product_category_name
order by tech_products_avg_price desc;
#Exclude categories below 100€ average price, which are "informatica_acessorios", "telefonia", "eletronicos"

#2.Check if remaining tech cathegories have good reviews (defined good as 4 or 5 review score)
#Combine products table with order_reviews table: 
#No direct connection: products table to order items table (with product_id) to order reviews table (with order_id)

#2.1.
#Make Popular and Not populat column to count
select
p.product_category_name,
case
when r.review_score>=4 then 1
else 0
end as Popular,
case
when r.review_score<4 then 1
else 0
end as  Not_popular
from products p
left join order_items oi 
on p.product_id=oi.product_id
left join order_reviews r 
on oi.order_id=r.order_id
where p.product_category_name="consoles_games"
or p.product_category_name="pcs"
or p.product_category_name="pc_gamer";

#Count popularity, group in tech categories -> doesnt work
select
p.product_category_name,
case
when r.review_score>=4 then 1
else 0
end as popular,
case
when r.review_score<4 then 1
else 0
end as not_popular,
sum(popular),#this doesnt work
sum(not_popular)#this doesnt work
from products p
left join order_items oi 
on p.product_id=oi.product_id
left join order_reviews r 
on oi.order_id=r.order_id
group by p.product_category_name;

select
p.product_category_name,
sum(
case
when r.review_score>=4 then 1
else 0
end) as popular,
sum
(case
when r.review_score<4 then 1
else 0
end) as not_popular
from products p
left join order_items oi 
on p.product_id=oi.product_id
left join order_reviews r 
on oi.order_id=r.order_id
group by p.product_category_name;


#2.2 New approach: Sum up review scores: Compare actual review scores of high tech categories with potential highst outcome
#Actual high-tech review scores: 5412 points
#Potential highest high-tech review scores: 6730 points
#High-tech reviews scored 80% of max -> High-tech products are popular!

#High tech review scores: 5412 points
#Includes categories "consoles_games", "pcs" and "pc_gamer"
select
sum(review_score) as high_tech_review_score
from products p
left join order_items oi                                  
on p.product_id=oi.product_id
left join order_reviews r 
on oi.order_id=r.order_id
where p.product_category_name="consoles_games"
or p.product_category_name="pcs"
or p.product_category_name="pc_gamer";

#Potential highest high-tech review scores: 1346 high-tech review *5 = 6730 points
#Count order_id of high-tech category and multiply by 5 (5 points max per review)
select
count(review_score) as review_count
from products p
left join order_items oi 
on p.product_id=oi.product_id
left join order_reviews r 
on oi.order_id=r.order_id
where p.product_category_name="consoles_games"
or p.product_category_name="pcs"
or p.product_category_name="pc_gamer";

select
1346*5;

select
round((5412*100)/6730) AS percentage;


###In relation to the sellers:

##How many months of data are included in the magist database?
#Which column to use for date? Has to include everything, so first date entry and last date entry 
#-> "order_purchase_timestamp" and order_delivered_timestamp? delivery time short enough, will just use one column
select
year(order_purchase_timestamp) as year_,
month(order_purchase_timestamp) as month_
from orders
group by year_ , month_
order by year_ , month_ desc;
#-> but how to count??

SELECT 
    TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp))  AS months
FROM 
    orders;

##How many sellers are there? 3095 sellers
#Count seller_id
select
count(distinct seller_id)
from sellers;

##How many Tech sellers are there? -> 468 tech sellers
#Join sellers table & order_items table (seller_id) and order_items table and products tables (product_id)
#Which join: I want ALL tech sellers -> products is my main table
#Then count seller_id, just include tech categories
select
count(distinct seller_id)
from products p
left join order_items oi using(product_id)
left join sellers s using(seller_id)
where p.product_category_name="consoles_games" 
or p.product_category_name="eletronicos" 
or p.product_category_name="pcs"
or p.product_category_name="informatica_acessorios"
or p.product_category_name="telefonia"
or p.product_category_name="pc_gamer";

#What percentage of overall sellers are Tech sellers? 15%
select
round((468*100)/3095) AS percentage;

##What is the total amount earned by all sellers? -> 13591644€ (13.6 M)
#Sum up "price" to get the total amount of all sellers (no group by seller_id to see different sellers amounts)
select 
round(sum(price)) as total_amount_earned
from order_items;

##What is the total amount earned by all Tech sellers? -> 1777843€ (1.8 M)
#Sum up "price" to get the total amount of all tech categories
select 
round(sum(price)) as tech_amount_earned
from products p
left join order_items oi 
on p.product_id=oi.product_id
where p.product_category_name="consoles_games" 
or p.product_category_name="eletronicos" 
or p.product_category_name="pcs"
or p.product_category_name="informatica_acessorios"
or p.product_category_name="telefonia"
or p.product_category_name="pc_gamer";

##Can you work out the average monthly income of all sellers? - NO
#Define monthly income: price of orders in a month (avg)
select
round(avg(price)) as monthly_income_ALL
from order_items
group by YEAR(shipping_limit_date), MONTH(shipping_limit_date);

##Can you work out the average monthly income of Tech sellers? -NO


###In relation to the delivery time:

##What’s the average time between the order being placed and the product being delivered? 
#Between "order_purchase_timestamp" and "order_delivered_timestamp"
select
              
from orders;

##How many orders are delivered on time vs orders delivered with a delay? -> No delay 88649 vs With delay 7827
#Order_status
select
sum(
case
when order_delivered_customer_date-order_estimated_delivery_date=1 then 1
else 0
end) as No_Delay
from orders;

##Is there any pattern for delayed orders, e.g. big products being delayed more often?
select *
from product_category_name_translation;


##Other peoples code:
select

   COUNT(DISTINCT s.seller_id) as all_sellers, 
   COUNT(DISTINCT CASE WHEN pn.product_category_name_english IN ('audio' ,'consoles_games','electronics,computers_accessories','telephony')
   THEN s.seller_id END) as Tech_sellers,


    (COUNT(DISTINCT CASE WHEN pn.product_category_name_english IN ('audio' ,'consoles_games','electronics,computers_accessories','telephony') 
    THEN s.seller_id END) / COUNT(DISTINCT s.seller_id)) * 100 AS tech_sellers_percentage
     FROM 
    sellers s
left JOIN 
    order_items oi ON s.seller_id = oi.seller_id
right join 
    products p ON oi.product_id = p.product_id
 left JOIN 
    product_category_name_translation pn ON p.product_category_name = pn.product_category_name

 ;