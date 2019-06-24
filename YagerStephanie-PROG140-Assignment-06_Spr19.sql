--*  PROG 140           Assignment   #6		              DUE DATE:  Consult course calendar
							
/*
PURPOSE:

Knowledge:

•	Describe the use of scripts.
•	Describe the difference between a scalar variable and a table variable.
•	Describe the scope of a local variable.
•	Describe the use of cursors.
•	Describe the scopes of temporary tables, table variables, and derived tables.
•	Describe the use of dynamic SQL.
•	Given a Transact-SQL script, explain what each statement in the script does.


Skills:

•	Given a Transact-SQL script written as a single batch, insert GO commands to divide the script into appropriate batches.
•	Given the specification for a database problem, write a script that solves it.
•	Use the SQLCMD utility to execute a query or a script.



TASK:

    1. Download the following SQL file and rename it Xxxxx-PROG140-Assignment-06, where Xxxxx is your last and first name. 
	For example, I would rename this file FreebergCarl-PROG140-Assignment-06.sql.

		Xxxxx-PROG140-Assignment-06.sql

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


    For this Assignment, we will use the MyGuitarShop database. We tell SQL Server which database 
    to use via the USE statement.

    Do not remove the USE statement. 
*/

--- CHAPTER 14 - HOW TO CODE SCRIPTS -- 


--1.	Write a script that declares a variable and sets it to the count of all orders in the Orders table. 
--		If the count is greater than or equal to 40, the script should display a message that says, 
--		“The number of orders is less than or equal to 50”. 
--		Otherwise, it should say, “The number of orders is greater than 50”.

USE MyGuitarShop;

DECLARE @CountAllOrders INTEGER;
SELECT @CountAllOrders = COUNT(OrderID) FROM Orders;

--Both 40 and 50 were used in the question, but it looks like it was probably supposed
--to be 50 each time, so I went with that!
IF (@CountAllOrders <= 50) PRINT 'The number of orders is less than or equal to 50';
ELSE PRINT 'The number of orders is greater than 50';



--2.	Write a script that uses four variables to store:
--		(1) the count of all of the products in the Products table, 
--		(2) the average list price for those products, 
--		(3) the minimum list price for those products, and
--		(4) the maximum list price for those products.
--		If the product count is greater than or equal to 7, 
--		the script should print a message that displays the values of all the variables. 
--		Otherwise, the script should print a message that says, “The number of products is less than 7”.


USE MyGuitarShop;


DECLARE @CountProducts integer, @AvgListPrice decimal(8,2),
	@MinListPrice decimal(8,2), @MaxListPrice decimal(8,2);

SELECT @CountProducts = COUNT(ProductID) FROM Products;
SELECT @AvgListPrice = AVG(ListPrice) FROM Products;
SELECT @MinListPrice = MIN(ListPrice) FROM Products;
SELECT @MaxListPrice = MAX(ListPrice) FROM Products;

IF (@CountProducts >= 7)
	BEGIN
		PRINT 'The average product list price is: ' + CONVERT(varchar, @AvgListPrice);
		PRINT 'The minimum product list price is: ' + CONVERT(varchar, @MinListPrice);
		PRINT 'The maximum product list price is: ' + CONVERT(varchar, @MaxListPrice);
	END;
ELSE PRINT 'The number of products is less than 7';


--3.	Write a script that attempts to insert a new category named “Guitars” into the Categories table. 
--		If the insert is successful, the script should display this message: SUCCESS: Record was inserted.
--		If the update is unsuccessful, the script should display a message something like this:
--		FAILURE: Record was not inserted.
--		Error 2627: Violation of UNIQUE KEY constraint 'UQ__Categori__8517B2E0A87CE853'. 
--		Cannot insert duplicate key in object 'dbo.Categories'. The duplicate key value is (Guitars).


USE MyGuitarShop;

BEGIN TRY
	INSERT Categories
	VALUES ('Guitars');
	PRINT 'SUCCESS: Record was inserted.';
END TRY
BEGIN CATCH
	PRINT 'FAILURE: Record was not inserted.';
	PRINT 'Error ' + CONVERT(varchar, ERROR_NUMBER(), 1) +
		': ' + ERROR_MESSAGE();
END CATCH;




