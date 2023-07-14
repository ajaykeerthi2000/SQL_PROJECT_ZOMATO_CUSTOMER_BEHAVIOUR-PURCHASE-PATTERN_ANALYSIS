
-- Create goldusers_signup table
DROP TABLE IF EXISTS goldusers_signup;
CREATE TABLE goldusers_signup (
  userid INT,
  gold_signup_date DATE
);

-- Insert data into goldusers_signup table
INSERT INTO goldusers_signup (userid, gold_signup_date)
VALUES 
  (1, '2017-09-22'),
  (3, '2017-04-21');

-- Create users table
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  userid INT,
  signup_date DATE
);

-- Insert data into users table
INSERT INTO users (userid, signup_date)
VALUES 
  (1, '2014-09-02'),
  (2, '2015-01-15'),
  (3, '2014-04-11');

-- Create sales table
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  userid INT,
  created_date DATE,
  product_id INT
);

-- Insert data into sales table
INSERT INTO sales (userid, created_date, product_id)
VALUES 
  (1, '2017-04-19', 2),
  (3, '2019-12-18', 1),
  (2, '2020-07-20', 3),
  (1, '2019-10-23', 2),
  (1, '2018-03-19', 3),
  (3, '2016-12-20', 2),
  (1, '2016-11-09', 1),
  (1, '2016-05-20', 3),
  (2, '2017-09-24', 1),
  (1, '2017-03-11', 2),
  (1, '2016-03-11', 1),
  (3, '2016-11-10', 1),
  (3, '2017-12-07', 2),
  (3, '2016-12-15', 2),
  (2, '2017-11-08', 2),
  (2, '2018-09-10', 3);

-- Create product table
DROP TABLE IF EXISTS product;
CREATE TABLE product (
  product_id INT,
  product_name TEXT,
  price INT
);

-- Insert data into product table
INSERT INTO product (product_id, product_name, price)
VALUES
  (1, 'p1', 980),
  (2, 'p2', 870),
  (3, 'p3', 330);




select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;








1		WHAT IS THE TOTAL AMOUNT EACH CUSTOMER SPENT ON ZOMOTO ?

SELECT s.userid, SUM(p.price) AS total_amount
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
GROUP BY s.userid;

2		HOW MANY DAYS HAS EACH CUSTOMER VISITED ZOMATO ?
Select userid , count(created_date) as No_of_visited from sales group by userid

3		WHAT IS THE FIRST PRODUCT PURCHASED BY EACH CUSTOMER

select userid,product_id from 
(select * , rank () over ( partition by userid order by created_date ) as rnk from sales) as a  where rnk=1

4		WHAT IS THE MOST PURCHASED ITEM ON THE MENU AND HOW MANY TIMES WAS IT PURCHSED BY ALL CUSTOMERSS ?

SELECT userid, COUNT(product_id)
FROM sales
WHERE product_id = (
    SELECT product_id
    FROM sales
    GROUP BY product_id
    ORDER BY COUNT(product_id) DESC
    LIMIT 1
)
GROUP BY userid;

5		WHICH ITEM WAS THE MOST POPULAR FOR EACH CUSTOMER ?

select * from
(select *, rank() over (partition by userid order by cnt desc) as rnk from
(select userid, product_id, count(product_id) as cnt from sales group by userid ,product_id) as a) b where rnk=1

6		WHICH ITEM WAS PURCAHSED FIRST BY THE CUSTOMER AFTER THEY BECOME GOLG MEMBER ?


select * from
(select c.*, rank () over( partition by userid  order by created_date) as rnk from 
(select s.userid,created_date,g.gold_signup_date, s.product_id 
 from sales as s join goldusers_signup as g on s.userid=g.userid and created_date>gold_signup_date ) c ) d where rnk=1


7		WHICH ITEM WAS  PURCHASED JUST BEFORE THE CUSTOMER BECAME GOLD MEMBER ?

Select * from
(select c.*, rank () over( partition by userid  order by created_date desc) as rnk from 
(select s.userid,created_date,g.gold_signup_date, s.product_id 
 from sales as s join goldusers_signup as g on s.userid=g.userid and created_date<gold_signup_date ) c ) d Where rnk=1
 
 
 8		WHAT IS THE TOTAL ORDERS AND AMOUNT SPENT FOR EACH MEMBER BEFORE THEY BECAME A GOLD MEMBER ?

 select userid, count(created_date) as no_of_orders ,sum(price) as total_amt from
(select c.* , p.price from
(select s.userid,created_date,g.gold_signup_date, s.product_id 
 from sales as s join goldusers_signup as g on s.userid=g.userid and created_date<gold_signup_date) c join product p on 
 c.product_id=p.product_id) as d group by userid 


9		IF BUYING EACH PRODUCT GENERATES POINTS FOR EX:5Rs=2 POINTS  AND EACH PRODUCT HS DIFFERENT PURCHASING POINTS FOR EX:
		PRODUCT P1---5Rs=1 ZOMATO POINT
        PRODUCT P2---10Rs=2 ZOMATO POINT ====2rs=1zomto point
        PRODUCT P1---5Rs=1 ZOMATO POINT
		NOW CALCULATE POINTS COLLECTED BY EACH CUSTOMER AND FOR WHICH PRODUCT MOST POINTS HAVE BEEN GENERATED TILL NOW  ?
        
        
	/* Total no of points earned by each customer*/
select userid, sum(total_points_earned) from
( select e.*, round(amt/points,1) total_points_earned from
( select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end  as points from
( select c.userid, c.product_id , sum(price) amt from
(select a.*, b.price from sales a join product b on a.product_id=b.product_id) as c group by userid , product_id) as d) as e)as f
group by userid order by userid


			/*PRODUCT MOST POINTS HAVE BEEN GENERATED TILL NOW*/
select * from
(select *,rank () over( order by total_points_earned desc ) as rnk from
(select product_id, sum(total_points_earned) total_points_earned from
( select e.*, round(amt/points,1) total_points_earned from
( select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end  as points from
( select c.userid, c.product_id , sum(price) amt from
(select a.*, b.price from sales a join product b on a.product_id=b.product_id) as c group by userid , product_id) as d) as e)as f
group by product_id) as g) h where rnk=1


10.Q 		IN THE FIRST ONE YEAR AFTER A CUSTOMER JOINS THE GOLD PROGRAM (INCLUDING THEIR JOIN DATE ) IRRESPECTIVE OF WHAT THE CUSTOMER HAS PURCHASED THEY EARN 5 ZOMATO POINTS FOR EVERY 10RS SPENT WHO EARNED MORE 1 (USERID) OR 3(USERID) AND WHAT WAS THEIR POINTS EARNINGS IN THEIR FIRST YEAR ?
        
							(1ZOMATO POINT =2Rs THEN 0.5ZP=1Rs)
select c.*, d.price*0.5 as total_points_earned from  
(select a.userid,a.created_date,b.gold_signup_date, a.product_id from sales as a inner join goldusers_signup as b on a.userid=b.userid and created_date>=gold_signup_date and created_date>=DATE_ADD(gold_signup_date, INTERVAL 1 YEAR)) c join product d on c.product_id=d.product_id
			
        
11Q . 		RANK ALL THE TRASACTIONS OF THE CUSTOMERS 
        
select * , rank () over(partition by userid order by created_date) rnk from sales
            
12Q.		RANK ALL THE TRASACTIONS FOR EACH WHENEVER THEY ARE A ZOMATO GOLD MEMBER FOR EVERY NON GOLD TRASACTION MARK AS NA

 select e.*, case when rnk=0 then 'NA' else cast(rnk as char) end rnk from
 (select c.*, case when gold_signup_date is null then 0 else rank() over (partition by userid order by created_date desc) end as rnk from
 (select a.userid,created_date, a.product_id ,b.gold_signup_date from sales as a LEFT join goldusers_signup as b on a.userid=b.userid and created_date>=gold_signup_date)c)e       
		
          