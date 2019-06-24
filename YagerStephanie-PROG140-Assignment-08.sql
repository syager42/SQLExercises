--*  PROG 140           Assignment # 8	(functions and triggers)	       DUE DATE:  Consult course calendar
							
/*
PURPOSE:

Knowledge:

•	Describe the two types of user-defined functions.
•	Describe the two types of triggers.
•	Describe the effects of the WITH ENCRYPTION and WITH SCHEMABINDING clauses on a stored procedure, 
	user-defined function, or trigger.
•	Explain why you’d want to use the ALTER statement rather than dropping and recreating a procedure, 
	function, or trigger.
•	Given a stored procedure, user-defined function, or trigger, explain what each statement does.


Skills:

•	Given an expression, write a scalar-valued user-defined function based on the formula or expression.
•	Given a SELECT statement with a WHERE clause, write a table-valued user-defined function that replaces it.
•	Given the specifications for a database problem that could be caused by an action query, write a trigger that prevents the problem.
•	Given the specifications for a database problem that could be caused by a DDL statement, write a trigger that prevents the problem.


TASK:

    1. Download the following SQL file and rename it Xxxxx-PROG140-Assignment-08, where Xxxxx is your last and first name. 
	For example, I would rename this file FreebergCarl-PROG140-Assignment-08.sql.

		Xxxxx-PROG140-Assignment-08.sql

    2. Open the file in SQL Server Management Studio (SSMS).

    3. Add your SQL code in the space provided below each question. The questions are written as comments so they will not execute in SQL Server. 

    4. Proofread your document to make sure all questions are answered completely and that it is easy to distinguish your responses from the questions on the page.

    5. Return to this Exercise page, attach your completed file, and submit.

 

CRITERIA:

    o Answer all the questions
    o If you do not understand a question, did you ask for help from the teacher, a classmate, the Discussion board, or a tutor?
    o Your answer/query is in the right place underneath the question
    o Your answer/query is not commented out
    o Your answer/query executes without an error
    o You have renamed the file as specified above and submitted it via Canvas
    o If you cannot complete the Exercise, did you communicate with the teacher (before the due date) so that he/she/they understands your situation?

	
    You are to develop SQL statements for each task listed. You should type your SQL statements under each task.
	The fields' names are written as if a person is asking you for the report. You will need to look at the data
	and understand that list price is in the ListPrice field, for example.
	Add comments to describe your reasoning when you are in doubt about something. 


--- CHAPTER 15 - FUNCTIONS AND TRIGGERS ---
*/

USE MyGuitarShop;

/*

1.	Write a script that creates and calls a function named fnDiscountPrice that calculates 
the discount price of an item in the OrderItems table (discount amount subtracted from item price). 
To do that, this function should accept one parameter for the item ID, 
and it should return the value of the discount price for that item.
*/
GO
CREATE FUNCTION fnDiscountPrice
	(@ItemID int)
	RETURNS money
BEGIN
	RETURN (SELECT (ItemPrice - DiscountAmount) 
			FROM OrderItems
			WHERE ItemID = @ItemID);
END;

GO
PRINT CONVERT(varchar, dbo.fnDiscountPrice(3));
GO
/*
2.	Write a script that creates and calls a function named fnItemTotal that calculates 
the total amount of an item in the OrderItems table (discount price multiplied by quantity). 
To do that, this function should accept one parameter for the item ID, 
it should use the DiscountPrice function that you created in question 1, 
and it should return the value of the total for that item.
*/
GO
CREATE FUNCTION fnItemTotal
	(@ItemID int)
	RETURNS money
BEGIN
	RETURN(SELECT dbo.fnDiscountPrice(@ItemID) * Quantity
			FROM OrderItems
			WHERE ItemID = @ItemID);
END;

GO 
PRINT CONVERT(varchar, dbo.fnItemTotal(5));

/*
3. Write a Scalar UDF, called fnYearMonth that will take any date as an input parameter and return
that same date in the following format:  YYYY-MMM  example:  2018-Nov  
(4 digits for the year, a hyphen, and 3 characters for the Month)
Note:  the Return will be in varchar format, NOT date format

Include at least 3 statements to test this new UDF with different dates
*/

GO
CREATE FUNCTION fnYearMonth
	(@DateChange date)
	RETURNS varchar(8)
BEGIN
	DECLARE @TheYear varchar(4) = SUBSTRING(convert(varchar, @DateChange, 107), 9, 8) --tested this code, gets YYYY
	DECLARE @TheMonth varchar(3) = SUBSTRING(convert(varchar, @DateChange, 107), 1, 3) --
	RETURN(CONCAT(@TheYear, '-', @TheMonth));
END;
GO
DECLARE @NewDate date = '2015-8-5'
PRINT dbo.fnYearMonth(@NewDate);

DECLARE @SecondDate date = '5/5/1998'
PRINT dbo.fnYearMonth(@SecondDate);

DECLARE @ThirdDate date = '12 Sep 15'
PRINT dbo.fnYearMonth(@ThirdDate);

/* 
4.	Create a trigger named Products_UPDATE that checks the new value for the DiscountPercent column 
of the Products table. This trigger should raise an appropriate error if the discount percent 
is greater than 100 or less than 0.

If the new discount percent is between 0 and 1, this trigger should modify the new discount percent 
by multiplying it by 100. That way, a discount percent of .2 becomes 20.

Test this trigger with an appropriate UPDATE statement.
*/
GO
CREATE TRIGGER Products_UPDATE
ON Products
AFTER INSERT, UPDATE
AS
BEGIN
	IF (SELECT p.DiscountPercent FROM Products p 
			JOIN deleted d ON p.ProductID = d.ProductID) > 100 OR
		(SELECT p.DiscountPercent FROM Products p 
			JOIN deleted d ON p.ProductID = d.ProductID) < 0
		BEGIN 
			ROLLBACK TRAN;
			THROW 50001, 'Discount percentage must be between 0 and 100', 1;
	END;
	ELSE IF (SELECT p.DiscountPercent FROM Products p 
			JOIN deleted d ON p.ProductID = d.ProductID) < 1
		BEGIN
			UPDATE Products
			SET DiscountPercent = DiscountPercent * 100
			WHERE Products.ProductID = (SELECT d.ProductID 
										FROM Products p JOIN deleted d 
										ON p.ProductID = d.ProductID);
	END;
END;
GO
UPDATE Products
SET DiscountPercent = .15
WHERE ProductID = 1;

UPDATE Products
SET DiscountPercent = 105
WHERE ProductID = 1;

UPDATE Products
SET DiscountPercent = 35
WHERE ProductID = 1;


/*
5.	Create a trigger named Products_INSERT that inserts the current date for the DateAdded column 
of the Products table if the value for that column is null.

Test this trigger with an appropriate INSERT statement.
*/
GO
CREATE TRIGGER Products_INSERT
ON Products
AFTER INSERT, UPDATE
AS
BEGIN
	IF (SELECT i.DateAdded 
		FROM Products p 
			JOIN inserted i ON p.ProductID = i.ProductID
			) IS NULL
	BEGIN
		UPDATE Products
		SET DateAdded = GETDATE()
		WHERE Products.ProductID = (SELECT i.ProductID
									FROM Products p JOIN inserted i
									ON p.ProductID = i.ProductID);
	END;
END;

INSERT INTO Products
VALUES (1, 'testcode', 'testname', 'testdescrip', 100.00, 25, NULL);


/*
6.	Create a table named ProductsAudit. This table should have all columns of the Products table, 
except the Description column. Also, it should have an AuditID column for its primary key, 
and the DateAdded column should be changed to DateUpdated.

Create a trigger named Products_UPDATE. 

This trigger should insert the old data about the product into the ProductsAudit table after the row is updated. 

Then, test this trigger with an appropriate UPDATE statement.
*/
GO
USE MyGuitarShop;
GO
CREATE TABLE ProductsAudit
(AuditID	INT		PRIMARY KEY IDENTITY,
 ProductID	INT		NOT NULL, 
 CategoryID INT		NULL,
 ProductCode varchar(10) NULL,
 ProductName varchar(255) NOT NULL,
 ListPrice	 money	NOT NULL,
 DiscountPercent money NOT NULL,
 DateUpdated	datetime	NOT NULL)

 GO
 CREATE TRIGGER Products_UPDATE
 ON Products
 AFTER UPDATE
 AS
 BEGIN
	INSERT INTO ProductsAudit
	SELECT d.ProductID, d.CategoryID, d.ProductCode, d.ProductName,
		d.ListPrice, d.DiscountPercent, GETDATE()
	FROM Products p JOIN deleted d ON p.ProductID = d.ProductID;
END;
GO

UPDATE Products
SET ListPrice = 1000.00
WHERE ProductID = 1;