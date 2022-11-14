# Developing-for-RDBMS_
Second year "Database Systems" using MySQL_
The core component of the database are the books, which are specified by isbn, title & author. 
For each book there are specific copies available, which are specified by code, isbn & loan 
duration (7, 14 or 21 days).
The set of students, who are specified by no, name, school & embargo (defaults to false, but 
when true prevents book loans) may loan copies of books for their corresponding loan duration. 
To support this, the database records the date the book was taken, the date it is due back & 
the date it is actually returned.
You should produce the following DDL statements in MySQL . .
1. CREATE TABLE Statements.
o Include constraints specified in the diagram or derived from the sample data including 
DEFAULT, UNIQUE, CHECK, PRIMARY KEY & FOREIGN KEY where appropriate.
2. CREATE VIEW Statements.
o Produce a view that returns only those students who belong to the “CMP” school and 
rejects any attempt to insert or update students belonging to any other school.
o Write a simple statement to test rejection.
3. CREATE PROCEDURE Statements.
o Produce a procedure that issues a new loan. The procedure should accept a book isbn 
& student no as arguments then search for an available copy of the book before 
inserting a new row in the loan table. A suitable error should be raised for problems 
such as the student having an embargo or no copies of the book being available.
o Tips . . CURSOR, LOOP, SIGNAL
4. CREATE TRIGGER Statements.
o Produce an audit trail (in a separate table) that records the code, no, taken, due & 
return fields when a loan table row is updating only when the loan is overdue.
The file DBSyS_CourseWork_01.xlsx on Canvas, contains sample data for each of the four tables 
and should be inserted so as to ensure consistent testing data.
You should produce the following DML statements in MySQL . .
Write the appropriate statements to insert the sample data.
1. Fetch every book’s isbn, title & author.
2. Fetch every student’s no, name & school in descending order by school.
3. Fetch any book’s isbn & title where that book’s author contains the string “Smith”.
4. Calculate the latest due date for any book copy.
5. Modify the query from Q4 to now fetch only the student no.
o Tips . . Sub-Query
6. Modify the query from Q5 to also fetch the student name.
o Tips . . Nested Sub-Query
7. Fetch the student no, copy code & due date for loans in the current year which have not 
yet been returned.
o Tips . . YEAR(), CURRENT_DATE(), IS NULL
8. Uniquely fetch the student no & name along with the book isbn & title for students who 
have loaned a 7 day duration book.
o Tips . . DISTINCT, INNER JOIN
9. Solve the problem from Q6 using JOINS where possible.
o Tips . . INNER JOIN, Sub-Query
10. Calculate then display the loan frequency for every book.
o Tips . . COUNT(), INNER JOIN, GROUP BY
11. Modify the query from Q10 to only show a book when it has been loaned two or more times.
o Tips . . HAVING
