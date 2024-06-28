

--Retrieve all columns for all products.

select * 
from big_basket_products
   
   
--List all unique product categories.

select distinct category
from big_basket_products
   

--Find the total number of products in the dataset.
select count(*)
from big_basket_products
  

--Retrieve the product name and sale price of the products that have a rating above 4.
  
  select product,sale_price
  from big_basket_products
  where rating>4


--Calculate the average sale price of products in the 'Beauty & Hygiene' category.

select avg(sale_price) as avg_sale_price
from big_basket_products
 where category='beauty & hygiene'

--List the top 5 most expensive products based on sale price.

select top 5 product, sale_price
from big_basket_products
order by sale_price desc

--Count the number of products in each sub-category.

select sub_category,count(*) as no_of_products
from big_basket_products
group by sub_category


