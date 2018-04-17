/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT *
	FROM Facilities
WHERE membercost = 0.0


/* Q2: How many facilities do not charge a fee to members? */

SELECT 0.0 AS member_cost,
		COUNT(CASE WHEN membercost = 0.0 THEN 1 ELSE NULL END)
	FROM Facilities


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid AS facility_id,
		name AS facility_name,
		membercost AS membership_cost,
		monthlymaintenance AS monthly_maintenance_cost
	FROM Facilities
WHERE monthlymaintenance * 0.2 > membercost


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
	FROM Facilities
WHERE facid IN ('1', '5')


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name AS facility_name,
		monthlymaintenance AS monthly_maintenance_cost,
		CASE WHEN monthlymaintenance > 100 THEN 'expensive'
				ELSE 'cheap' END AS facility_cost
	FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname AS 'first_name',
		surname AS 'last_name',
		joindate AS 'join_date'
	FROM Members
WHERE joindate = (SELECT MAX(joindate)
                  	FROM Members)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT Facilities.name as court,
		CONCAT(Members.firstname, ' ', Members.surname) AS member_name
	FROM Bookings
	JOIN Facilities
		ON Bookings.facid = Facilities.facid
	JOIN Members
		ON Bookings.memid = Members.memid
WHERE Bookings.memid != 0 AND Facilities.name LIKE 'TENNIS COURT%'
GROUP BY 1,2
ORDER BY 2


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name AS facility_name,
		'GUEST' AS member_name,
		Facilities.guestcost * Bookings.slots AS booking_cost
	FROM Bookings
JOIN Facilities
	ON Bookings.facid = Facilities.facid
Join Members
	ON Bookings.memid = Members.memid
WHERE LEFT(starttime, 10) = '2012-09-14' 
		AND Members.memid = 0


UNION 


SELECT Facilities.name AS facility_name,
		CONCAT(Members.firstname, ' ', Members.surname) AS member_name,
		SUM(Facilities.membercost * Bookings.slots) AS booking_cost
	FROM Bookings
JOIN Facilities
	ON Bookings.facid = Facilities.facid
Join Members
	ON Bookings.memid = Members.memid
WHERE LEFT(starttime, 10) = '2012-09-14' 
		AND Members.memid != 0
GROUP BY Members.memid
HAVING SUM(Facilities.membercost * Bookings.slots) > 30
ORDER BY booking_cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT guest.facname AS facility_name,
		'Guest' AS member_name,
		guest.booking_cost
	FROM Members
		

JOIN (

	SELECT Bookings.memid AS memid,
		Facilities.name AS facname,
		slots * guestcost AS booking_cost
	FROM Bookings
	JOIN Facilities
	ON Bookings.facid = Facilities.facid
	WHERE LEFT(starttime, 10) = '2012-09-14'
		AND memid = 0
    
    ) guest
ON Members.memid = guest.memid
WHERE guest.booking_cost > 30


UNION 


SELECT sub.facname AS facility_name,
		CONCAT(Members.firstname, ' ', Members.surname) AS member_name,
		sub.booking_cost
	FROM Members


JOIN (

	SELECT Bookings.memid AS memid,
		Facilities.name AS facname,
		SUM(slots * membercost) AS booking_cost
		
		FROM Bookings
		JOIN Facilities
		ON Bookings.facid = Facilities.facid
	WHERE LEFT(starttime, 10) = '2012-09-14'
    		AND memid != 0
GROUP BY 1
    ) sub

ON Members.memid = sub.memid
WHERE sub.booking_cost > 30
ORDER BY 3 DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT Facilities.name AS facility,

		SUM(CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
            	ELSE Facilities.membercost * Bookings.slots END) AS revenue
	FROM Facilities
JOIN Bookings
ON Facilities.facid = Bookings.facid
GROUP BY 1
HAVING revenue < 1000
ORDER BY revenue DESC