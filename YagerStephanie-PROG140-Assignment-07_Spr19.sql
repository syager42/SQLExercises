--*  PROG 140           Assignment   #7		              DUE DATE:  Consult course calendar
							
/*
PURPOSE:

Knowledge:

•	Explain why a stored procedure executes faster than an equivalent SQL script.
•	Describe the basic process for validating data within a stored procedure.
•	Describe the basic purpose of the system stored procedures.
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

    1. Download the following SQL file and rename it Xxxxx-PROG140-Assignment-07, where Xxxxx is your last and first name. 
	For example, I would rename this file FreebergCarl-PROG140-Assignment-07.sql.

		Xxxxx-PROG140-Assignment-07.sql

    2. Open the file in SQL Server Management Studio (SSMS).

    3. Add your SQL code in the space provided below each question. The questions are written as comments so they will not execute in SQL Server. 

    4. Proofread your document to make sure all questions are answered completely and that it is easy to distinguish your responses from the questions on the page.

    5. Return to this Assignment page, attach your completed file, and submit.

 

CRITERIA:

    o Answer all the questions
    o If you do not understand a question, did you ask for help from the teacher, a classmate, the Discussion board, or a tutor?
    o Your answer/query is in the right place underneath the question
    o Your answer/query is not commented out
    o Your answer/query executes without an error
    o You have renamed the file as specified above and submitted it via Canvas
    o If you cannot complete the Exercise, did you communicate with the teacher (before the due date) so that he/she/they understands your situation?

For this Assignment, we will use the MyGuitarShop database. 

Test if a procedure already exists before creating it. 
Assuming you are already pointing to the correct database and you want to create a procedure named spInsertCategory, the easiest syntax to drop it before creating a new one is:

	DROP PROC IF EXISTS spInsertCategory;
  
*/

--- CHAPTER 15 - HOW TO CODE STORED PROCEDURES ---

/*
1.	Write a script that creates and calls a stored procedure named spInsertCategory. 

	First, code a statement that creates a procedure that adds a new row to the Categories table. 
	To do that, this procedure should have one parameter for the category name.

	Code at least two EXEC statements that test this procedure -- one that succeeds, and one that fails. 
	(Note that this table doesn’t allow duplicate category names.)   
*/
USE MyGuitarShop;

-- Test if proc already exists and drop it if does:
DROP PROC IF EXISTS spInsertCategory;

-- Create the proc:
GO
CREATE PROC spInsertCategory
	@NewCategory varchar(30)
AS
INSERT INTO Categories
VALUES (@NewCategory); 


-- Test fail: 

GO
USE MyGuitarShop;
BEGIN TRY
	EXEC spInsertCategory 'Drums';
END TRY
BEGIN CATCH
	PRINT 'Error: ' + CONVERT(varchar(25), ERROR_NUMBER()) + ' , ' +
		CONVERT(varchar(200), ERROR_MESSAGE());
END CATCH;


-- Test success: 

GO
USE MyGuitarShop;
BEGIN TRY
	EXEC spInsertCategory 'Clarinets';
END TRY
BEGIN CATCH
	PRINT 'Error: ' + CONVERT(varchar(25), ERROR_NUMBER()) + ' , ' +
		CONVERT(varchar(200), ERROR_MESSAGE());
END CATCH;

/*
2.	Write a script that creates and calls a stored procedure named spInsertProduct 
	that inserts a row into the Products table. 
	
	This stored procedure should accept five parameters. 
	One parameter for each of these columns: CategoryID, ProductCode, ProductName, ListPrice, and DiscountPercent.
	
	This stored procedure should set the Description column to an empty string, 
	and it should set the DateAdded column to the current date.
	
	If the value for the ListPrice column is a negative number, the stored procedure should raise an error 
	that indicates that this column doesn’t accept negative numbers. 
	
	Similarly, the procedure should raise an error if the value for the DiscountPercent column is a negative number.
	
	Test ALL the branches of your logic. Raise errors with THROW syntax.

	Code at least two EXEC statements that test this procedure.
*/
USE MyGuitarShop;
GO

-- Test if proc already exists and drop it if does:
DROP PROC IF EXISTS spInsertProduct;

GO

-- Create the proc:

CREATE PROC spInsertProduct
	@CategoryID int,
	@ProductCode varchar(10),
	@ProductName varchar(255),
	@ListPrice money,
	@DiscountPercent money
AS
IF @ListPrice < 0
	THROW 50001, 'Product price can not be negative',1;
IF @DiscountPercent < 0
	THROW 50001, 'Discount percent can not be negative', 1;
INSERT INTO Products
VALUES (@CategoryID, @ProductCode, @ProductName, '', @ListPrice, @DiscountPercent, GETDATE());




-- Test fail: 

EXEC spInsertProduct 3, 'drums', 'Loud drums', 300, -20;


-- Test success: 

EXEC spInsertProduct 3, 'drumz', 'Cool looking drums', 300, 20;


/*
3.	Write a script that creates and calls a stored procedure named spUpdateProductDiscount 
	that updates the DiscountPercent column in the Products table. 

	This procedure should have one parameter for the product ID and another for the discount percent.

	If the value for the DiscountPercent column is a negative number, the stored procedure 
	should raise an error that indicates that the value for this column must be a positive number.

	Code at least two EXEC statements that test this procedure.
*/
GO
USE MyGuitarShop;
GO
-- Test if proc already exists and drop it if does:

DROP PROC IF EXISTS spUpdateProductDiscount

GO

-- Create the proc:

CREATE PROC spUpdateProductDiscount
		@UpdateProdID int,
		@UpdateProdDisc money
AS
IF @UpdateProdDisc < 0
THROW 50001, 'The product discount can not be negative', 1;
UPDATE Products
SET DiscountPercent = @UpdateProdDisc
WHERE ProductID = @UpdateProdID;


-- Test fail: 

EXEC spUpdateProductDiscount 8, -20;



-- Test success: 

EXEC spUpdateProductDiscount 5, 15;




