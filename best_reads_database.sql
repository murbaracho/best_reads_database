-- Create table for Publishers
CREATE TABLE Publisher (
    publisher_id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE,
    location VARCHAR(255)
);

-- Create table for Books
CREATE TABLE Book (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    published_year INT,
    first_publish_year INT,
    publisher_id INT REFERENCES Publisher(publisher_id)
);

-- Create table for Authors
CREATE TABLE Author (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE
);

-- Create many-to-many relationship table for Books and Authors
CREATE TABLE Book_Author (
    book_id INT REFERENCES Book(book_id),
    author_id INT REFERENCES Author(author_id),
    PRIMARY KEY (book_id, author_id)
);

-- Insert unique publishers
INSERT INTO Publisher (name)
SELECT DISTINCT publisher FROM good_reads
WHERE publisher IS NOT NULL;

-- Insert unique books
INSERT INTO Book (title, published_year, first_publish_year, publisher_id)
SELECT DISTINCT g.title, g.publishedYear, g.firstPublishYear, p.publisher_id
FROM good_reads g
JOIN Publisher p ON g.publisher = p.name;


-- Insert unique authors
INSERT INTO Author (first_name, last_name)
SELECT DISTINCT 
    SPLIT_PART(author, ' ', 1) AS first_name,
    SPLIT_PART(author, ' ', 2) AS last_name
FROM good_reads
WHERE author IS NOT NULL;


-- Insert into Book_Author (handling multiple authors per book)
INSERT INTO Book_Author (book_id, author_id)
SELECT DISTINCT b.book_id, a.author_id
FROM good_reads g
JOIN Book b ON g.title = b.title
JOIN Author a ON g.author LIKE '%' || a.first_name || ' ' || a.last_name || '%';

SELECT * FROM Publisher LIMIT 10;
SELECT * FROM Book LIMIT 10;
SELECT * FROM Author LIMIT 10;
SELECT * FROM Book_Author LIMIT 10;

SELECT b.book_id, b.title, p.name AS publisher_name
FROM Book b
JOIN Publisher p ON b.publisher_id = p.publisher_id
LIMIT 10;

SELECT ba.book_id, b.title, a.first_name, a.last_name
FROM Book_Author ba
JOIN Book b ON ba.book_id = b.book_id
JOIN Author a ON ba.author_id = a.author_id
LIMIT 10;

SELECT p.name AS publisher, COUNT(b.book_id) AS total_books
FROM Publisher p
LEFT JOIN Book b ON p.publisher_id = b.publisher_id
GROUP BY p.name
ORDER BY total_books DESC
LIMIT 10;

SELECT a.first_name, a.last_name, COUNT(ba.book_id) AS book_count
FROM Author a
JOIN Book_Author ba ON a.author_id = ba.author_id
GROUP BY a.first_name, a.last_name
ORDER BY book_count DESC
LIMIT 10;

CREATE INDEX idx_book_title ON Book(title);
CREATE INDEX idx_author_name ON Author(first_name, last_name);

CREATE VIEW book_author_details AS
SELECT b.title, a.first_name, a.last_name, p.name AS publisher, b.published_year
FROM Book b
JOIN Book_Author ba ON b.book_id = ba.book_id
JOIN Author a ON ba.author_id = a.author_id
JOIN Publisher p ON b.publisher_id = p.publisher_id;

SELECT * FROM book_author_details LIMIT 10;

SELECT * FROM Publisher LIMIT 10;
SELECT * FROM Book LIMIT 10;
SELECT * FROM Author LIMIT 10;
SELECT * FROM Book_Author LIMIT 10;

SELECT b.title, p.name AS publisher, b.published_year
FROM Book b
JOIN Publisher p ON b.publisher_id = p.publisher_id
ORDER BY b.published_year DESC
LIMIT 10;

SELECT a.first_name, a.last_name, b.title, b.published_year
FROM Author a
JOIN Book_Author ba ON a.author_id = ba.author_id
JOIN Book b ON ba.book_id = b.book_id
ORDER BY a.last_name, a.first_name
LIMIT 10;

SELECT p.name AS publisher, COUNT(b.book_id) AS total_books
FROM Publisher p
LEFT JOIN Book b ON p.publisher_id = b.publisher_id
GROUP BY p.name
ORDER BY total_books DESC
LIMIT 10;








