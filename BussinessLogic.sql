CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    Amount DECIMAL(10,2)
);


INSERT INTO Orders VALUES
(1, '2024-01-05', 1500),
(2, '2024-01-15', 2000),
(3, '2024-02-10', 3000),
(4, '2024-02-25', 2500),
(5, '2024-03-03', 4000),
(6, '2024-03-20', 1000),
(7, '2024-04-05', 5000),
(8, '2024-04-25', 2000),
(9, '2024-05-15', 6500),
(10, '2024-06-01', 500),
(11, '2024-06-20', 1500);


select * from Orders;
with Months as(
	select month(OrderDate) as Months , sum(Amount) as TotalAmount from Orders
	group by month(OrderDate)

)
select m2.TotalAmount as PreviousMonth , m1.TotalAmount as CurrentMonth, (((m1.TotalAmount - m2.TotalAmount)/m2.TotalAmount)*100) as GrowthPercentage from Months m1
left join Months m2 on m1.Months - m2.Months = 1
where m2.Months is not null
order by GrowthPercentage desc;

with MonthlySales as(
select month(Orderdate) as month ,sum(amount) as TotalAmount from orders
group by month(orderDate)
)
select w1.TotalAmount as PreviousMonthsale ,w2.TotalAmount as cuurentmonthsale,(((w2.TotalAmount-w1.TotalAmount)/w1.TotalAmount)*100) as growthInPercentage ,rank() over(order by (((w2.TotalAmount-w1.TotalAmount)/w1.TotalAmount)*100) desc) from MonthlySales w1
left join  MonthlySales w2  on w2.month-w1.month=1
where w2.month is not null
