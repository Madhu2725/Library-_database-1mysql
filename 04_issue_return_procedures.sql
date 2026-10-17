USE LibraryDB;

DELIMITER //

DROP PROCEDURE IF EXISTS sp_issue_book//
CREATE PROCEDURE sp_issue_book(
    IN p_user_id INT,
    IN p_book_id INT,
    IN p_due_date DATE
)
BEGIN
    DECLARE v_user_count INT DEFAULT 0;
    DECLARE v_book_count INT DEFAULT 0;
    DECLARE v_available_copies INT DEFAULT 0;
    DECLARE v_transaction_id INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User ID is required.';
    END IF;

    SELECT COUNT(*)
      INTO v_user_count
      FROM Users
     WHERE user_id = p_user_id;

    IF v_user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot issue book: user ID does not exist.';
    END IF;

    IF p_book_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Book ID is required.';
    END IF;

    SELECT COUNT(*)
      INTO v_book_count
      FROM Books
     WHERE book_id = p_book_id;

    IF v_book_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot issue book: book ID does not exist.';
    END IF;

    IF p_due_date IS NULL OR p_due_date < CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Due date must be today or a future date.';
    END IF;

    SELECT available_copies
      INTO v_available_copies
      FROM Books
     WHERE book_id = p_book_id
     FOR UPDATE;

    IF v_available_copies <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot issue book: no copies are available.';
    END IF;

    UPDATE Books
       SET available_copies = available_copies - 1
     WHERE book_id = p_book_id
       AND available_copies > 0;

    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Book inventory update failed; issue was cancelled.';
    END IF;

    INSERT INTO `Transactions` (user_id, book_id, issue_date, due_date)
    VALUES (p_user_id, p_book_id, CURRENT_DATE(), p_due_date);

    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaction insert failed; issue was cancelled.';
    END IF;

    SET v_transaction_id = LAST_INSERT_ID();
    COMMIT;

    SELECT v_transaction_id AS transaction_id,
           'Book issued successfully.' AS result;
END//

DROP PROCEDURE IF EXISTS sp_return_book//
CREATE PROCEDURE sp_return_book(
    IN p_transaction_id INT,
    IN p_return_date DATE,
    IN p_daily_fine_rate DECIMAL(10,2)
)
BEGIN
    DECLARE v_transaction_count INT DEFAULT 0;
    DECLARE v_return_date DATE DEFAULT NULL;
    DECLARE v_issue_date DATE DEFAULT NULL;
    DECLARE v_due_date DATE DEFAULT NULL;
    DECLARE v_book_id INT DEFAULT NULL;
    DECLARE v_available_copies INT DEFAULT 0;
    DECLARE v_fine DECIMAL(10,2) DEFAULT 0.00;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_transaction_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaction ID is required.';
    END IF;

    SELECT COUNT(*)
      INTO v_transaction_count
      FROM `Transactions`
     WHERE transaction_id = p_transaction_id;

    IF v_transaction_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot return book: transaction ID does not exist.';
    END IF;

    SELECT return_date, issue_date, due_date, book_id
      INTO v_return_date, v_issue_date, v_due_date, v_book_id
      FROM `Transactions`
     WHERE transaction_id = p_transaction_id
     FOR UPDATE;

    IF v_return_date IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This transaction has already been returned.';
    END IF;

    IF p_return_date IS NULL OR p_return_date < v_issue_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Return date must be on or after the issue date.';
    END IF;

    IF p_daily_fine_rate IS NULL OR p_daily_fine_rate < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Daily fine rate must be zero or greater.';
    END IF;

    SET v_fine = GREATEST(DATEDIFF(p_return_date, v_due_date), 0)
                 * p_daily_fine_rate;

    SELECT available_copies
      INTO v_available_copies
      FROM Books
     WHERE book_id = v_book_id
     FOR UPDATE;

    UPDATE Books
       SET available_copies = available_copies + 1
     WHERE book_id = v_book_id
       AND available_copies < total_copies;

    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Book inventory update failed; return was cancelled.';
    END IF;

    UPDATE `Transactions`
       SET return_date = p_return_date,
           fine = v_fine
     WHERE transaction_id = p_transaction_id
       AND return_date IS NULL;

    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Return record update failed; return was cancelled.';
    END IF;

    COMMIT;

    SELECT p_transaction_id AS transaction_id,
           p_return_date AS return_date,
           v_fine AS fine,
           'Book returned successfully.' AS result;
END//

DELIMITER ;

SHOW PROCEDURE STATUS
WHERE Db = 'LibraryDB'
  AND Name IN ('sp_issue_book', 'sp_return_book');
