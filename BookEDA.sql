# Perform some general cleaning to enure only 16 genres remains in books db - noticed excel cleaning missed some rows
# Perform some general cleaning to remove and fix books with blank genres in books db
SELECT *
FROM books
WHERE Genre = '';
UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE `Index` = 475;

UPDATE books
SET Genre = 'Thriller'
WHERE `Index` = 773;
# Correct a misspelling in the Genre column
UPDATE books
SET Genre = 'Children''s Literature'
WHERE Genre = 'Chidren''s Literature';

# General cleaning for genres to ensure consistency
UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE Genre = 'Biography/Autobiography';

UPDATE books
SET Genre = 'Self-Help & Instruction'
WHERE Genre = 'Self-Help and Instruction';
SELECT * FROM books;
UPDATE books
SET Genre = 'Adventure'
WHERE `Index` = 548;

UPDATE books
SET Genre = 'Self-Help & Instruction'
WHERE `Index` = 568;

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE `Index` = 256;

UPDATE books
SET Genre = 'Essays/Journalism'
WHERE Genre = 'Business/Leadership' AND `Index` = 401;

UPDATE books
SET Genre = 'Self-Help & Instruction'
WHERE Genre = 'Business/Leadership' AND `Index` = 459;

UPDATE books
SET Genre = 'Thriller'
WHERE Genre = 'Legal Thriller';

UPDATE books
SET Genre = 'Historical Fiction'
WHERE Genre = 'Western';

UPDATE books
SET Genre = 'Essays/Journalism'
WHERE Genre = 'Philosophy';

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE Genre = 'Humor';

UPDATE books
SET Genre = 'Science Fiction'
WHERE Genre = 'Dystopian Fiction';

UPDATE books
SET Genre = 'Essays/Journalism'
WHERE `Index` = 412;

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE `Index` = 297;

UPDATE books
SET Genre = 'Adventure'
WHERE `Index` = 222;

UPDATE books
SET Genre = 'Biography/Autobiography/Memoir'
WHERE `Index` = 249;

UPDATE books
SET Genre = 'Classics'
WHERE Genre = 'Drama';

# Fixing author names 
UPDATE books
SET Author = 'Stephen King'
WHERE Author LIKE '%Richard Bachman%';

UPDATE books
SET Author = 'Stephen King'
WHERE Author LIKE '%Roberto Aguirre%';
 
UPDATE books
SET Author = 'Robert Jordan, Brandon Sanderson'
WHERE Author LIKE '%Brandon Sanderson, Robert Jordan%';

# Standardizing publisher names
UPDATE books
SET Publisher = 'HarperCollins'
WHERE Publisher LIKE '%HarperCollins%';

#final look at cleaned up table
SELECT * FROM books;

# With all our data cleaned up, we can now accurate organize the data according to highest rated genres
SELECT 
    Genre,
    AVG(Book_average_rating) AS average_rating,
    SUM(gross_sales) AS total_gross_sales
FROM 
    books
GROUP BY 
    Genre
ORDER BY 
    average_rating DESC;

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
    
#Next we will sum up our main Publishers to see who does best in gross sales, ratings, and units sold
SELECT 
    Publisher,
    SUM(gross_sales) AS total_gross_sales,
    AVG(Book_average_rating) AS average_rating,
    SUM(publisher_revenue) AS total_publisher_revenue
FROM 
    books
GROUP BY 
    Publisher
ORDER BY 
    total_gross_sales DESC;
    
# Analyze genre performance over time (grouping by genre and publishing year)
SELECT 
    Genre,
    Publishing_Year,
    SUM(gross_sales) AS total_gross_sales,
    AVG(Book_average_rating) AS average_rating
FROM 
    books
GROUP BY 
    Genre, Publishing_Year
ORDER BY 
    Genre, Publishing_Year;

    
# Find publisher performance in specific genres, ranked by total gross sales
SELECT 
    Publisher,
    Genre,
    SUM(gross_sales) AS total_gross_sales,
    AVG(Book_average_rating) AS average_rating,
    SUM(units_sold) AS total_units_sold
FROM 
    books
GROUP BY 
    Publisher, Genre
ORDER BY 
    total_gross_sales DESC;
    

# Find the books with the highest sale prices and their corresponding sales performance
SELECT 
    Book_Name,
    Author,
    Genre,
    sale_price,
    gross_sales,
    units_sold
FROM 
    books
ORDER BY 
    sale_price DESC
LIMIT 10;

SELECT 
    Genre,
    Publishing_Year,
    SUM(gross_sales) AS total_gross_sales,
    AVG(Book_average_rating) AS average_rating
FROM 
    books
GROUP BY 
    Genre, Publishing_Year
ORDER BY 
    Genre, Publishing_Year;
    
# Step 11: Analyze how author rating correlates with gross sales, average book rating,  over time
SELECT 
    Author_Rating,
    Publishing_Year,
    SUM(gross_sales) AS total_gross_sales,
    AVG(Book_average_rating) AS average_book_rating
FROM  
    books
GROUP BY 
    Author_Rating,  -- Grouping by Author Rating to track by category
    Publishing_Year -- Grouping by year to track changes over time
ORDER BY 
    Publishing_Year, -- Sorting results by year for proper chronological order
    Author_Rating;  -- Sorting by Author Rating for better readability

#general query for ratings over time sorted by author rating, publisher, or genre
SELECT 
    Publishing_Year,
    Genre,
    Publisher,
    Author_Rating,
    AVG(Book_average_rating) AS average_rating
FROM 
    books
GROUP BY 
    Publishing_Year, Genre, Publisher, Author_Rating
ORDER BY 
    Publishing_Year;  -- Default sorting by year
