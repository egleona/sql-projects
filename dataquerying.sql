/***************************************************/
/* SQL - Vilnius coding school  */
/***************************************************/
/*Before you run these queries, make sure to create and import the Sakila DB*/

###  all customers with the name JESSICA. Print their first & last name.
select customer.first_name as Vardas, customer.last_name as Pavarde 
from customer
where customer.first_name  = "JESSICA"
order by first_name, last_name asc;
### actors whom name starts with the letter S or has the combination "ca" in their last name. Print the first name, last name, and ID of those actors
Select first_name, last_name, actor_id
from actor
where first_name like "S%" or last_name like "%ca%"
order by actor_id desc;
###display all countries and find how many times it was rented in each country. Sort by rental times in descending order
select country.country as Salis , count(payment.rental_id) as Kiek_nuomota from country
join city on country.country_id = city.country_id
join address on address.city_id = city.city_id
join customer on address.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
group by country.country
order by count(payment.rental_id) desc;
### find the total amount earned from rent in each country and then how much was earned per customer (ARPPU) on average. Sort by ARPPU in ascending order.
select country.country as Salis , count(payment.rental_id) as "Kiek nuomota", sum(payment.amount) as SUMA,
sum(payment.amount)/count(distinct customer.customer_id) as ARPPU  
from country
join city on country.country_id = city.country_id
join address on address.city_id = city.city_id
join customer on address.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
group by country.country
order by sum(payment.amount) asc;
### what was the highest and lowest rental price. Filter out zero [0] prices. (Find the lowest non-zero price)
select max(payment.amount) as MAX_kaina , min(payment.amount) as MIN_kaina 
from payment
where payment.amount <>0;
### display it by movie(title), but filter movies with category "Family", "Comedy", "Action"
select film.title, max(payment.amount) as MAX_kaina , min(payment.amount) as MIN_kaina from category
join film_category on film_category.category_id = category.category_id
join film on film.film_id = film_category.film_id
join inventory on inventory.film_id = film.film_id
join rental on rental.inventory_id = inventory.inventory_id
join payment on payment.rental_id = rental.rental_id
where payment.amount <>0 and category.name in ("Family", "Comedy", "Action")
group by film.film_id
order by film.film_id;
###print out  id and titles of the movies and find duplicates in inventory. Also output those movies that are not in the inventory. Sort by number of copies in ascending order.
select film.film_id, film.title, count(inventory.inventory_id) as KOPIJU_kiekis
from film
left join inventory on inventory.film_id = film.film_id
group by film.film_id
order by count(inventory.inventory_id) asc;
###print Movie category and movie in one column, with dash. Arrange the data according to the length of this compound
select concat(category.name,"-",film.title) as JUNGINYS, length(concat(category.name,"-",film.title)) as ILGIS
from category
join film_category on film_category.category_id = category.category_id
join film on film.film_id = film_category.film_id
order by length(concat(category.name,"-",film.title)) desc;
###Find cities with average amount is higher than the total average. 
select city.city_id, city.city, avg(payment.amount) as AVG
from city
join address on address.city_id = city.city_id
join customer on address.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
group by city.city_id
having avg(payment.amount)>(select avg(payment.amount) from payment)
order by city.city_id;
###check which categories are the most popula, show categories with the most movies first.
select category.name as KATEGORIJA, count(rental.rental_id) as "Nuomos kartai"
from category
join film_category on film_category.category_id = category.category_id
join film on film.film_id = film_category.film_id
join inventory on inventory.film_id = film.film_id
join rental on rental.inventory_id = inventory.inventory_id
join customer on customer.customer_id = rental.customer_id
join address on address.address_id = customer.address_id
join city on city.city_id = address.city_id
where city.city in
(select * from(select city.city
from city
join address on address.city_id = city.city_id
join customer on address.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
group by city.city
having avg(payment.amount)>(select avg(payment.amount) from payment)) as test)
group by category.name
order by count(rental.rental_id) desc;
###If the movie has been rented more than 20 times according to rental times, then assign it to the segment: "Most popular".
-- if the movie was rented less than 20 but more than 10 , assign average.
-- Assign to all others "Unpopular". Get the Movie ID, title, Rental times, and assigned segment.
select film.film_id, film.title, count(rental.rental_id) as "Nuomos kartai",
case
when count(rental.rental_id) >20 then "Populiariausi"
when count(rental.rental_id) >10 and count(rental.rental_id) <=20 then "Vidutinis"
else "Nepopuliarus"
end as Segmentas
from film
join inventory on inventory.film_id = film.film_id
join rental on rental.inventory_id = inventory.inventory_id
group by film.film_id
order by film.film_id;
### the total amount earned in each city. We are specifically interested in American cities.
select city.city as MIESTAS, sum(payment.amount) as SUMA from country
join city on country.country_id = city.country_id
join address on address.city_id = city.city_id
join customer on address.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
where country.country in ("United States")
group by city.city_id
order by SUMA;
###The replacement cost must be higher than the average replacement cost.
select city.city as MIESTAS, sum(payment.amount) as SUMA, replacement_cost
from country
join city on country.country_id = city.country_id
join address on address.city_id = city.city_id
join customer on address.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
join rental on rental.rental_id = payment.rental_id
join inventory on inventory.inventory_id = rental.inventory_id
join film on film.film_id = inventory.film_id
where country.country in ("United States")
and
film.replacement_cost > (select avg(film.replacement_cost) from film)
group by city.city_id
order by replacement_cost asc;
###Take only those users who had a first and last name combination longer than the average length of the first and last name combination.
-- (filter out all users who do not meet the criteria)
select city.city as MIESTAS, sum(payment.amount) as SUMA from country
join city on country.country_id = city.country_id
join address on address.city_id = city.city_id
join customer on address.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
join rental on rental.rental_id = payment.rental_id
join inventory on inventory.inventory_id = rental.inventory_id
join film on film.film_id = inventory.film_id
where country.country in ("United States")
and
film.replacement_cost > (select avg(film.replacement_cost) from film)
and
length(concat(customer.first_name,customer.last_name)) > (select avg(length(concat(customer.first_name,customer.last_name))) from customer)
group by city.city_id
order by length(concat(customer.first_name,customer.last_name));
###Take only those that were not executed in June and is of a later than the current month
select city.city as MIESTAS, sum(payment.amount) as SUMA from country
join city on country.country_id = city.country_id
join address on address.city_id = city.city_id
join customer on address.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
join rental on rental.rental_id = payment.rental_id
join inventory on inventory.inventory_id = rental.inventory_id
join film on film.film_id = inventory.film_id
where country.country in ("United States")
and
film.replacement_cost > (select avg(film.replacement_cost) from film)
and
length(concat(customer.first_name,customer.last_name)) > (select avg(length(concat(customer.first_name,customer.last_name))) from customer)
and month(rental.rental_date)> month(current_date())
and month(rental.rental_date)<>8
group by city.city_id
order by rental_date desc;