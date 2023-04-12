/* 1. Найти заказчиков и обслуживающих их заказы сотрудников из города London, 
у которых доставка идёт компанией Speedy Express. Вывести компанию заказчика и ФИО сотрудника. */

SELECT c.company_name AS customer,
       CONCAT(e.first_name, ' ', e.last_name) AS employee
FROM orders as o 
	JOIN customers as c USING(customer_id)
	JOIN employees as e USING(employee_id)
	JOIN shippers as s ON o.ship_via = s.shipper_id
WHERE c.city = 'London'
	AND e.city = 'London'
	AND s.company_name = 'Speedy Express';

/* 2. Найти активные (см. поле discontinued) продукты из категории Beverages и Seafood, 
которых в продаже менее 20 единиц. Вывести наименование продуктов, кол-во единиц в продаже, имя контакта поставщика и его телефонный номер. */

SELECT product_name, 
	   units_in_stock, 
	   contact_name, 
	   phone
FROM products
	JOIN categories USING(category_id)
	JOIN suppliers USING(supplier_id)
WHERE category_name IN ('Beverages', 'Seafood')
	AND discontinued = 0
	AND units_in_stock < 20
ORDER BY units_in_stock;

/* 3. Найти заказчиков, не сделавших ни одного заказа. Вывести имя заказчика и order_id. */

SELECT distinct contact_name, order_id
FROM customers
	LEFT JOIN orders USING(customer_id)
WHERE order_id IS NULL
ORDER BY contact_name;

/* 4. Переписать предыдущий запрос, использовав симметричный вид джойна. */

SELECT contact_name, order_id
FROM orders
	RIGHT JOIN customers USING(customer_id)
WHERE order_id IS NULL
ORDER BY contact_name;

/* 5. Вывести продукты, количество которых в продаже меньше самого малого среднего количества продуктов в деталях заказов. 
Результирующая таблица должна иметь колонки product_name и units_in_stock. */

SELECT product_name, units_in_stock
FROM products
WHERE units_in_stock < ALL 
		(SELECT AVG(quantity)
		FROM order_details
		GROUP BY product_id)
ORDER BY units_in_stock DESC;

/* 6. Создать представление, которое выводит следующие колонки:
order_date, required_date, shipped_date, ship_postal_code, company_name, contact_name, phone, last_name, first_name, title из таблиц orders, customers и employees.
Сделать select к созданному представлению, выведя все записи, где order_date больше 1-го января 1997 года. */

CREATE VIEW orders_customers_employees AS
SELECT order_date,
	required_date, 
	shipped_date, 
	ship_postal_code,
	company_name,
	contact_name,
	phone,
	last_name,
	first_name,
	title
FROM orders
	JOIN customers USING (customer_id)
	JOIN employees USING (employee_id);

SELECT *
FROM orders_customers_employees
WHERE order_date > '1997-01-01';

/* 7. Создать представление "активных" (discontinued = 0) продуктов, содержащее все колонки. 
Представление должно быть защищено от вставки записей, в которых discontinued = 1.*/

CREATE OR REPLACE VIEW active_products
AS
SELECT product_id, product_name, supplier_id, category_id, quantity_per_unit, unit_price,
units_in_stock, units_on_order, reorder_level, discontinued
FROM products
WHERE discontinued <> 1
WITH LOCAL CHECK OPTION;


/* 8. Вывести наименование продукта, цену продукта и столбец со значениями
too expensive если цена >= 100
average если цена >=50 но < 100
low price если цена < 50 */


SELECT product_name, unit_price,
CASE WHEN unit_price >= 100 THEN 'too expensive'
	 WHEN unit_price >= 50 AND unit_price < 100 THEN 'average'
	 ELSE 'low price'
END AS price
FROM products
ORDER BY unit_price DESC;

