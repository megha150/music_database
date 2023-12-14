-- Q1: Write a query to return email, first name, last name and genre of all rock music listeners.
-- write your list ordered alphabetically by email starting with A.

SELECT DISTINCT email, first_name, last_name 
FROM customer
JOIN invoice 
ON customer.customer_id = invoice.customer_id
JOIN invoice_line
ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
    SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name = 'Rock'
)
ORDER BY email;




--Q2: Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the artist name and total track count of the top 10 rock bands.

SELECT artist.name as artist_name, COUNT(*) AS track_count
FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.name
ORDER BY track_count DESC
LIMIT 10;




--Q3: Return all the track names that have a song length longer than the average song length.
--Return the names and milliseconds for each track. 
--Order by the song length with the longest song listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS average
	FROM track)
ORDER BY milliseconds DESC;




--Q4: Write how much amount spent by each customer on artists? 
--Write a query to return customer name and total spent.

SELECT c.customer_id, c.first_name, c.last_name,  SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN artist ON artist.artist_id = alb.artist_id

GROUP BY 1,2,3
ORDER BY amount_spent DESC;


  
--Q5 We want to find out the most popular music genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top genre.
--For countries where the maximum number of purchases is shared return all genres.

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1
