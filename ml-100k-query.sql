CREATE TABLE ratingsdata ( 
   userid INT, 
   itemid INT, 
   rating INT, 
   timestamp INT, 
   PRIMARY KEY (userid, itemid)); 
   
CREATE TABLE items ( 
   itemid INT PRIMARY KEY, 
   title TEXT, 
   date TEXT, 
   videodate TEXT, 
   imdb TEXT, 
   unknown BOOLEAN, 
   action BOOLEAN, 
   adventure BOOLEAN, 
   animation BOOLEAN, 
   childrens BOOLEAN, 
   comedy BOOLEAN, 
   crime BOOLEAN, 
   documentary BOOLEAN, 
   drama BOOLEAN, 
   fantasy BOOLEAN, 
   noir BOOLEAN, 
   horror BOOLEAN, 
   musical BOOLEAN, 
   mystery BOOLEAN, 
   romance BOOLEAN, 
   scifi BOOLEAN, 
   thriller BOOLEAN, 
   war BOOLEAN, 
   western BOOLEAN); 
 
CREATE TABLE users ( 
   userid INT PRIMARY KEY, 
   age INT, 
   gender CHAR, 
   occupation TEXT, 
   zip INT); 
 
-- Indexes creation 
CREATE INDEX usersdata_index ON ratingsdata (userid); 
CREATE INDEX itemsdata_index ON ratingsdata (itemid);

-- Load in ratings data
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-100k/u.data' 
	INTO TABLE ratingsdata;

SELECT * FROM ratingsdata;

-- Load in items data
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-100k/u.item' 
	INTO TABLE items 
	FIELDS TERMINATED BY '|';

SELECT * FROM items;

-- Load in users data
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-100k/u.user' 
	INTO TABLE users 
	FIELDS TERMINATED BY '|';

SELECT * FROM users;

-- Descriptives
	-- Count
SELECT COUNT(*) AS "Number of ratings"
	FROM ratingsdata;

SELECT COUNT(*) AS "Number of movies"
	FROM items;

SELECT COUNT(*) AS "Number of users"
	FROM users;

	--- Ratings descriptives
SELECT rating, COUNT(rating) as "Number of ratings"
	FROM ratingsdata
	GROUP BY rating;
	
SELECT items.title, ratingsdata.rating, AVG(ratingsdata.rating) AS "Average rating"
	FROM ratingsdata
	INNER JOIN items
	ON ratingsdata.itemid = items.itemid;
	
SELECT title, AVG(rating) AS "Averaging rating"
	FROM items
	INNER JOIN ratingsdata
	ON ratingsdata.itemid = items.itemid
	GROUP BY title;

	-- Check for Christmas titles
SELECT FROM_UNIXTIME(timestamp) 
	FROM ratingsdata 
	WHERE MONTH(FROM_UNIXTIME(timestamp)) = 12;
	
SELECT * FROM Customers
WHERE City LIKE 's%';

SELECT title FROM items
	WHERE title LIKE ('%Christmas%');
	
SELECT MONTH(FROM_UNIXTIME(timestamp)), AVG(rating) AS "Averaging rating"
FROM items
INNER JOIN ratingsdata
  ON ratingsdata.itemid = items.itemid
WHERE title LIKE ('%Christmas%')
GROUP BY MONTH(FROM_UNIXTIME(timestamp));
/* Doesn't really work as there are only two movies with 'Christmas' in the title. Let's try finding a list of top Christmas movies and searching for them specifically. */

/* The maximum rating is at 1998*/
SELECT MAX(YEAR(FROM_UNIXTIME(timestamp))) FROM ratingsdata;

-- Top rated movies for December
SELECT *
FROM (
  SELECT title, AVG(rating) AS avgRating
  FROM items
  INNER JOIN ratingsdata
	ON ratingsdata.itemid = items.itemid
  WHERE MONTH(FROM_UNIXTIME(timestamp)) = 12
  GROUP BY title
) AS ratings
ORDER BY avgRating DESC;

-- Movies with at least 30 ratings in December
SELECT *
FROM (
  SELECT title, AVG(rating) AS avgRating
  FROM items
  INNER JOIN ratingsdata
	ON ratingsdata.itemid = items.itemid
  WHERE MONTH(FROM_UNIXTIME(timestamp)) = 12
  GROUP BY title
  HAVING COUNT(rating) >= 20
) AS ratings
ORDER BY avgRating DESC;

-- Have a look by title order to scan for Christmas movies
SELECT *
FROM (
  SELECT title, AVG(rating) AS avgRating
  FROM items
  INNER JOIN ratingsdata
	ON ratingsdata.itemid = items.itemid
  GROUP BY title
  HAVING COUNT(rating) >= 120
) AS ratings
ORDER BY title ASC;

-- Look at 'It's a Wonderful Life'

SELECT * FROM items
WHERE UPPER(title)
  LIKE UPPER("%IT'S A WONDERFUL LIFE%");

SELECT MONTH(FROM_UNIXTIME(timestamp)), AVG(rating) AS "Averaging rating"
FROM items
INNER JOIN ratingsdata
  ON ratingsdata.itemid = items.itemid
WHERE UPPER(title)
  LIKE UPPER("%IT'S A WONDERFUL LIFE%")
GROUP BY MONTH(FROM_UNIXTIME(timestamp));

SELECT * FROM items
WHERE UPPER(title)
  LIKE UPPER("%SANTA CLAUSE%");
  
SELECT MONTH(FROM_UNIXTIME(timestamp)), AVG(rating) AS "Averaging rating"
FROM items
INNER JOIN ratingsdata
  ON ratingsdata.itemid = items.itemid
WHERE UPPER(title)
  LIKE UPPER("%SANTA CLAUSE%")
GROUP BY MONTH(FROM_UNIXTIME(timestamp));



