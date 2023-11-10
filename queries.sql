--Запрос, который считает общее количество покупателей из таблицы customers
select count(customer_id) as customers_count 
from customers c ;

-- Первый отчет о десятке лучших продавцов.
select concat(e.first_name, ' ', e.last_name) as name, count(s.sales_id) as operations, round(sum(s.quantity * p.price)) as income
from employees e 
inner join sales s ON e.employee_id = s.sales_person_id 
inner join products p on p.product_id = s.product_id 
group by e.employee_id 
order by income desc 
limit 10;

-- Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
select concat(e.first_name, ' ', e.last_name) as name, round(avg(s.quantity * p.price)) as average_income
from sales s 
inner join products p on s.product_id = p.product_id 
inner join employees e on e.employee_id = s.sales_person_id 
group by e.employee_id  
having round(avg(s.quantity * p.price)) < (
	select round(avg(s.quantity * p.price))
	from sales s 
	inner join products p on s.product_id = p.product_id 
)
order by average_income asc;

-- Третий отчет содержит информацию о выручке по дням недели.
select wi.name, wi.weekday, sum(wi.income) as income
from (
	SELECT
	  CONCAT(e.first_name, ' ', e.last_name) AS name,
	  TO_CHAR(s.sale_date, 'Day') AS weekday,
	  ROUND(SUM(p.price * s.quantity)) AS income,
	  EXTRACT(DOW FROM s.sale_date) as day_num
	FROM
	  sales s
	JOIN
	  employees e ON s.sales_person_id = e.employee_id
	JOIN
	  products p ON s.product_id = p.product_id
	GROUP BY
	  name, weekday, e.first_name, e.last_name, s.sale_date
	ORDER BY
	  EXTRACT(DOW FROM s.sale_date), name
	) as wi
group by wi.day_num, name, wi.weekday
order by wi.day_num;
