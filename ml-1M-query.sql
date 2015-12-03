CREATE TABLE ratingsdata ( 
   userid INT, 
   itemid INT, 
   rating INT, 
   timestamp INT, 
   PRIMARY KEY (userid, itemid)); 
   
CREATE TABLE items ( 
   itemid INT PRIMARY KEY, 
   title TEXT, 
   genres TEXT);

CREATE TABLE users ( 
   userid INT PRIMARY KEY, 
   gender CHAR, 
   age INT, 
   occupation TEXT, 
   zip INT); 