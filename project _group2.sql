# Creating database
CREATE database project;
use project;
# Adding data using import wizard
# Also checked datatype while importing the data. 

# Part 1 – Sales and Delivery:
# Question 1: Find the top 3 customers who have the maximum number of orders

SELECT
cust_id,
customer_name 
FROM cust_dimen 
WHERE cust_id IN (SELECT cust_id FROM market_fact 
GROUP BY(cust_id)
ORDER BY count(cust_id) DESC ) LIMIT 3;

# Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.


SELECT 
O.Order_ID,
O.Order_Date, 
O.Order_Priority,
S.Ship_Mode,
S.Ship_Date,
S.Ship_id,
 datediff(S.ship_date,O.order_date) DaysTakenForDelivery 
FROM Orders_Dimen AS O
INNER JOIN Shipping_Dimen AS S
ON O.order_id=S.order_id;

 
# Question 3: Find the customer whose order took the maximum time to get delivered.

SELECT 
cd.cust_id, 
customer_name,
order_date, 
ship_date, 
datediff(ship_date, order_date) as order_deliver_in_days 
FROM cust_dimen cd JOIN market_fact mf ON cd.cust_id = mf.cust_id
JOIN orders_dimen od ON od.ord_id = mf.ord_id 
JOIN shipping_dimen sd ON sd.order_id = od.order_id 
ORDER BY order_deliver_in_days DESC LIMIT 1;

# Question 4: Retrieve total sales made by each product from the data (use Windows function)


SELECT 
pd.prod_id, 
product_category, 
product_sub_category, 
Sales, 
sum(Sales) over(partition by pd.Prod_id) as product_wise_total_Sales 
FROM prod_dimen pd JOIN market_fact mf ON pd.prod_id = mf.prod_id;   

# Question 5: Retrieve the total profit made from each product from the data (use windows function)

SELECT pd.prod_id, 
product_category, 
product_sub_category, 
Profit, 
sum(Profit) over(partition by product_sub_category) as product_wise_total_Profit 
FROM prod_dimen pd JOIN market_fact mf ON pd.prod_id = mf.prod_id;   

# Question 6: Count the total number of unique customers in January and how many of them came back 
# every month over the entire year in 2011

SELECT c.cust_id , c.customer_name, x.distinct_order_count FROM cust_dimen c,
(SELECT 
count(distinct(ord_id)) AS distinct_order_count, 
cust_id FROM market_fact 
WHERE Cust_id IN
(SELECT distinct(cust_id) FROM market_fact WHERE ord_id IN
(SELECT ord_id FROM orders_dimen WHERE date_format(order_date, '%m') ='01' and date_format(order_date, '%Y') ='2011') ) 
group by cust_id order by ord_id)as x where c.cust_id = x.Cust_id ;


# Part 2 – Restaurant:


# Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.


SELECT 
go.placeid, 
go.name, 
alcohol, 
count(userid) as Visitors 
FROM geoplaces2 go 
JOIN rating_final rf ON go.placeid = rf.placeid 
WHERE alcohol != 'No_Alcohol_Served' 
GROUP BY alcohol, go.placeid, go.name order by name ;


# Question 2: -Let's find out the average rating according to alcohol and price so that we
# can understand the rating in respective price categories as well.

SELECT 
G.alcohol, 
G.price, 
avg(R.rating) Rating
FROM geoplaces2 G 
JOIN Rating_final R
ON G.placeid=R.placeid
GROUP BY alcohol, price 
ORDER BY alcohol desc;


# Question 3:  Let’s write a query to quantify that what are the parking availability 
# as well in different alcohol categories along with the total number of restaurants.


SELECT 
G.alcohol, 
count(G.name) Number_of_restaurant,
Parking_lot Parking_availability
FROM geoplaces2 G JOIN Chefmozparking C 
ON G.placeid=C.placeid
GROUP BY alcohol, parking_lot order by alcohol;

# Question 4: -Also take out the percentage of different cuisine in each alcohol type.


SELECT 
go.Alcohol, 
Rcuisine, 
count(Rcuisine) cuisine_count, 
x.Total_Cuisine_For_Each_Alcohol_Type, 
round(((count(Rcuisine)/x.Total_Cuisine_For_Each_Alcohol_Type) * 100),2) as Percentage
FROM geoplaces2 go JOIN chefmozcuisine cc ON go.placeid = cc.placeid,
(SELECT alcohol, count(Rcuisine) Total_Cuisine_For_Each_Alcohol_Type FROM geoplaces2 gos 
JOIN chefmozcuisine ccx ON gos.placeid = ccx.placeid
 GROUP BY alcohol order by alcohol) as x WHERE x.alcohol = go.alcohol
group by alcohol, Rcuisine order by alcohol;


# Questions 5: - let’s take out the average rating of each state.

SELECT 
state, 
avg(rating) ratings 
FROM geoplaces2 go JOIN rating_final rf 
ON go.placeid = rf.placeid 
WHERE state != '?' 
GROUP BY state ORDER BY ratings desc  ;


# Questions 6: -' Tamaulipas' Is the lowest average rated state. 
# Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.


SELECT 
state, 
avg(rating), 
alcohol, 
Rcuisine 
FROM geoplaces2 go JOIN rating_final rf ON go.placeid = rf.placeid 
JOIN chefmozcuisine cf ON cf.placeID = go.placeID 
where state ='Tamaulipas' 
GROUP BY state, alcohol, Rcuisine 
ORDER BY state desc;

# Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC 
# and tried Mexican or Italian types of cuisine, and also their budget level is low.
# We encourage you to give it a try by not using joins.


SELECT avg(up.weight) AS Average_Weight , 
avg(food_rating) AS Average_Foot_Rating, 
avg(service_rating) AS Average_Service_Rating 
FROM rating_final rf,
(SELECT userid, weight, budget FROM userprofile WHERE budget ='low' and userid IN 
(SELECT userid FROM usercuisine WHERE
rcuisine IN ('Mexican','Italian'))) AS up 
WHERE up.userid = rf.userid AND rf.placeid = (SELECT placeid FROM geoplaces2 WHERE name = 'KFC');



#PART 3: (TRIGGERS)

# Creating two tables student_details and student_details_backup
CREATE TABLE student_details
(
studentid int primary key,
studentname varchar(50),
mailid varchar(80),
mobile bigint
);

CREATE TABLE student_details_backup
(
studentid int primary key,
studentname varchar(50),
mailid varchar(80),
mobile bigint
);

# Inserting data to the student_details table 

INSERT INTO student_details VALUES (1001, 'SANKAR', 'sankar@gmail.com',9825644156),
(1002, 'ROHAN', 'ron1@gmail.com',9008445822),(1003,'IMRAN', 'imran@yahoo.com',8955785662),
(1004,'SOUMI','soumi1@yahoo.com',7789565645),(1005,'SONALI', 'sonali@gmail.com',8955437744);
insert into student_details values(1006, 'SANDY', 'sandy@gmail.com',9805644156);
insert into student_details values(1007, 'SOHINI', 'sohini@gmail.com',8075644146);
SELECT * FROM student_details;

# Trigger creation for student_details table 
delimiter $$
CREATE TRIGGER record_push BEFORE DELETE ON student_details
FOR EACH ROW
BEGIN
	INSERT INTO student_details_backup VALUES(old.studentid, old.studentname, old.mailid, old.mobile) ;
END $$
delimiter ;


# Deleting data from the student_details table
DELETE FROM student_details WHERE studentid = 1007;
DELETE FROM student_details WHERE studentid = 1002;

SELECT * FROM student_details_backup;