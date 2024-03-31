--Check if a hotel for example hotel A1 has 5 rooms with different sizes and print them 
SELECT COUNT(DISTINCT Size) AS NumberOfDistinctSizes,
       GROUP_CONCAT(DISTINCT Size ORDER BY Size) AS distinctSizes
FROM Room
WHERE HotelAddress = 'A1 Address'; --result gives 5, single,family,quad,double,suite

-- How many hotels are in all the hotel chains?
	SELECT hotelchain.NAME AS ChainName, COUNT(*) AS NumberOfHotels
		FROM hotelchain 
		JOIN hotel ON hotelchain.NAME = hotel.ChainName
		GROUP BY hotelchain.NAME;

--How many rooms did a customer with id = 10 book ?  --aggregation query 
	SELECT CustomerID, COUNT(*) AS NumberOfRoomsBooked
		FROM bookinghistory
		WHERE CustomerID = '10'
		GROUP BY CustomerID;
	
-- How many hotels did a customer book at?
	SELECT CustomerID, COUNT(*) AS NumberOfRoomsBooked
		FROM booksat
		GROUP BY CustomerID;
	
	
--List emails of hotels with  distinct addresses in hotel table
	SELECT email AS email, ADDRESS FROM hotel GROUP BY ADDRESS;

--number of hotels in Chain A that are downtown 
	SELECT COUNT(*) AS NumberOfHotels
		FROM hotel
		JOIN hotelchain ON hotel.ChainName = hotelchain.NAME
		WHERE hotel.Area = 'Downtown' AND hotel.ChainName = 'Chain A';