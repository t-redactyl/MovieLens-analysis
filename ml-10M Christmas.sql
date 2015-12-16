DROP TABLE IF EXISTS ratingsdata;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS tags;

CREATE TABLE ratingsdata ( 
   userid INT, 
   itemid INT, 
   rating INT, 
   timestamp INT, 
   PRIMARY KEY (userid, itemid)); 
    
CREATE TABLE tags ( 
   userid INT, 
   itemid INT, 
   tag INT, 
   timestamp INT, 
   PRIMARY KEY (userid, itemid)); 
 
DROP TABLE movies;    
CREATE TABLE movies ( 
   itemid INT PRIMARY KEY, 
   title TEXT, 
   genres TEXT,
   action INT DEFAULT 0,
   adventure INT DEFAULT 0,
   animation INT DEFAULT 0,
   childrens INT DEFAULT 0,
   comedy INT DEFAULT 0,
   crime INT DEFAULT 0,
   documentary INT DEFAULT 0,
   drama INT DEFAULT 0,
   fantasy INT DEFAULT 0,
   noir INT DEFAULT 0,
   horror INT DEFAULT 0,
   musical INT DEFAULT 0,
   mystery INT DEFAULT 0,
   romance INT DEFAULT 0,
   scifi INT DEFAULT 0,
   thriller INT DEFAULT 0,
   war INT DEFAULT 0,
   western INT DEFAULT 0);
   
-- Indexes creation 
CREATE INDEX usersdata_index ON ratingsdata (userid); 
CREATE INDEX itemsdata_index ON ratingsdata (itemid);

-- Load in data
	-- Ratings
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-10M100K/ratings.dat' 
	INTO TABLE ratingsdata 
	FIELDS TERMINATED BY '::';
	
SELECT *
	FROM ratingsdata
	LIMIT 20;

	-- Tags
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-10M100K/tags.dat' 
	INTO TABLE tags 
	FIELDS TERMINATED BY '::';
	
SELECT *
	FROM ratingsdata
	LIMIT 20;

	-- Movies
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-10M100K/movies.dat' 
	INTO TABLE movies 
	FIELDS TERMINATED BY '::';

SELECT *
	FROM movies
	LIMIT 20;

-- Christmas movies

DROP TABLE christmas;
CREATE TABLE christmas (
	name TEXT,
	year TEXT,
	ranking INT PRIMARY KEY
);

LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/movies.csv' 
	INTO TABLE christmas
	FIELDS TERMINATED BY '|';
			
SELECT * FROM christmas
ORDER BY ranking;

UPDATE christmas
SET name = REPLACE(name,'â','\'');

UPDATE christmas
SET name = REPLACE(name,'ï»¿','');

UPDATE christmas
SET name = REPLACE(name,'ï»¿','');

-- Try to match

SELECT * 
	FROM christmas 
	INNER JOIN movies
	ON UPPER(movies.title)
  		LIKE CONCAT(UPPER(christmas.name), '%')

SELECT DISTINCT COUNT(name)
FROM (
	SELECT * 
	FROM christmas 
	INNER JOIN movies
	ON UPPER(movies.title)
  		LIKE CONCAT(UPPER(christmas.name), '%')
  	) AS counts;
	-- 37 of the titles were matched

-- Revisit the table and change those with 'A' and 'The'

SELECT * FROM christmas
ORDER BY name;

SELECT * FROM movies
WHERE UPPER(title)
  LIKE UPPER("%Joyeux%");

UPDATE christmas
SET name = REPLACE(name,'A Charlie Brown Christmas','Charlie Brown Christmas, A');

UPDATE christmas
SET name = REPLACE(name,'A Christmas Carol','Christmas Carol, A');

UPDATE christmas
SET name = REPLACE(name,'A Christmas Story','Christmas Story, A');

UPDATE christmas
SET name = REPLACE(name,'The Family Stone', 'Family Stone, The');

UPDATE christmas
SET name = REPLACE(name,'The Family Stone', 'Family Stone, The');

UPDATE christmas
SET name = REPLACE(name,'The Holiday','Holiday, The');

UPDATE christmas
SET name = REPLACE(name,'The Long Kiss Goodnight','Long Kiss Goodnight, The');

UPDATE christmas
SET name = REPLACE(name,'The Muppet Christmas Carol','Muppet Christmas Carol, The');

UPDATE christmas
SET name = REPLACE(name,'The Nightmare Before Christmas','Nightmare Before Christmas, The');

UPDATE christmas
SET name = REPLACE(name,'The Polar Express','Polar Express, The');

UPDATE christmas
SET name = REPLACE(name,'The Santa Clause','Santa Clause, The');

UPDATE christmas
SET name = REPLACE(name,'The Snowman','Snowman, The');

-- Merging by columns in Christmas, attempt 2

SELECT * 
	FROM christmas 
	INNER JOIN movies
	ON UPPER(movies.title)
  		LIKE CONCAT(UPPER(christmas.name), '%')

SELECT DISTINCT COUNT(name)
FROM (
	SELECT * 
	FROM christmas 
	INNER JOIN movies
	ON UPPER(movies.title)
  		LIKE CONCAT(UPPER(christmas.name), '%')
  	) AS counts;
	-- Now 48 are matched!

-- Keeping only the relevant rows

SELECT * 
	FROM christmas 
	INNER JOIN movies
	ON UPPER(movies.title)
  		LIKE CONCAT(UPPER(christmas.name), '%')
  	WHERE movies.title NOT IN ('Die Hard: With a Vengeance (1995)',
  							   'Home Alone 2: Lost in New York (1992)',
  							   'Home Alone 3 (1997)',
  							   'Lethal Weapon 4 (1998)',
  							   'Lethal Weapon 2 (1989)',
  							   'Lethal Weapon 3 (1992)',
  							   'Gremlins 2: The New Batch (1990)',
  							   'Miracle on 34th Street (1994)',
  							   'Christmas Carol, A (Scrooge) (1951)',
  							   'How the Grinch Stole Christmas! (1966)');
	
/* To do:
	- Revisit the web scraping
	- Keep year and name together
	- Convert to UTC-8 and export that into SQL
*/

DROP TABLE christmas;
CREATE TABLE christmas (
	name TEXT
);

LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/christmas_movies.txt' 
	INTO TABLE christmas;

SELECT * FROM christmas;

SELECT * 
	FROM christmas 
	INNER JOIN movies
	ON UPPER(movies.title)
  		LIKE CONCAT('%', UPPER(christmas.name), '%');
  		
SELECT COUNT(name) 
FROM (
	SELECT * 
	FROM christmas 
	INNER JOIN movies
	ON UPPER(movies.title)
  		LIKE CONCAT('%', UPPER(christmas.name), '%')
) AS counts;

-- Managed to match 35 of the 50 movies!

-- Now that we have the sublist of movies, let's start looking at average ratings

SELECT * FROM ratingsdata;

SELECT AVG(ratingsdata.rating)
FROM ratingsdata
INNER JOIN movies
ON movies.itemid = ratingsdata.itemid
WHERE (
	SELECT movies.itemid 
	FROM christmas 
	INNER JOIN movies
	ON UPPER(movies.title)
  		LIKE CONCAT('%', UPPER(christmas.name), '%')
)
GROUP BY movies.title;

DROP TABLE christmasids;
CREATE TABLE christmasids (
	itemid INT
);

INSERT INTO christmasids
SELECT movies.itemid
FROM christmas 
INNER JOIN movies
ON UPPER(movies.title)
	LIKE CONCAT('%', UPPER(christmas.name), '%');

SELECT movies.title, AVG(ratingsdata.rating) AS "Average rating"
FROM movies
INNER JOIN ratingsdata
ON movies.itemid = ratingsdata.itemid
WHERE movies.itemid IN (
	SELECT christmasids.itemid
	FROM movies
	INNER JOIN christmasids
	ON movies.itemid = christmasids.itemid)
GROUP BY movies.title;

SELECT * 
FROM (
	SELECT movies.title AS "Title", AVG(ratingsdata.rating) AS avgr
	FROM movies
	INNER JOIN ratingsdata
	ON movies.itemid = ratingsdata.itemid
	WHERE movies.itemid IN (
		SELECT christmasids.itemid
		FROM movies
		INNER JOIN christmasids
			ON movies.itemid = christmasids.itemid)
	GROUP BY movies.title
) AS christmasratings
ORDER BY avgr DESC;

SELECT * 
FROM (
	SELECT movies.title AS "Title", AVG(ratingsdata.rating) AS avgr 
	FROM movies
	INNER JOIN ratingsdata
	ON movies.itemid = ratingsdata.itemid
	WHERE movies.itemid IN (
		SELECT christmasids.itemid
		FROM movies
		INNER JOIN christmasids
			ON movies.itemid = christmasids.itemid) 
	AND MONTH(FROM_UNIXTIME(ratingsdata.timestamp)) = 12
	GROUP BY movies.title
) AS christmasratings
ORDER BY avgr DESC
LIMIT 15;


SELECT movies.title AS Title, YEAR(FROM_UNIXTIME(ratingsdata.timestamp)) as Year,
	AVG(ratingsdata.rating) AS AverageRating
FROM movies
INNER JOIN ratingsdata
ON movies.itemid = ratingsdata.itemid
WHERE movies.itemid IN (
	SELECT christmasids.itemid
	FROM movies
	INNER JOIN christmasids
		ON movies.itemid = christmasids.itemid)
GROUP BY movies.title, Year;

-- Genres

SELECT COUNT(DISTINCT movies.title) AS Title
FROM movies
LEFT JOIN ratingsdata
ON movies.itemid = ratingsdata.itemid
WHERE movies.itemid IN (
	SELECT christmasids.itemid
	FROM movies
	INNER JOIN christmasids
		ON movies.itemid = christmasids.itemid)
AND movies.genres LIKE '%Action%';

	-- Action
UPDATE movies
SET action = 1
WHERE genres LIKE '%Action%';

	-- Adventure
UPDATE movies
SET adventure = 1
WHERE genres LIKE '%Adventure%';

	-- Animation
UPDATE movies
SET animation = 1
WHERE genres LIKE '%Animation%';

	-- Children's
UPDATE movies
SET childrens = 1
WHERE genres LIKE '%Children%';

	-- Comedy
UPDATE movies
SET comedy = 1
WHERE genres LIKE '%Comedy%';

	-- Crime
UPDATE movies
SET crime = 1
WHERE genres LIKE '%Crime%';

	-- Documentary
UPDATE movies
SET documentary = 1
WHERE genres LIKE '%Documentary%';

	-- Drama
UPDATE movies
SET drama = 1
WHERE genres LIKE '%Drama%';

	-- Fantasy
UPDATE movies
SET fantasy = 1
WHERE genres LIKE '%Fantasy%';

	-- Noir
UPDATE movies
SET noir = 1
WHERE genres LIKE '%Noir%';

	-- Horror
UPDATE movies
SET horror = 1
WHERE genres LIKE '%Horror%';

	-- Musical
UPDATE movies
SET musical = 1
WHERE genres LIKE '%Musical%';

	-- Mystery
UPDATE movies
SET mystery = 1
WHERE genres LIKE '%Mystery%';

	-- Romance
UPDATE movies
SET romance = 1
WHERE genres LIKE '%Romance%';

	-- Sci-Fi
UPDATE movies
SET scifi = 1
WHERE genres LIKE '%Sci-Fi%';

	-- Thriller
UPDATE movies
SET thriller = 1
WHERE genres LIKE '%Thriller%';

	-- War
UPDATE movies
SET war = 1
WHERE genres LIKE '%War%';

	-- Western
UPDATE movies
SET western = 1
WHERE genres LIKE '%Western%';

-- Query the genres

SELECT * FROM movies;

SELECT SUM(movies.action) AS Action, SUM(movies.adventure) AS Adventure, SUM(movies.animation) AS Animation,
	   SUM(movies.childrens) AS Childrens, SUM(movies.comedy) AS Comedy, SUM(movies.crime) AS Crime,
	   SUM(movies.documentary) AS Documentary, SUM(movies.drama) AS Drama, SUM(movies.fantasy) AS Fantasy,
	   SUM(movies.noir) AS Noir, SUM(movies.horror) AS Horror, SUM(movies.musical) AS Musical,
	   SUM(movies.mystery) AS Mystery, SUM(movies.romance) AS Romance, SUM(movies.scifi) AS SciFi,
	   SUM(movies.thriller) AS Thriller, SUM(movies.war) AS War, SUM(movies.western) AS Western
FROM movies
WHERE movies.title IN (
	SELECT DISTINCT movies.title
	FROM movies
	LEFT JOIN ratingsdata
		ON movies.itemid = ratingsdata.itemid
	WHERE movies.itemid IN (
		SELECT christmasids.itemid
		FROM movies
		INNER JOIN christmasids
			ON movies.itemid = christmasids.itemid));

	