create database LibraryManagementSystem;
go
use LibraryManagementSystem;

-- 1. Departments
CREATE TABLE Departments (
  DepartmentID INT PRIMARY KEY,
  DepartmentName VARCHAR(100)
);

INSERT INTO Departments VALUES
(1, 'Computer Science'),
(2, 'Mechanical'),
(3, 'Electronics');

-- 2. Authors
CREATE TABLE Authors (
  AuthorID INT PRIMARY KEY,
  AuthorName VARCHAR(100)
);

INSERT INTO Authors VALUES
(1, 'Robert C. Martin'),
(2, 'Andrew S. Tanenbaum'),
(3, 'J.K. Rowling');

-- 3. Categories
CREATE TABLE Categories (
  CategoryID INT PRIMARY KEY,
  CategoryName VARCHAR(100)
);

INSERT INTO Categories VALUES
(1, 'Fiction'),
(2, 'Networking'),
(3, 'Software Engineering');

-- 4. Status
CREATE TABLE Status (
  StatusID INT PRIMARY KEY,
  Status VARCHAR(50)
);

INSERT INTO Status VALUES
(1, 'Available'),
(2, 'Issued'),
(3, 'Reserved');

-- 5. Students
CREATE TABLE Students (
  StudentID INT PRIMARY KEY,
  StudentName VARCHAR(100),
  DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID),
  StudentEmail VARCHAR(100),
  StudentPhone VARCHAR(15)
);

INSERT INTO Students VALUES
(101, 'Arun Kumar', 1, 'arun@example.com', '9876543210'),
(102, 'Priya Sharma', 2, 'priya@example.com', '9876512345'),
(103, 'Ravi Mehta', 3, 'ravi@example.com', '9876598765');

-- 6. Books
CREATE TABLE Books (
  BookID INT PRIMARY KEY,
  BookName VARCHAR(150),
  AuthorID INT FOREIGN KEY REFERENCES Authors(AuthorID),
  CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
  Editions VARCHAR(20)
);

INSERT INTO Books VALUES
(201, 'Clean Code', 1, 3, '2nd'),
(202, 'Computer Networks', 2, 2, '5th'),
(203, 'Harry Potter', 3, 1, '1st');

-- 7. BookInventory
CREATE TABLE BookInventory (
  BookInventoryID INT PRIMARY KEY,
  BookID INT FOREIGN KEY REFERENCES Books(BookID),
  AccessNo INT UNIQUE,
  StatusID INT FOREIGN KEY REFERENCES Status(StatusID)
);

INSERT INTO BookInventory VALUES
(301, 201, 1001, 1),
(302, 201, 1002, 2),
(303, 202, 1003, 2),
(304, 203, 1004, 1);

-- 8. BorrowedBooks
CREATE TABLE BorrowedBooks (
  BorrowedBookID INT PRIMARY KEY,
  StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
  BookInventoryID INT FOREIGN KEY REFERENCES BookInventory(BookInventoryID),
  BorrowDate DATE,
  DueDate DATE,
  ReturnDate DATE
);

INSERT INTO BorrowedBooks VALUES
(401, 101, 302, '2025-06-01', '2025-06-15', NULL),
(402, 102, 303, '2025-06-03', '2025-06-17', '2025-06-20');

-- 9. Fines
CREATE TABLE Fines (
  FineID INT PRIMARY KEY,
  BorrowedBookID INT FOREIGN KEY REFERENCES BorrowedBooks(BorrowedBookID),
  FineDate DATE,
  Amount DECIMAL(10,2),
  Reason VARCHAR(100)
);

INSERT INTO Fines VALUES
(501, 402, '2025-06-20', 15.00, 'Returned Late');

-- 10. PaymentMethods
CREATE TABLE PaymentMethods (
  PaymentMethodID INT PRIMARY KEY,
  PaymentMethodName VARCHAR(50)
);

INSERT INTO PaymentMethods VALUES
(1, 'Cash'),
(2, 'UPI'),
(3, 'Card');

-- 11. PayStatus
CREATE TABLE PayStatus (
  PaymentStatusID INT PRIMARY KEY,
  Status VARCHAR(50)
);

INSERT INTO PayStatus VALUES
(1, 'Paid'),
(2, 'Pending');

-- 12. FinePayment
CREATE TABLE FinePayment (
  PaymentID INT PRIMARY KEY,
  FineID INT FOREIGN KEY REFERENCES Fines(FineID),
  PaymentMethodID INT FOREIGN KEY REFERENCES PaymentMethods(PaymentMethodID),
  PaymentStatusID INT FOREIGN KEY REFERENCES PayStatus(PaymentStatusID)
);

INSERT INTO FinePayment VALUES
(601, 501, 1, 1);

SELECT * FROM Departments;
SELECT * FROM Authors;
SELECT * FROM Categories;
SELECT * FROM Status;
SELECT * FROM Students;
SELECT * FROM Books;
SELECT * FROM BookInventory;
SELECT * FROM BorrowedBooks;
SELECT * FROM Fines;
SELECT * FROM PaymentMethods;
SELECT * FROM PayStatus;
SELECT * FROM FinePayment;

--Joins & Multi-Level Filters
--1. List StudentName, BookTitle, AuthorName, IssueDate, DueDate for all currently issued books (not returned).
select s.StudentName, b.BookName, a.AuthorName, br.BorrowDate, br.DueDate from BorrowedBooks br
inner join Students s on br.StudentID = s.StudentID
inner join BookInventory bi on br.BookInventoryID = bi.BookInventoryID
inner join Books b on bi.BookID = b.BookID
inner join Authors a on b.AuthorID = a.AuthorID 
where br.ReturnDate is not null ;

--2.Display books issued by student "Arun Kumar" that are already overdue (due date before today).
select b.BookName, bb.DueDate from BorrowedBooks bb
inner join BookInventory bi on bb.BookInventoryID = bi.BookInventoryID
inner join Books b on bi.BookID = b.BookID
inner join Students s on bb.StudentID = s.StudentID
where s.StudentName = 'Arun Kumar' and bb.DueDate < getdate() and bb.ReturnDate is null;

--3. Show Author who wrote more than one Books.
insert into Books values
(204, 'Code Rules the World', 1, 3, '2nd');

select a.AuthorName , Count(b.AuthorID) as NumberOfBooks from Books b
inner join Authors a on b.AuthorID = a.AuthorID
group by a.AuthorName
having count(b.AuthorID) > 1;

--4. List the top 3 students who borrowed the most books in the last 30 days.
select top 3 s.StudentName , count(bb.StudentID) as NumberOfBorrow from BorrowedBooks bb
inner join Students s on bb.StudentID = s.StudentID
where bb.BorrowDate >= dateadd(day, -30, getdate())
group by s.StudentName
Order by NumberOfBorrow desc;

--SECTION A – Joins, Filters, Logical Queries
--1. List all books currently borrowed, showing: StudentName, BookName, AuthorName, BorrowDate, DueDate, AccessNo, and CategoryName.
select s.StudentName, b.BookName, a.AuthorName, bb.BorrowDate, bb.DueDate, bi.AccessNo, c.CategoryName from BorrowedBooks bb
inner join Students s on bb.StudentID = s.StudentID 
inner join BookInventory bi on bb.BookInventoryID = bi.BookInventoryID
inner join Books b on bi.BookID = b.BookID
inner join Authors a on b.AuthorID = a.AuthorID
inner join Categories c on b.CategoryID = c.CategoryID
where bb.ReturnDate is null;

--2. Display books overdue by more than 5 days with StudentName, DaysOverdue, BookName.
select s.StudentName, datediff(day, bb.DueDate, GETDATE()) , b.BookName from BorrowedBooks bb
inner join Students s on bb.StudentID = s.StudentID 
inner join BookInventory bi on bb.BookInventoryID = bi.BookInventoryID
inner join Books b on bi.BookID = b.BookID
where bb.ReturnDate is null and datediff(day, bb.DueDate, GETDATE()) > 5;

--3. List the number of books borrowed by department this year (with DepartmentName and TotalBorrowed).
select d.DepartmentName, Count(*) as TotaBorrowed from BorrowedBooks bb
inner join Students s on bb.StudentID = s.StudentID
inner join Departments d on s.DepartmentID = d.DepartmentID
where year(bb.BorrowDate ) = year(getdate())
group by d.DepartmentName;

--4. Show the student who has paid the highest total fines.
select top 1 s.StudentName, Sum(f.Amount) as Amount from Fines f
inner join BorrowedBooks bb on f.BorrowedBookID = bb.BorrowedBookID
inner join Students s on bb.StudentID = s.StudentID
group by s.StudentName
order by Amount desc ;

--5. List books that have been borrowed more than 3 times overall.
select b.BookName , count(bb.BookInventoryID) as NumberOfBorrow from BorrowedBooks bb
inner join BookInventory bi on bb.BookInventoryID = bi.BookInventoryID
inner join Books b on bi.BookID = b.BookID
group by b.BookName 
having count(bb.BookInventoryID) > 3;

--SECTION B – Aggregation, Subqueries, Conditions
--6. Show total fine collected per payment method this year.
select p.PaymentMethodName, sum(f.Amount) as Total
from Fines f
inner join FinePayment pay on f.FineID = pay.FineID
inner join PaymentMethods p on pay.PaymentMethodID = p.PaymentMethodID
where year(FineDate) = year(getdate())
group by p.PaymentMethodName;

--7. Find students who returned books after more than 10 days from due date.
select s.StudentName from BorrowedBooks bb
inner join Students s on bb.StudentID = s.StudentID
where DATEDIFF(day, bb.DueDate, getdate()) >= 10 and bb.ReturnDate is null;

--8. Display all students who borrowed books from more than one category.
select s.StudentName , c.CategoryName, count(b.CategoryID) as Counts from BorrowedBooks bb
inner join Students s on bb.StudentID = s.StudentID
inner join BookInventory bi on bb.BookInventoryID = bi.BookInventoryID
inner join Books b on bi.BookID = b.BookID
inner join Categories c on b.CategoryID = c.CategoryID
group by s.StudentName, c.CategoryName
having count(b.CategoryID) > 1;

--SECTION C – Views, Functions, Stored Procedures (9–13)
--9. Create a view vw_OverdueDetails showing: StudentID, BookName, DaysLate, FineAmount (if any), where ReturnDate > DueDate.
create view vw_OverdueDetails 
as
	select bb.StudentID, b.BookName, DATEDIFF(day, bb.DueDate, bb.ReturnDate)as DaysLate, f.Amount from BorrowedBooks bb
	inner join Fines f on bb.BorrowedBookID = f.BorrowedBookID
	inner join BookInventory bi on bb.BookInventoryID = bi.BookInventoryID
	inner join Books b on bi.BookID = b.BookID
	where bb.ReturnDate > bb.DueDate and bb.ReturnDate is not null


select * from vw_OverdueDetails;


--10. Create a scalar function fn_GetTotalFineByStudent(@StudentID) returning total paid fine for a student.
create function fn_GetTotalFineByStudent(
	@StudentID int
)
returns decimal(10,2)
as
begin
	declare @TotalAmount decimal (10,2)
	select @TotalAmount = sum(f.Amount) from Fines f
	inner join BorrowedBooks bb on f.BorrowedBookID = bb.BorrowedBookID
	where bb.StudentID = @StudentID

	return isnull(@TotalAmount,0)
end

select dbo.fn_GetTotalFineByStudent(101);
