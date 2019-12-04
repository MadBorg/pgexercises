-- https://pgexercises.com/questions/joins/


-- Simple join

-- Retrieve the start times of members' bookings
-- Q: How can you produce a list of the start times for bookings by members named 'David Farrell'?

SELECT b.starttime
FROM cd.bookings AS b
INNER JOIN cd.members AS m
	USING(memid)
WHERE m.firstname = 'David' AND m.surname = 'Farrell'


-- Work out the start times of bookings for tennis courts
-- Q: How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.

SELECT b.starttime, f.name
FROM cd.bookings AS b
INNER JOIN cd.facilities AS f
	USING(facid)
WHERE 
	f.name LIKE '%Tennis Court%' AND
	b.starttime >= '2012-09-21' AND
	b.starttime < '2012-09-22'
ORDER BY b.starttime;


-- Produce a list of all members who have recommended another member
-- Q: How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).

SELECT DISTINCT mem1.firstname, mem1.surname
FROM cd.members AS mem1
INNER JOIN cd.members AS mem2
	ON mem1.memid = mem2.recommendedby
ORDER BY mem1.surname, mem1.firstname;


-- Produce a list of all members, along with their recommender
-- Q: How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).

SELECT 
	mem.firstname AS memfname,
	mem.surname AS memsname,
	rec.firstname AS recfname,
	rec.surname AS recsname
FROM
	cd.members AS mem LEFT OUTER JOIN
	cd.members AS rec ON rec.memid = mem.recommendedby
ORDER BY mem.surname, mem.firstname;


-- Produce a list of all members who have used a tennis court
-- Q: How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member formatted as a single column. Ensure no duplicate data, and order by the member name.
SELECT DISTINCT
	mem.firstname ||' '|| mem.surname AS member,
	fac.name AS facility
FROM
	cd.members AS mem 
	
  INNER JOIN
	cd.bookings AS book 
  USING(memid)
		
  INNER JOIN
	cd.facilities as fac
  USING(facid)
  
WHERE fac.name LIKE '%Tennis Court%'
ORDER BY member;


-- Produce a list of costly bookings
-- Q: How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.

SELECT 
	mem.firstname ||' '|| mem.surname AS member,
	fac.name AS facility,
	CASE -- if mem.memid = 0 then its a guest.
		when mem.memid = 0 then
			book.slots*fac.guestcost
		else
			book.slots*fac.membercoast
	END AS cost
	
FROM 
	cd.facilities as fac 
	INNER JOIN cd.bookings as book
		USING(facid)
	LEFT JOIN cd.members AS mem
		ON book.memid = mem.memid

WHERE 
	book.starttime < '2012-09-15' AND
	book.starttime >= '2012-09-14' AND (
		(mem.memid = 0 and book.slots*fac.guestcost > 30) or
		(mem.memid != 0 and book.slots*fac.membercost > 30)
	)
ORDER BY cost DESC;

