USE LibraryDB;

-- Add a dedicated demo book once; rerunning this script will not duplicate it.
INSERT INTO Books (title, author, total_copies, available_copies)
SELECT 'SQL Fundamentals - CRUD Demo', 'Project Demo Author', 2, 2
WHERE NOT EXISTS (
    SELECT 1
    FROM Books
    WHERE title = 'SQL Fundamentals - CRUD Demo'
      AND author = 'Project Demo Author'
);

-- Update the dedicated demo book without changing inventory counts.
UPDATE Books
SET author = 'Updated Demo Author'
WHERE title = 'SQL Fundamentals - CRUD Demo'
  AND author = 'Project Demo Author';

-- Register a dedicated demo user once.
INSERT INTO Users (user_name, email, phone)
SELECT 'Library Demo User', 'library.demo@example.com', NULL
WHERE NOT EXISTS (
    SELECT 1
    FROM Users
    WHERE email = 'library.demo@example.com'
);

-- Search books by title or author (edit the LIKE pattern to search).
SELECT book_id, title, author, total_copies, available_copies
FROM Books
WHERE title LIKE '%SQL%'
   OR author LIKE '%Demo%'
ORDER BY title, author;

-- List all books.
SELECT book_id, title, author, total_copies, available_copies
FROM Books
ORDER BY title, author;

-- List all registered users.
SELECT user_id, user_name, email, phone
FROM Users
ORDER BY user_id;
