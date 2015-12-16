-- Create tables
DROP TABLE IF EXISTS ratingsdata;
CREATE TABLE ratingsdata ( 
   userid INT, 
   itemid INT, 
   rating INT, 
   timestamp INT, 
   PRIMARY KEY (userid, itemid)); 

DROP TABLE IF EXISTS movies;
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

DROP TABLE IF EXISTS christmas;
CREATE TABLE christmas (
	name TEXT);

-- Create indexes
CREATE INDEX usersdata_index ON ratingsdata (userid); 
CREATE INDEX itemsdata_index ON ratingsdata (itemid);

-- Loading in data
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-10M100K/ratings.dat' 
	INTO TABLE ratingsdata 
	FIELDS TERMINATED BY '::';

LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-10M100K/movies.dat' 
	INTO TABLE movies 
	FIELDS TERMINATED BY '::';

LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/christmas_movies.txt' 
	INTO TABLE christmas;

-- Query to merge the top Christmas movies with the MovieLens 10M list
SELECT COUNT(name) 
FROM (
   SELECT * 
   FROM christmas 
   INNER JOIN movies
   ON UPPER(movies.title)
      LIKE CONCAT('%', UPPER(christmas.name), '%')
) AS counts;
   -- 35 of the 50 Christmas movies were found.

-- Christmas movies IDs table.
DROP TABLE IF EXISTS christmasids;
CREATE TABLE christmasids (
   itemid INT);

INSERT INTO christmasids
SELECT movies.itemid
FROM christmas 
INNER JOIN movies
ON UPPER(movies.title)
   LIKE CONCAT('%', UPPER(christmas.name), '%');

-- Averaging rating of all Christmas movies
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

-- Average rating of all Christmas movies in December
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
ORDER BY avgr DESC;

-- Update the movie table by filling in genre binaries
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

-- Average rating by movie and by year
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



