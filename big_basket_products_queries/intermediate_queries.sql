--Identify the brand with the highest average rating for its products.
select top 1 brand,avg(rating) as avg_rating
from big_basket_products
group by brand
order by avg_rating desc;
 

--Calculate the difference between market price and sale price for each product and find the product with the maximum difference.
  
  select top 1 product, (market_price -sale_price) as diff_btw_price
  from big_basket_products
  order by diff_btw_price desc;

--List the top 3 sub-categories with the highest average sale

select top 3 sub_category,avg(sale_price) as avg_sale
from big_basket_products
group by sub_category
order by avg_sale desc;
   

--Find the percentage of products that have a rating (i.e., non-null rating values).

with cte as
(
select count(*) as total_products 
,count(rating) as rated_product
from big_basket_products
)
select total_products,rated_product
,((rated_product*100)/total_products)as percent_with_rating
from cte;


--Find the top 3 brands with the most products listed.

select top 3 brand,count(product) as no_of_product_listed
from big_basket_products
group by brand
order by no_of_product_listed desc;


--Calculate the total sale price and total market price for each category.

select category, sum(sale_price) as total_sale, sum(market_price) as total_market_price
from big_basket_products
group by category;

--List the products that have a sale price higher than the average sale price of all products.

select product, sale_price
from big_basket_products
where sale_price> (select avg(sale_price)
from big_basket_products);


--Find the average rating of products for each brand that has more than 50 products listed.

select brand, avg(rating) as avg_rating
from big_basket_products
where brand in (select brand from big_basket_products  group by brand having count(*)> 50)
group by brand;
   

--Identify the products where the sale price is at least 20% less than the market price.

select product, sale_price
from big_basket_products
where sale_price <= market_price * 0.8;



--List the top 5 products with the highest price difference (market price - sale price) and their respective categories.*


select top 5 category, product, (market_price - sale_price) as price_diff
from big_basket_products
order by price_diff desc;
   

--Find the sub-category with the highest total sale price and the total sale price amount.

select top 1 sub_category, sum(sale_price) as total_sale_price
from big_basket_products
group by sub_category
order by total_sale_price desc;

   

--Calculate the average discount percentage for each category (discount percentage = (market price - sale price) / market price * 100).*
   
   select category, avg ((market_price - sale_price)/market_price*100) as avg_discount_percent
   from big_basket_products
   group by category;


--List the brands that have an average rating above 4 and have at least 10 products listed.

select brand, avg(rating) as avg_rating
from big_basket_products
group by brand
having avg(rating)> 4 and count(*)>=10;
   

--Identify the top 3 sub-categories with the lowest average rating, and include the number of products in each sub-category.*

select top 3 sub_category, avg(rating) as avg_rating, count(*) as no_of_product
from big_basket_products
where rating is not null
group by sub_category
order by avg_rating ;


--Find the most expensive product (based on sale price) in each sub-category.

with cte as
(
select  sub_category,max(sale_price) as max_price
from big_basket_products
group by sub_category
)
select b.sub_category, b.product, b.sale_price
from big_basket_products b
inner join cte on cte.sub_category=b.sub_category and cte.max_price=b.sale_price;
   
--Calculate the overall average sale price and average market price, and 
--then list the products where the sale price is above the overall average sale price and 
--the market price is below the overall average market price.


with avg_price as
(
select avg(sale_price) as avg_sale_price , avg(market_price) as avg_market_price
from big_basket_products
)
select product,sale_price,market_price
from big_basket_products,avg_price
where sale_price > avg_price.avg_sale_price and market_price<avg_price.avg_market_price;



--Calculate the cumulative sum of sale prices for products in each category, ordered by sale price within each category.
   
   select category,product, sale_price,
   sum(sale_price) over (partition by category order by sale_price) as cumumulative_sale_price
   from big_basket_products;



--Find the most popular product in each category based on the highest average rating, including the average rating.
   
   with cte as
   (
   select category,product,avg(rating) as avg_rating
   from big_basket_products
   where rating is not null
   group by category,product
   ),
  cte2 as ( select category, product , avg_rating,
  rank() over (partition by category order  by avg_rating desc) as rn
  from cte)
  select category, product,avg_rating
  from cte2
  where rn =1;
  

--3. *Identify the products where the sale price is at least 30% below the 
--average sale price of their respective sub-category.

with cte as
(
select sub_category,avg(sale_price) as avg_sub_saleprice
from big_basket_products
group by sub_category
)
select b.product ,b.sale_price, c.avg_sub_saleprice 
from big_basket_products b
inner join cte c on c.sub_category=b.sub_category
where b.sale_price<= c.avg_sub_saleprice * 0.7;


--Find the brands that have a standard deviation in sale price above 50 within their product range.*
   
select brand,stdev(sale_price) as saleprice_stddev
from big_basket_products
group by brand
having stdev(sale_price) > 50;


--Calculate the average discount percentage for each brand, 
--and find the top 3 brands with the highest average discount. 
--(discount percentage = (market price - sale price) / market price * 100)*

select top 3 brand, avg((market_price - sale_price) / market_price * 100) as avg_discount_percent
from big_basket_products
group by brand
order by avg_discount_percent desc;

   

--Determine the category and sub-category with the highest average rating, along with the average rating value.*
   
   select top 1 category, sub_category, avg(rating) as avg_rating
   from big_basket_products
   group by category, sub_category
   order by avg_rating desc;

--Identify the top 5 products with the largest variation in price (market price - sale price) within each category,
--and list their category, product name, and price difference.

with cte as
(
select category, product, (market_price - sale_price) as price_difference,
row_number() over ( partition by category order by (market_price - sale_price) desc) as rn
from big_basket_products
)
select category, product, price_difference
from cte
where rn<=5;   

--Find the brands that have at least one product in the top 5 highest-rated products 
--and at least one product in the bottom 5 lowest-rated products.

with cte1 as
(
select top 5 brand, product,rating
from big_basket_products
order by rating desc
),
cte2 as
(
select top 5 brand,product,rating
from big_basket_products
where rating is not null
order by rating asc
)
select distinct cte1.brand
from cte1 
inner join cte2 on cte1.brand=cte2.brand;


                                                                                                                                       