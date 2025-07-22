select * from playstore
truncate table playstore;

LOAD DATA LOCAL INFILE 'C:/Users/Dell/Downloads/Case Study 2/googleplaystore.csv'
INTO TABLE playstore
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 1.You're working as a market analyst for a mobile app development company.
-- Your task is to identify the most promising categories (TOP 5)
-- for launching new free apps based on their average ratings.

select category, round(avg(rating),2) as rat from playstore where type="Free" group by Category 
order by rat desc limit 5

-- 2.As a business strategist for a mobile app company, your objective is to pinpoint 
-- the three categories that generate the most revenue from paid apps. This calculation is based on the 
-- product of the app price and its number of installations.

select category,avg(Rev) as "Revenue" from
(
select *,(Installs*Price) as "Rev" from playstore where type="Paid"
) as paid_apps group by category 
order by Revenue desc
limit 5

-- 3.	As a data analyst for a gaming company, you're tasked with calculating the percentage of app within each category. 
-- This information will help the company understand the distribution of gaming apps across different categories.

select *, (cnt/(select count(*) from playstore))*100 as "percentage" from
(
select category, count(app) as "cnt" from playstore group by category
)t

-- 4.	As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company should develop paid or free apps 
-- for each category based on the ratings of that category.
with t1 as
(
select category, round(avg(rating),2) as "paid" from playstore where type="Paid" group by category
),
t2 as
(
select category, round(avg(rating),2) as "free" from playstore where type="free" group by category
)
select *, if (paid>free, "Develop paid apps","Develop free apps") as "Decision" from
(
select a.category,paid, free from t1 as a inner join t2 as b on a.category=b.category
)k

-- 5.Suppose you're a database administrator your databases have been hacked and hackers are changing price of certain apps on the database, 
-- it is taking long for IT team to neutralize the hack, however you as a responsible manager don’t want your data to be changed, 
-- do some measure where the changes in price can be recorded as you can’t stop hackers from making changes.

create table pricechangelog(
	app varchar(255),
    old_price decimal(10,2),
    new_price decimal(10,2),
    operation_type varchar(255),
    operation_date timestamp
    )
    
select * from pricechangelog

create table play as
select * from playstore

select * from play

DELIMITER //

CREATE TRIGGER price_change_log
AFTER UPDATE ON play
FOR EACH ROW
BEGIN
    INSERT INTO pricechangelog(app, old_price, new_price, operation_type, operation_date)
    VALUES (NEW.app, OLD.price, NEW.price, 'update', CURRENT_TIMESTAMP);
END//

DELIMITER ;

set sql_safe_updates=0

update play
set price = 4
where app = 'Infinite Painter'

update play 
set price = 5
where app = 'Sketch - Draw & Paint'

-- 6.Your IT team have neutralized the threat; however, hackers have made some changes in the prices, 
-- but because of your measure you have noted the changes, now you want correct data to be inserted into the database again.

-- update+Join
-- pricechangelog

select * from play as a inner join pricechangelog as b on a.app=b.app

drop trigger price_change_log

update play as a
inner join pricechangelog as b on a.app=b.app
set a.price =b.old_price

select * from play where app= 'Sketch - Draw & Paint'

-- 7.	As a data person you are assigned the task of investigating the correlation between two numeric factors: 
-- app ratings and the quantity of reviews.

SET @x = (SELECT ROUND(AVG(rating), 2) FROM playstore);
SET @y = (SELECT ROUND(AVG(reviews), 2) FROM playstore);    

with t as 
(
	select  *, round((rat*rat),2) as 'sqrt_x' , round((rev*rev),2) as 'sqrt_y' from
	(
		select  rating , @x, round((rating- @x),2) as 'rat' , reviews , @y, round((reviews-@y),2) as 'rev'from playstore
	)a                                                                                                                        
)
-- select * from  t
select  @numerator := round(sum(rat*rev),2) , @deno_1 := round(sum(sqrt_x),2) , @deno_2:= round(sum(sqrt_y),2) from t ; -- setp 4 
select round((@numerator)/(sqrt(@deno_1*@deno_2)),2) as corr_coeff
-----------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    round((AVG(Rating * Reviews) - AVG(Rating) * AVG(Reviews)) / (STD(Rating) * STD(Reviews)),2) AS rating_review_correlation
FROM 
    playstore
WHERE 
    Rating IS NOT NULL AND Reviews IS NOT NULL;



-- 8. Your boss noticed  that some rows in genres columns have multiple generes in them, which was creating issue when developing the  
-- recommendor system from the data he/she asssigned you the task to clean the genres column and make two genres out of it, 
-- rows that have only one genre will have other column as blank.

select * from playstore

ALTER TABLE playstore
ADD COLUMN Primary_Genre VARCHAR(100),
ADD COLUMN Secondary_Genre VARCHAR(100);

UPDATE playstore
SET 
  Primary_Genre = SUBSTRING_INDEX(Genres, ';', 1),
  Secondary_Genre = NULLIF(SUBSTRING_INDEX(Genres, ';', -1), SUBSTRING_INDEX(Genres, ';', 1));

select Genres, Primary_Genre,Secondary_Genre from playstore

-- 2. another way to fetch the details or cleaning the geners column

SELECT 
  App,
  Genres,
  CASE 
    WHEN Genres LIKE '%;%' THEN SUBSTRING_INDEX(Genres, ';', -1)
    ELSE NULL
  END AS Secondary_Genre
FROM playstore;

-- Step 1: Add new column
ALTER TABLE playstore
ADD COLUMN Secondary_Genre VARCHAR(100);

-- Step 2: Extract secondary genre before cleaning original
UPDATE playstore
SET Secondary_Genre = TRIM(SUBSTRING_INDEX(Genres, ';', -1))
WHERE Genres LIKE '%;%';

-- Step 3: Keep only first genre in original Genres column
UPDATE playstore
SET Genres = SUBSTRING_INDEX(Genres, ';', 1);

select app, Genres,Secondary_Genre from playstore


-- 9.	Your senior manager wants to know which apps are not performing as par in their particular category, 
-- however he is not interested in handling too many files or list for every  category and he/she assigned  
-- you with a task of creating a dynamic tool where he/she  can input a category of apps he/she  interested in  
-- and your tool then provides real-time feedback by displaying apps within that category that have ratings lower than the average 
-- rating for that specific category.

DROP PROCEDURE IF EXISTS FindUnderperformingApps;


DELIMITER //
CREATE PROCEDURE FindUnderperformingApps(IN category_name VARCHAR(255))
BEGIN
    DECLARE category_avg DECIMAL(3,1);
    
    -- Calculate average rating for the specified category
    SELECT AVG(Rating) INTO category_avg
    FROM playstore
    WHERE Category = category_name;
    
    -- Display the category average for reference
    SELECT CONCAT('Average rating for ', category_name, ': ', ROUND(category_avg, 1)) AS Info;
    
    -- Find apps below the category average with detailed information
    SELECT 
        App AS 'Application Name',
        Rating AS 'App Rating',
        ROUND(category_avg, 1) AS 'Category Average',
        ROUND(category_avg - Rating, 1) AS 'Below Average By',
        Reviews,
        Installs,
        Genres,
        Last_Updated
    FROM 
        playstore
    WHERE 
        Category = category_name
        AND Rating < category_avg
    ORDER BY 
        Rating ASC;
END //
DELIMITER ;

CALL FindUnderperformingApps('ART_AND_DESIGN');
