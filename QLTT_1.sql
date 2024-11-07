CREATE DATABASE SCHOOL

USE SCHOOL;




DECLARE @Counter INT = 1;

WHILE @Counter <= 100000
BEGIN
    INSERT INTO STUDENTS(Name, Age, Grade)
    VALUES (
        'Student ' + CAST(@Counter AS NVARCHAR(10)), 
        (@Counter % 50) + 10,                           
        CHAR(65 + (@Counter % 5))                       
    );
    SET @Counter = @Counter + 1;
END;

SET STATISTICS TIME ON;
SELECT * 
FROM STUDENTS
WHERE ID >= 1 AND ID 
SET STATISTICS TIME OFF;

SELECT *
FROM STUDENTS