--Calculate the moving average of the sale price over the last 5 entries for each category, 
--ordered by the sale price.

select category, product, sale_price,
avg(sale_price) over (partition by category order by sale_price rows between 4 preceding and current row)
as moving_avg_saleprice
from big_basket_products;

  
--Identify the top 3 categories with the most significant increase in average sale price
--compared to the average market price.*

with cte1 as
(
select category, avg(sale_price) as avg_sale_price,
avg(market_price) as avg_market_price
from big_basket_products
group by category
)
select top 3 category,(avg_sale_price - avg_market_price) as price_diff
from cte1
order by price_diff desc;


--For each sub-category, find the product with the maximum rating and the product with the
--minimum rating, and include their sale prices.


with cte1 as
(
select sub_category, product as max_rating_p,
sale_price as max_rating_s,rating,
row_number() over (partition by sub_category order by rating desc) as rn
from big_basket_products
),
cte2 as
(
select sub_category,product as min_rating_p,
sale_price as min_ratig_sale, rating,
row_number() over (partition by sub_category order by rating asc) as rn
from big_basket_products
)
select cte1.sub_category, cte1.max_rating_p,cte1.max_rating_s, cte2.min_ratig_sale, cte2.min_rating_p 
from cte1
inner join cte2 on cte1.sub_category=cte2.sub_category
where cte1.rn=1 and cte2.rn=1;

   

--Find the top 5 products with the highest rating-to-price ratio in each category 
--(rating / sale price), including their category, product name, rating, and sale price.*
   
   with cte1 as
   (
   select category, product, rating,sale_price, (rating/sale_price)as rp_ratio,
   row_number() over (partition by category order by (rating/sale_price) desc) as rn
   from big_basket_products
   ) 
   select category, product, rating, sale_price, rp_ratio
   from cte1
   where rn<=5;
   

--Calculate the percentage contribution of each sub-category to the total sales within
--its category and identify sub-categories contributing more than 25% of their category’s sales.

with cte1 as
(
select category, sum(sale_price) as category_sale
from big_basket_products
group by category
),
cte2 as
(
select category, sub_category, sum(sale_price) as subcategory_sale
from big_basket_products
group by category, sub_category
)
select cte2.category, cte2.sub_category,((subcategory_sale * 100)/category_sale) as percentage_cont
from cte2
inner join cte1 on cte1.category=cte2.category
where ((subcategory_sale * 100)/category_sale) > 25;
      

--Calculate the average sale price for each sub-category in each category, and find 
--sub-categories where the average sale price is greater than the average sale price
--of their parent category by more than 20%.*

with cte1 as
(
select category , avg(sale_price) as avg_category_sale
from big_basket_products
group by category
),
cte2 as
(
select category, sub_category, avg(sale_price) as avg_subcategory_sale
from big_basket_products
group by category, sub_category 
)
select cte2.category, cte2.sub_category,cte2.avg_subcategory_sale,cte1.avg_category_sale
from cte2
inner join cte1 on cte1.category = cte2.category
where avg_subcategory_sale > (avg_category_sale * 1.2);