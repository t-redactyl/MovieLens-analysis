DROP TABLE IF EXISTS ratingsdata;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS users;

CREATE TABLE ratingsdata ( 
   userid INT, 
   itemid INT, 
   rating INT, 
   timestamp INT, 
   PRIMARY KEY (userid, itemid)); 
    
CREATE TABLE movies ( 
   itemid INT PRIMARY KEY, 
   title TEXT, 
   genres TEXT);

DROP TABLE users; 
CREATE TABLE users ( 
   userid INT PRIMARY KEY, 
   gender CHAR, 
   age INT, 
   occupation INT, 
   zip INT); 
   
-- Indexes creation 
CREATE INDEX usersdata_index ON ratingsdata (userid); 
CREATE INDEX itemsdata_index ON ratingsdata (itemid);

-- Load in data
	-- Ratings
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-1m/ratings.dat' 
	INTO TABLE ratingsdata 
	FIELDS TERMINATED BY '::';
	
SELECT *
	FROM ratingsdata
	LIMIT 20;

	-- Movies (items)
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-1m/movies.dat' 
	INTO TABLE movies 
	FIELDS TERMINATED BY '::';

SELECT *
	FROM movies
	LIMIT 20;

	-- Users
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-1m/users.dat' 
	INTO TABLE users 
	FIELDS TERMINATED BY '::';

SELECT *
	FROM users
	LIMIT 20;
	
CREATE TABLE occupations (
	id INT NOT NULL,
	name VARCHAR(255),
	PRIMARY KEY (id)
);

INSERT INTO occupations 
	VALUES (1,'Administrator'), (2,'Artist'), (3,'Doctor'), (4,'Educator'), (5,'Engineer'),
			(6,'Entertainment'), (7,'Executive'), (8,'Healthcare'), (9,'Homemaker'),
			(10,'Lawyer'), (11,'Librarian'), (12,'Marketing'), (13,'None'), (14,'Other'), 
			(15,'Programmer'), (16,'Retired'), (17,'Salesman'), (18,'Scientist'), (19,'Student'), 
			(20,'Technician'), (21,'Writer');
			
SELECT * FROM occupations;

-- Create new column for occupationName

ALTER TABLE users
	ADD occupation_name VARCHAR(255);

UPDATE users u, occupations o
	SET u.occupation_name = o.name
	WHERE u.occupation = o.id

SELECT *
	FROM users

-- Regex for genres
SELECT itemid, title, NULL as animation
FROM movies
WHERE genres LIKE ''
UNION ALL


ALTER TABLE movies
	ADD animation BOOLEAN;

UPDATE movies
	SET animation = 0;
	
UPDATE movies
	SET animation = 1
	WHERE genres LIKE '%Animation%';

SELECT * FROM movies
	WHERE genres LIKE '%Animation%';
	

