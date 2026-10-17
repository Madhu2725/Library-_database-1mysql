USE LibraryDB;

INSERT INTO Users (user_name, email, phone)
SELECT sample.user_name, sample.email, sample.phone
FROM (
    SELECT 'Aarav Sharma' AS user_name,
           'aarav.sharma@example.com' AS email,
           '9876543210' AS phone
    UNION ALL
    SELECT 'Meera Patel', 'meera.patel@example.com', '9876543211'
    UNION ALL
    SELECT 'Ishaan Rao', 'ishaan.rao@example.com', NULL
) AS sample
WHERE NOT EXISTS (
    SELECT 1
    FROM Users AS existing_user
    WHERE existing_user.email = sample.email
);

INSERT INTO Books (title, author, total_copies, available_copies)
SELECT sample.title, sample.author, sample.total_copies, sample.total_copies
FROM (
    SELECT 'The Hobbit' AS title, 'J.R.R. Tolkien' AS author, 3 AS total_copies
    UNION ALL
    SELECT 'Pride and Prejudice', 'Jane Austen', 2
    UNION ALL
    SELECT '1984', 'George Orwell', 2
    UNION ALL
    SELECT 'To Kill a Mockingbird', 'Harper Lee', 1
    UNION ALL
    SELECT 'The Great Gatsby', 'F. Scott Fitzgerald', 2
) AS sample
WHERE NOT EXISTS (
    SELECT 1
    FROM Books AS existing_book
    WHERE existing_book.title = sample.title
      AND existing_book.author = sample.author
);

SELECT user_id, user_name, email, phone
FROM Users
WHERE email IN (
    'aarav.sharma@example.com',
    'meera.patel@example.com',
    'ishaan.rao@example.com'
)
ORDER BY user_id;

SELECT book_id, title, author, total_copies, available_copies
FROM Books
WHERE (title = 'The Hobbit' AND author = 'J.R.R. Tolkien')
   OR (title = 'Pride and Prejudice' AND author = 'Jane Austen')
   OR (title = '1984' AND author = 'George Orwell')
   OR (title = 'To Kill a Mockingbird' AND author = 'Harper Lee')
   OR (title = 'The Great Gatsby' AND author = 'F. Scott Fitzgerald')
ORDER BY book_id;
