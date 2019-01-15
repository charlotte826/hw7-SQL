use sakila;
describe actor;

-- check datatypes
SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'actor'

-- 1a. Display the first and last names of all actors from the table actor.
Select first_name, last_name FROM actor;
 
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
-- Attempts: 
-- SELECT first_name + '  ' + last_name as "Actor Name" from sakila.actor;
-- SELECT COALESCE(first_name,'') + COALESCE(last_name,'') as "Actor Name" FROM sakila.actor;
-- select (first_name || last_name) as "Actor Name" from actor;
select concat(first_name,' ', last_name) as "Actor Name" from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the
--  first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
      from sakila.actor
      where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
-- Attemps (MYSQL does NOT support CONTAINS!?, only other databases like MS SQL.)
-- select actor_id, first_name, last_name
 --     from sakila.actor
 --     where last_name contains "GEN";
-- SELECT * FROM actor WHERE CONTAINS(last_name, 'gen');
-- SELECT * 
-- FROM actor 
-- WHERE LIKE (last_name, 'gen');
SELECT * FROM actor
WHERE last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name from actor
	WHERE last_name LIKE '%li%';

-- ORDER BY first_name DESC, last_name DESC;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT 
    country_id,country
FROM
    country
WHERE 
 (country) IN ('Afghanistan','Bangladesh','China');
 
 
-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, so create a 
-- column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and 
-- VARCHAR are significant).
	
-- Stackoverflow: user suggests using TEXT over BLOB:
-- Primary differnce: TEXT and BLOB is stored off the table with the table just 
-- having a pointer to the location of the actual storage.
-- VARCHAR is stored inline with the table.
-- if value = Text (store as text); if value = String attributes (store as VARCHAR)

ALTER TABLE actor
ADD COLUMN Description BLOB;

Select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.

ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
-- https://stackoverflow.com/questions/659978/mysql-retrieve-unique-values-and-counts-for-each

-- select first_name, count(*) from actor group by first_name;
select last_name, count(*) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

select last_name, count(*) from actor group by last_name 
having count(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor 
-- table as GROUCHO WILLIAMS. Write a query to fix the record
UPDATE actor SET first_name='HARPO' WHERE actor_id= 172;

-- using safe mode where i need to use a key to update a record
-- there are multiple actors with 1st name as groucho (3)
-- I'm looking for record with actor_id of 172
SELECT *
FROM actor
WHERE first_name like 'HARPO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name='GROUCHO' WHERE actor_id= 172;

SELECT *
FROM actor
WHERE first_name like 'GROUCHO';

-- 5a. You cannot locate the schema of the address table. ]
-- Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
-- SHOW CREATE TABLE address;
-- describe address;
-- explain address;

SELECT `table_schema` 
FROM `information_schema`.`tables` 
WHERE `table_name` = 'address';

-- 6a. Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address

SELECT address
FROM address
INNER JOIN staff ON address.address_id = staff.address_id;
-- SELECT first_name, last_name, address;

select * from address; 
select * from staff;

drop table staff_address_table;

create table staff_address_table as  
SELECT first_name, last_name, address 
FROM  staff 
INNER JOIN address  
ON staff.address_id = address.address_id;

select * from staff_address_table;
-- 

-- 6b. Use JOIN to display the total amount rung up by each staff member in
--  August of 2005. Use tables staff and payment.
use sakila;

-- SELECT first_name, last_name, SUM(amount)
-- FROM  payment 
-- WHERE DATE(payment_date) BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 00:00:00';
-- INNER JOIN staff  
-- ON staff.staff_id = payment.staff_id;

select * from staff;
select * from payment;

-- SELECT SUM(amount)
-- FROM    staff
-- WHERE payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59'
--         INNER JOIN payment
--             ON payment.staff_id = staff.staff_id
-- GROUP   BY staff.staff_id;

-- select staff.staff_id,staff.first_name,staff.last_name,sum(payment.amount)
-- WHERE payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59'
--    join payment on staff.staff_id=payment.staff_id
--    group by staff.staff_id;

SELECT 
    first_name,
    last_name,
	sum(amount) as total_amount
FROM       staff a
Left Join  payment d
    on d.staff_id = a.staff_id 
   where d.payment_date between '2005-08-01 00:00:00' AND '2005-08-31 23:59:59'
   GROUP   BY d.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
-- select last_name, count(*) from actor group by last_name;

select * from film_actor;
select * from film;

SELECT
	title,
    count(actor_id) as actor_count
FROM film fm
INNER JOIN film_actor fa
	on fa.film_id = fm.film_id
    group by fa.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select title, count(*) as count FROM film WHERE title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically 
-- by last name:

select * from payment;
select * from customer;

SELECT
SUM(amount) as total_paid,
first_name,
last_name
FROM customer c
INNER JOIN payment p
on c.customer_id = p.customer_id
group by c.customer_id
ORDER BY last_name ASC;

-- Use subqueries to display the titles of movies starting with the 
-- letters K and Q whose language is English.
select * from language;
select * from film;

use sakila;

SELECT *, name
FROM film AS f
INNER JOIN language AS l
ON f.language_id = l.language_id
WHERE (title LIKE 'K%' or title LIKE 'Q%') and l.language_id = 1;
-- GROUP BY title;
-- ORDER BY u_premium desc, id_uc desc

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor;
select * from film_actor;
select * from film;

select a.first_name, a.last_name, fm.title
from actor a, film fm, film_actor fa
where a.actor_id = fa.actor_id and fa.film_id = fm.film_id and fm.title LIKE "Alone Trip";

-- 7c you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select * from customer;
-- customer_id, store_id, first_name, last_name, email
select * from country;
-- country_id, country
select * from store;
-- store_id, address_id
select * from address;
-- address_id, city_id, postal_code
select * from city;
-- city_id, city, country_id

-- link storeID in customer to storeID in store, 
-- link addressID in store to addressID in address
-- cityID (address) to cityID (city)
-- countryID (city) to countryID (country)

-- select *
-- from city
-- INNER JOIN 
-- GROUP BY country;

SELECT b.first_name, b.last_name, b.email, c.country
FROM customer b
    INNER JOIN store s
        ON b.store_id = s.store_id
    INNER JOIN address a
        ON a.address_id = s.address_id
     INNER JOIN city ct
        ON a.city_id = ct.city_id
      INNER JOIN country c
        ON ct.country_id = c.country_id
        WHERE c.country LIKE "canada";
-- GROUP BY c.country;

-- 7d you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select * from film;
select * from film_category;
select * from category;

SELECT f.title, c.name
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON c.category_id = fc.category_id
where c.name LIKE "Family";

-- 7e. Display the most frequently rented movies in descending order.
select * from film;
-- film_id, title, 
select * from rental;
-- rental_id, rental_date, inventory_id, customer_id, staff_id
select * from payment;
-- payment_id, customer_id, staff_id, rental_id, amount, payment_date
select * from inventory;
-- inventory_id, film_id, store_id

-- from film join with inventory on film_id
-- from inventory join with rental on inventory_id
-- from rental join with payment on rental_id 

SELECT count(r.customer_id) as frequency, f.title
FROM film f
    INNER JOIN inventory i
        ON f.film_id = i.film_id
    INNER JOIN rental r
        ON i.inventory_id = r.inventory_id
     INNER JOIN payment p 
        ON r.rental_id = p.rental_id
        GROUP BY f.title HAVING frequency > 29
        ORDER by frequency DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store;
-- store_id, address_id, manager_staff_id
select * from payment;
-- payment_id, customer_id, staff_id, rental_id, amount, payment_date
select * from staff;
-- staff_id, store_id

SELECT concat('$', format(sum(payment.amount), 2)) as total_value, store.store_id
from store
inner join staff
on store.store_id = staff. store_id
inner join payment
on staff.staff_id = payment.staff_id
group by store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select * from customer;
-- customer_id, store_id, first_name, last_name, email
select * from country;
-- country_id, country
select * from store;
-- store_id, address_id
select * from address;
-- address_id, city_id, postal_code
select * from city;
-- city_id, city, country_id

-- store . address . city . country

SELECT s.store_id, ct.city, c.country
FROM store s
    INNER JOIN address a
        ON a.address_id = s.address_id
     INNER JOIN city ct
        ON a.city_id = ct.city_id
      INNER JOIN country c
        ON ct.country_id = c.country_id;

-- 7h List the top five genres in gross revenue in descending order. 
-- May need to use tables: category, film_category, inventory, payment, and rental.)
select * from category;
-- category_id, name (GENRE****)
select * from film_category;
-- film_id, category_id
select * from inventory;
-- inventory_id, film_id, store_id
select * from rental;
-- rental_id, rental_date, inventory_id, customer_id, staff_id
select * from payment;
-- payment_id, customer_id, staff_id, rental_id, amount, payment_date

-- find sum of amount (in payment) by category.name (in category)
-- link category to payment
-- charlotte_id, charlotte_zimmerman_id
-- category_id -- film_id -- inventory_id -- rental_id

SELECT c.name, concat('$', format(sum(amount), 2)) as gross_revenue
FROM category c
INNER JOIN film_category fc
ON c.category_id = fc.category_id
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY gross_revenue DESC LIMIT 5;

-- 8a easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
-- CREATE VIEW test.v AS SELECT * FROM t;
-- https://dev.mysql.com/doc/refman/5.5/en/create-view.html

Create View `Top 5 Gross Revenues` as 
SELECT c.name, concat('$', format(sum(amount), 2)) as gross_revenue
FROM category c
INNER JOIN film_category fc
ON c.category_id = fc.category_id
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY gross_revenue DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM  `Top 5 Gross Revenues`;

-- 8c. You find that you no longer need the view top_five_genres. 
-- Write a query to delete it.
-- http://download.nust.na/pub6/mysql/doc/refman/5.1/en/drop-view.html

DROP VIEW `Top 5 Gross Revenues`;


