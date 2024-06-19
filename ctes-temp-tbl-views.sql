-- Step 1. The view should include the customer's ID, name, email address, and total number of rentals
CREATE OR REPLACE VIEW sakila.rental_info AS
SELECT customer.customer_id, customer.first_name, customer.last_name, customer.email, count(*) rental_count
FROM sakila.customer AS customer
LEFT JOIN sakila.rental AS rental ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, customer.email;

-- Step 2
CREATE TEMPORARY TABLE sakila.payment_info AS
SELECT sakila.rental_info.*, paymnt_tbl.total_paid
FROM sakila.rental_info rental_info
LEFT JOIN (
	SELECT payment.customer_id, SUM(payment.amount) total_paid
    FROM sakila.payment AS payment
    GROUP BY payment.customer_id
	) AS paymnt_tbl
ON paymnt_tbl.customer_id = rental_info.customer_id;


-- Step 3
WITH CTE AS (
	SELECT CONCAT(rental_info.first_name,' ', rental_info.last_name) name,
			rental_info.email, rental_info.rental_count,
            payment_info.total_paid
    FROM sakila.rental_info AS rental_info
    JOIN sakila.payment_info AS payment_info ON rental_info.customer_id = payment_info.customer_id
			)
SELECT CTE.*,  total_paid/rental_count average_payment_per_rental FROM CTE;