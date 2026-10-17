CREATE DATABASE IF NOT EXISTS LibraryDB
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE LibraryDB;

CREATE TABLE IF NOT EXISTS Users (
    user_id INT NOT NULL AUTO_INCREMENT,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(15) NULL,
    PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_name_not_blank
        CHECK (CHAR_LENGTH(TRIM(user_name)) > 0),
    CONSTRAINT chk_users_email_not_blank
        CHECK (CHAR_LENGTH(TRIM(email)) > 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Books (
    book_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    PRIMARY KEY (book_id),
    CONSTRAINT chk_books_title_not_blank
        CHECK (CHAR_LENGTH(TRIM(title)) > 0),
    CONSTRAINT chk_books_author_not_blank
        CHECK (CHAR_LENGTH(TRIM(author)) > 0),
    CONSTRAINT chk_books_total_copies
        CHECK (total_copies > 0),
    CONSTRAINT chk_books_available_copies
        CHECK (available_copies >= 0 AND available_copies <= total_copies)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Transactions` (
    transaction_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    fine DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (transaction_id),
    CONSTRAINT fk_transactions_user
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_transactions_book
        FOREIGN KEY (book_id) REFERENCES Books (book_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_transactions_dates
        CHECK (
            due_date >= issue_date
            AND (return_date IS NULL OR return_date >= issue_date)
        ),
    CONSTRAINT chk_transactions_fine
        CHECK (fine >= 0)
) ENGINE = InnoDB;

SHOW TABLES;
