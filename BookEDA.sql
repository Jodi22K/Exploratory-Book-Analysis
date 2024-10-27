# Perform some general cleaning to enure only 16 genres remains in books db - noticed excel cleaning missed some rows
# Perform some general cleaning to remove and fix books with blank genres in books db
SELECT DISTINCT *
FROM Books b
WHERE b.Genre = '';

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE BookID = 165;

UPDATE books
SET Genre = 'Thriller'
WHERE BookID = 470;

UPDATE books
SET Genre = 'Essays/Journalism'
WHERE `Book Name` = 'Holidays on Ice';

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE `Book Name` = 'Persepolis';

UPDATE books
SET Genre = 'Adventure'
WHERE `Book Name` = 'Scott Pilgrim, Volume 1: Scott Pilgrim''s Precious Little Life';

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE `Book Name` = 'Calvin and Hobbes';

UPDATE books
SET Genre = 'Adventure'
WHERE `Book Name` = 'The Celestine Prophecy';

UPDATE books
SET Genre = 'Self-Help & Instruction'
WHERE  `Book Name` = 'Tao Te Ching';
SELECT genre FROM books WHERE BookID =35;;

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE  `Book Name` = 'Sh*t My Dad Says';

UPDATE books
SET Genre = 'Essays/Journalism'
WHERE Genre = 'Business/Leadership' AND `Book Name` = 'Good to Great: Why Some Companies Make the Leap... and Others Don''t';

UPDATE books
SET Genre = 'Self-Help & Instruction'
WHERE Genre = 'Business/Leadership' AND `Book Name` = 'Rework';

UPDATE books b
JOIN genres g ON g.genre = b.genre
SET g.genre = 'Chidren''s Literature',
    b.genre = 'Chidren''s Literature'
WHERE b.genre LIKE '%Chidren''s Literature%'
  AND g.genre LIKE '%Chidren''s Literature%';

UPDATE books b
JOIN genres g ON g.genre = b.genre
SET g.genre = 'Self-Help & Instruction',
    b.genre = 'Self-Help & Instruction'
WHERE b.genre LIKE '%Self-Help and Instruction%'
  AND g.genre LIKE '%Self-Help and Instruction%';
  
UPDATE books b
JOIN genres g ON g.genre = b.genre
SET g.genre = 'Thriller',
    b.genre = 'Thriller'
WHERE b.genre LIKE '%Legal Thriller%'
  AND g.genre LIKE '%Legal Thriller%';

UPDATE books b
JOIN genres g ON g.genre = b.genre
SET g.genre = 'Historical Fiction',
    b.genre = 'Historical Fiction'
WHERE b.genre LIKE '%Western%'
  AND g.genre LIKE '%Western%';

UPDATE books b
JOIN genres g ON g.genre = b.genre
SET g.genre = 'Biography/Autobiography/Memoir',
    b.genre = 'Biography/Autobiography/Memoir'
WHERE b.genre LIKE '%Humor%'
  AND g.genre LIKE '%Humor%';

UPDATE books b
JOIN genres g ON g.genre = b.genre
SET b.genre = 'Science Fiction',
    g.genre = 'Science Fiction' 
WHERE b.genre LIKE '%Dystopian Fiction%'
  AND g.genre LIKE '%Dystopian Fiction%';

UPDATE books b
JOIN genres g ON g.genre = b.genre
SET g.genre = 'Historical Fiction' AND
    b.genre = 'Historical Fiction'
WHERE b.genre LIKE '%Western%'
  AND g.genre LIKE '%Western%';

UPDATE books b
JOIN genres g ON g.genre = b.genre
SET g.genre = 'Classics',
    b.genre = 'Classics'
WHERE b.genre LIKE '%Drama%'
  AND g.genre LIKE '%Drama%';
  
# Fixing author names 
UPDATE books b
JOIN authors a ON b.Author = a.Author
SET b.Author = 'Stephen King',
    a.Author = 'Stephen King'
WHERE b.Author LIKE '%Richard Bachman%'
  AND a.Author LIKE '%Richard Bachman%';
  
UPDATE books b
JOIN authors a ON b.Author = a.Author
SET b.Author = 'Stephen King',
    a.Author = 'Stephen King'
WHERE b.Author LIKE '%Roberto Aguirre%'
  AND a.Author LIKE '%Roberto Aguirre%';

# Standardizing publisher names
UPDATE books
SET publisher = 'HarperCollins'
WHERE publisher LIKE '%HarperCollin%';

UPDATE publishers
SET publisher = 'HarperCollins'
WHERE publisher LIKE '%HarperCollin%';

#####
# With all our data cleaned up, we can now accurate organize the data according to highest rated genres
CREATE VIEW vw_SalesByCategory AS
SELECT 
    b.Genre,
    b.Publisher,
    a.Author_Rating,
    SUM(s.`gross sales`) AS total_gross_sales
FROM 
    books b
JOIN 
    authors a ON b.Author = a.Author 
JOIN 
    sales s ON b.`Book Name` = s.`Book Name`
GROUP BY 
    b.Genre, b.Publisher, a.Author_Rating;

SELECT * FROM vw_salesbycategory;
DROP VIEW IF EXISTS vw_salesbycategory;

#########
#Next we will sum up our main Publishers to see who does best in gross sales, ratings, and units sold
CREATE VIEW vw_PublisherRevenue AS
SELECT DISTINCT
	Publisher,
    `Publisher Revenue` AS total_publisher_revenue
FROM 
    publishers
GROUP BY 
    Publisher, total_publisher_revenue
ORDER BY 
    total_publisher_revenue DESC;
SELECT * FROM vw_PublisherRevenue;

######
CREATE VIEW vw_UnitsByCategory AS
SELECT 
    b.Genre,
    b.publisher,
    a.Author_Rating,
    SUM(s.`units sold`) AS total_units_sold
FROM 
    books b
INNER JOIN
    authors a ON b.Author = a.Author  -- assuming books table has Author_ID to link with authors table
INNER JOIN 
    sales s ON b.`Book Name` = s.`Book Name`
GROUP BY 
	b.Genre, b.Publisher, a.Author_Rating;
SELECT * FROM vw_UnitsByCategory;
DROP VIEW IF EXISTS vw_UnitsByCategory;

######
#general query for ratings over time sorted by author rating, publisher, or genre
CREATE VIEW vw_AvgRating AS
SELECT 
    b.`Publishing Year`,
    b.Genre,
    b.Publisher,
    a.Author_Rating,
    AVG(b.`Book Average Rating`) AS average_rating
FROM 
    books b
INNER JOIN
    authors a ON b.Author = a.Author  -- assuming books table has Author_ID to link with authors table
GROUP BY 
    b.`Publishing Year`, b.Genre, b.Publisher, a.Author_Rating;
SELECT * FROM vw_AvgRating;
DROP VIEW vw_AvgRating;

#We also want the top authors based on various values for all their books
SELECT 
    SUBSTRING_INDEX(Author, ',', 1) AS Prim_Author,
    SUM(gross_sales) AS total_gross_sales,
    COUNT(Book_Name) AS book_count,
    SUM(units_sold) AS total_units_sold,
    RANK() OVER (ORDER BY SUM(gross_sales) DESC) AS sales_rank
FROM 
    books
GROUP BY 
    Prim_Author
ORDER BY 
    sales_rank;