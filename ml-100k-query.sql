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

SELECT * FROM ratingsdata

-- Load in items data
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-100k/u.item' 
	INTO TABLE items 
	FIELDS TERMINATED BY '|';

SELECT * FROM items
SELECT COUNT('title') FROM items

-- Load in users data
LOAD DATA LOCAL INFILE '/Users/jburchell/Documents/MovieLens/ml-100k/u.user' 
	INTO TABLE users 
	FIELDS TERMINATED BY '|';

SELECT * FROM users