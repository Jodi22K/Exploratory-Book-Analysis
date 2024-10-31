# Perform some general cleaning to enure only 16 genres remains in books db - noticed some rows missed in initial excel cleaning
# Identify and further clean specific rows with incorrect or blank information in Books, Sales, Authors, and Publishers tables to ensure data integrity
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
SELECT genre FROM books WHERE BookID =35;

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE  `Book Name` = 'Sh*t My Dad Says';

UPDATE books
SET Genre = 'Essays/Journalism'
WHERE Genre = 'Business/Leadership' AND `Book Name` = 'Good to Great: Why Some Companies Make the Leap... and Others Don''t';

UPDATE books
SET Genre = 'Self-Help & Instruction'
WHERE Genre = 'Business/Leadership' AND `Book Name` = 'Rework';

# Correct and standardize incorrect genre names across tables
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

# Correct and standardize publisher names across tables
UPDATE publishers
SET publisher = 'HarperCollins'
WHERE publisher LIKE '%HarperCollin%';

# Consolidate publisher revenue by summing and removing duplicates
SELECT SUM(`Publisher Revenue`) AS total_revenue
FROM publishers
WHERE Publisher = 'HarperCollins';
SET @total_revenue = (
    SELECT SUM(`Publisher Revenue`)
    FROM publishers
    WHERE Publisher = 'HarperCollins'
);

DELETE FROM publishers 
WHERE Publisher = 'HarperCollins' AND PublisherID <> 4;

UPDATE publishers
SET `Publisher Revenue` = @total_revenue
WHERE PublisherID = 4;

# View all data for validation
SELECT * FROM books;
SELECT * FROM genres;
SELECT * FROM publishers;
SELECT * FROM sales;
SELECT * FROM authors;

# Since authors may have multiple author ratings, create view to rank authors based on their rating values
CREATE VIEW vw_HighestAuthorRating AS
SELECT 
    b.BookID,
    b.`Book Name`,
    b.Genre,
    b.Publisher,
    b.`Publishing Year`,
    a.Author,
    a.Author_rating,
    CASE 
        WHEN a.Author_rating = 'Excellent' THEN 3
        WHEN a.Author_rating = 'Famous' THEN 2
        WHEN a.Author_rating = 'Intermediate' THEN 1
        WHEN a.Author_rating = 'Novice' THEN 0
        ELSE -1  -- Unknown ratings get the lowest priority
    END AS rating_value
FROM 
    books b
INNER JOIN 
    authors a ON b.Author = a.Author;
SELECT * FROM vw_HighestAuthorRating;

CREATE VIEW vw_Top100Books AS
SELECT 
    h.BookID,
    h.`Book Name`,
    h.Genre,
    h.Publisher,
    h.Author,
    h.Author_rating,
    h.`Publishing Year`,
    SUM(s.`gross sales`) AS total_gross_sales,
    SUM(s.`publisher revenue`) AS total_publisher_revenue,
    SUM(s.`units sold`) AS total_units_sold,
    AVG(b.`Book Average Rating`) AS average_rating
FROM 
    vw_HighestAuthorRating h
INNER JOIN 
    (SELECT BookID, MAX(rating_value) AS max_rating_value
     FROM vw_HighestAuthorRating
     GROUP BY BookID) max_ratings 
     ON h.BookID = max_ratings.BookID AND h.rating_value = max_ratings.max_rating_value
INNER JOIN 
    sales s ON h.BookID = s.BookID
INNER JOIN 
    books b ON h.BookID = b.BookID
GROUP BY 
    h.BookID, h.`Book Name`, h.Genre, h.Publisher, h.Author, h.Author_rating, h.`Publishing Year`
ORDER BY 
    total_gross_sales DESC
LIMIT 100;

# Creating view of top 100 books ordered by gross sales and sorted by sales, units sold, avg rating, and publisher revenue
CREATE VIEW vw_Top100Books AS
SELECT 
    b.BookID,
    b.`Book Name`,
    b.Genre,
    b.Publisher,
    a.Author,
    a.Author_rating,
    b.`Publishing Year`,
	SUM(s.`gross sales`) AS total_gross_sales,
    SUM(s.`publisher revenue`) AS total_publisher_revenue,
    SUM(s.`units sold`) AS total_units_sold,
    AVG(b.`Book Average Rating`) AS average_rating
FROM 
    books b
INNER JOIN 
    authors a ON b.Author = a.Author
INNER JOIN 
    sales s ON b.BookID = s.BookID   
GROUP BY 
    b.BookID, b.`Book Name`,b.`Publishing Year`, b.Genre, b.Publisher,a.Author_Rating, a.Author
ORDER BY
	total_gross_sales DESC
LIMIT 100;
#View verification
SELECT * FROM vw_Top100Books;
DROP VIEW vw_Top100Books;

# Creating a view to calculate average rating over time for genre, publisher, and author
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

# View Verification
SELECT * FROM vw_AvgRating;
DROP VIEW vw_AvgRating;

    
# Next create views for publisher, genre, and author rating metrics, all sorted by same KPIs - total sales, avg rating, publisher revenue, and units sold

# PUBLISHER METRICS
CREATE VIEW vw_PublisherMetrics AS
SELECT 
    p.Publisher,
	p.`Publisher Revenue`,
    SUM(s.`units sold`) AS total_units_sold,
    SUM(s.`gross sales`) AS total_gross_sales,
    AVG(b.`Book Average Rating`) AS average_rating
FROM 
    books b
INNER JOIN 
    publishers p ON b.Publisher = p.Publisher
 INNER JOIN 
    sales s ON b.`Book Name` = s.`Book Name`
GROUP BY 
    p.Publisher, p.`Publisher Revenue`;
    
# View Verification
SELECT * FROM vw_PublisherMetrics;
DROP VIEW vw_PublisherMetrics;

# GENRE METRICS
CREATE VIEW vw_GenreMetrics AS
SELECT 
    g.Genre,
    SUM(s.`publisher revenue`) AS total_publisher_revenue,
    SUM(s.`units sold`) AS total_units_sold,
    SUM(s.`gross sales`) AS total_gross_sales,
    AVG(b.`Book Average Rating`) AS average_rating
FROM 
    books b
INNER JOIN 
    genres g ON b.Genre = g.Genre
INNER JOIN 
    sales s ON b.`Book Name` = s.`Book Name`
GROUP BY 
    g.Genre;
    
# View Verification
SELECT * FROM vw_GenreMetrics;
DROP VIEW vw_GenreMetrics;

# AUTHOR METRICS
CREATE VIEW vw_AuthorMetrics AS
SELECT 
    a.Author_rating,
	SUM(s.`publisher revenue`) AS total_publisher_revenue,
    SUM(s.`units sold`) AS total_units_sold,
    SUM(s.`gross sales`) AS total_gross_sales,
    AVG(b.`Book Average Rating`) AS average_rating
FROM 
    books b
INNER JOIN 
    authors a ON b.Author = a.Author
INNER JOIN 
    publishers p ON b.Publisher = p.Publisher
INNER JOIN 
    sales s ON b.`Book Name` = s.`Book Name`
GROUP BY 
    a.Author_rating;
    
# View Verification
SELECT * FROM vw_AuthorMetrics;
DROP VIEW vw_AuthorMetrics;

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
    
# View Verification
SELECT * FROM vw_AuthorMetrics;
DROP VIEW vw_AuthorMetrics;

