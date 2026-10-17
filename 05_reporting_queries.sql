USE LibraryDB;

-- Complete borrowing history, including returned and currently borrowed books.
SELECT
    t.transaction_id,
    u.user_id,
    u.user_name,
    b.book_id,
    b.title,
    b.author,
    t.issue_date,
    t.due_date,
    t.return_date,
    t.fine
FROM `Transactions` AS t
JOIN Users AS u ON u.user_id = t.user_id
JOIN Books AS b ON b.book_id = t.book_id
ORDER BY t.issue_date DESC, t.transaction_id DESC;

-- Books not yet returned and already past their due date.
SELECT
    t.transaction_id,
    u.user_name,
    b.title,
    t.issue_date,
    t.due_date,
    DATEDIFF(CURRENT_DATE(), t.due_date) AS days_overdue
FROM `Transactions` AS t
JOIN Users AS u ON u.user_id = t.user_id
JOIN Books AS b ON b.book_id = t.book_id
WHERE t.return_date IS NULL
  AND t.due_date < CURRENT_DATE()
ORDER BY t.due_date, t.transaction_id;

-- Fine report includes returned transactions with a positive fine.
SELECT
    t.transaction_id,
    u.user_name,
    b.title,
    t.issue_date,
    t.due_date,
    t.return_date,
    t.fine
FROM `Transactions` AS t
JOIN Users AS u ON u.user_id = t.user_id
JOIN Books AS b ON b.book_id = t.book_id
WHERE t.fine > 0
ORDER BY t.fine DESC, t.return_date DESC;

-- Borrow frequency for every title, including titles with no loans.
SELECT
    b.book_id,
    b.title,
    b.author,
    COUNT(t.transaction_id) AS times_borrowed
FROM Books AS b
LEFT JOIN `Transactions` AS t ON t.book_id = b.book_id
GROUP BY b.book_id, b.title, b.author
ORDER BY times_borrowed DESC, b.title, b.author;

-- Most frequently borrowed title(s), including ties.
WITH borrow_counts AS (
    SELECT
        b.book_id,
        b.title,
        b.author,
        COUNT(t.transaction_id) AS times_borrowed
    FROM Books AS b
    LEFT JOIN `Transactions` AS t ON t.book_id = b.book_id
    GROUP BY b.book_id, b.title, b.author
)
SELECT book_id, title, author, times_borrowed
FROM borrow_counts
WHERE times_borrowed = (
    SELECT MAX(times_borrowed)
    FROM borrow_counts
)
ORDER BY title, author;
