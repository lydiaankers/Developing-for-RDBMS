DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS copy;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS audit;
DROP VIEW IF EXISTS schools;
DROP PROCEDURE IF EXISTS create_loan;

CREATE TABLE book(
	isbn CHAR(17) NOT NULL,
    title VARCHAR(30) NOT NULL,
    author VARCHAR(30) NOT NULL,
    CONSTRAINT pri_book PRIMARY KEY(isbn));
    
CREATE TABLE student(
	`no` INT NOT NULL,
    `name` VARCHAR(30) NOT NULL,
    school CHAR(3) NOT NULL,
    embargo BIT DEFAULT FALSE,
    CONSTRAINT pri_student PRIMARY KEY(`no`));
    
CREATE TABLE copy(
	`code` INT NOT NULL,
    isbn CHAR(17) NOT NULL,
	duration TINYINT NOT NULL,
    CONSTRAINT check_copy
		CHECK (duration IN ('7','14','21')),
    CONSTRAINT pri_copy PRIMARY KEY(`code`),
    CONSTRAINT for_copy FOREIGN KEY(isbn)
    REFERENCES book(isbn) ON UPDATE CASCADE ON DELETE CASCADE);

Create TABLE loan(
	`code` INT NOT NULL,
    `no` INT NOT NULL,
    taken DATE NOT NULL,
    due DATE NOT NULL,
    `return` DATE NULL,
    CONSTRAINT pri_loan PRIMARY KEY(taken,`code`,`no`),
    CONSTRAINT for1_loan FOREIGN KEY(`no`) 
	REFERENCES student(`no`) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT for2_loan FOREIGN KEY(`code`) 
	REFERENCES copy(`code`) ON UPDATE CASCADE ON DELETE CASCADE);
    
INSERT INTO book(isbn,title,author)
	VALUES('111-2-33-444444-5','Pro JavaFX','Dave Smith'),
	('222-3-44-555555-6','Oracle systems','Kate Roberts'),
	('333-4-55-666666-7','Expert jQuery','Mike Smith');
    
INSERT INTO student(`no`,`name`,school,embargo)
	VALUES(2001,'Mike','CMP',0),
	(2002,'Andy','CMP',1),
	(2003,'Sarah','ENG',0),
	(2004,'Karen','ENG',1),
	(2005,'Lucy','BUE',0);
    
INSERT INTO copy(`code`,isbn,duration)
	VALUES(1011,'111-2-33-444444-5',21),
	(1012,'111-2-33-444444-5',14),
	(1013,'111-2-33-444444-5',7),
	(2011,'222-3-44-555555-6',21),
	(3011,'333-4-55-666666-7',7),
	(3012,'333-4-55-666666-7',14);
    
INSERT INTO loan(`code`,`no`,taken,due,`return`)
	VALUES(1011,2002,'2022-01-10','2022-01-31','2022-01-31'),
	(1011,2002,'2022-02-05','2022-02-26','2022-02-23'),
	(1011, 2003, '2022-05-10', '2022-05-31', NULL),
	(1013, 2003, '2021-03-02', '2021-03-16', '2021-03-10'),
	(1013, 2002, '2021-08-02', '2021-08-16', '2021-08-16'),
	(2011, 2004, '2020-02-01', '2020-02-22', '2020-02-20'),
	(3011, 2002, '2022-07-03', '2022-07-10', NULL),
	(3011, 2005, '2021-10-10', '2021-10-17', '2021-10-20');
 
 -- CREATE VIER SECTION
 CREATE VIEW schools
	AS 
		SELECT `no`, `name`, school, embargo
        FROM student
        WHERE school = 'CMP'
        WITH CHECK OPTION; -- this allows every row that is inserted or updated through the view must conform to the definition of the view
 
 -- invalid update test
 -- UPDATE schools SET school = 'BUE';
 
 -- CREATE PROCEDURE SECTION
 DELIMITER $$
 
CREATE PROCEDURE create_loan (IN book_isbn CHAR(17), IN student_no INT)
  BEGIN
  
    DECLARE complete BOOLEAN DEFAULT FALSE;
    
    -- ToDo : declaring variable(s) !
    DECLARE cursor_code INT;
    DECLARE loan_duration TINYINT;
    DECLARE Sembargo BIT;
    
    -- DECLARE book_copy INT;
    DECLARE copy_cursor CURSOR FOR
		SELECT `code`, duration
			FROM copy 
            WHERE isbn = book_isbn;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
      SET complete = TRUE;
      
    -- ToDo : checking student embargo !
    IF (EXISTS(
		SELECT `no`, embargo FROM student WHERE (`no` = student_no) AND (embargo =1))) THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = ' Student doesnt fit criteria to loan a book';
    END IF;
    
    OPEN copy_cursor;
    
    backflip : LOOP
      FETCH NEXT FROM copy_cursor INTO cursor_code, loan_duration; 
      
      -- ToDo : when cursor runs out there is no book copy available !
      IF cursor_code IS NULL THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = ' No availible book copy';
      END IF;
      
      IF cursor_code IS NOT NULL THEN
        INSERT INTO loan
          (`code`, `no`, taken, due, `return`)
          VALUES
            -- ToDo : employ date & time functions !
            (cursor_code, student_no, current_date(), adddate(current_date(), INTERVAL loan_duration DAY), NULL);
        LEAVE backflip;
      END IF;
    END LOOP;
    CLOSE copy_cursor;
  END$$
  
  DELIMITER ;
  
  -- TEST PROCEDURE STATEMENT
  -- CALL create_loan('111-2-33-444444-5',2001);

  
  -- Trigger statement
CREATE TABLE audit (
	audit_no INT NOT NULL AUTO_INCREMENT,
	`code` INT NOT NULL,
	`no` INT NOT NULL,
    taken DATE NOT NULL,
    due DATE NOT NULL,
    `return` DATE NOT NULL,
	CONSTRAINT pri_audit PRIMARY KEY(audit_no));
  
DELIMITER $$
CREATE TRIGGER loan_audit
	AFTER UPDATE ON audit FOR EACH ROW
	BEGIN
    IF (NEW.return IS NOT NULL) THEN
      IF (NEW.`return` > NEW.due) THEN
        INSERT INTO audit 
        (`code`, `no`, taken, due, `return`)
        VALUES
        (NEW.`code`, NEW.`no`, NEW.taken, NEW.due, NEW.`return`);
		END IF;
	END IF;
	END$$
DELIMITER ;

-- SELECT STATEMENT SECTION
-- 1
SELECT *
	FROM book;
   
-- 2   
SELECT `no`,`name`,school
	FROM student
	ORDER BY school DESC;
 
-- 3
SELECT isbn,title
	FROM book
	WHERE author LIKE '%Smith%';
        
-- 4
SELECT MAX(due)
	FROM LOAN;
    
-- 5     DOUBLE CHECK
 SELECT `no`
	FROM loan 
	WHERE due = (SELECT MAX(due)
					FROM loan);

-- 6
SELECT `no`, `name`
	FROM student
    WHERE `no` = (SELECT `no`
					FROM loan
					WHERE due = (SELECT MAX(due) 
									FROM loan));
    
-- 7
SELECT `no`,`code`,due
	FROM loan
    WHERE (`return` IS NULL) AND (year(due) = YEAR(CURRENT_DATE()));
   
-- 8
SELECT DISTINCT student.`no`, student.`name`, book.isbn, book.title
	from copy INNER JOIN loan
		ON copy.`code` = loan.`code`
    INNER JOIN student
		ON loan.`no` = student.`no`
    INNER JOIN book
		ON copy.isbn = book.isbn
    WHERE copy.duration = 7;
    
-- 9 
SELECT student.`no`, student.`name`  /* DOUBLE CHECK*/
	FROM student INNER JOIN loan
    ON student.`no` = loan.`no`
    WHERE due = (SELECT MAX(due)
					FROM loan);
    
-- 10 
SELECT book.title, COUNT(book.title) AS FREQUENCY
	FROM book INNER JOIN copy 
		ON book.isbn = copy.isbn
	INNER JOIN loan
		ON copy.`code` = loan.`code` 
	GROUP BY book.title   
		HAVING (COUNT(book.title)); 

-- 11
SELECT book.title, COUNT(book.title) AS FREQUENCY 
	FROM book INNER JOIN copy 
		ON book.isbn = copy.isbn
	INNER JOIN loan
		ON copy.`code` = loan.`code` 
	GROUP BY book.title 
		HAVING (COUNT(book.title))>=2; 
        