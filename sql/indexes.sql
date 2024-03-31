--(shows us that using index makes it easier to search and less time consuming)


CREATE INDEX idx_HotelAddress_RoomNumber --composit index 
ON room (HotelAddress, RoomNumber);

--we try this query before adding index 
SET SESSION query_cache_type = OFF;             -- Disable query cache to get accurate time measurements
SELECT RoomNumber 
FROM room
WHERE HotelAddress = 'A1 Address';                  --Query took 0.0008 seconds. without index 

--time it took after adding index to table is 0.0006 seconds

 ---------------------------------------------------------------------------------


CREATE INDEX price_idx
ON Room (price);

--we try this query before adding index 
SET SESSION query_cache_type = OFF;                -- Disable query cache to get accurate time measurements
SELECT RoomNumber,HotelAddress FROM room WHERE Price = '70.00';     --Query took 0.0014 seconds without index

--time it took after adding index to table 0.0004 seconds. 


 ---------------------------------------------------------------------------------
CREATE INDEX idx_Rating
ON hotel (Rating);


--we try this query before adding index 
SET SESSION query_cache_type = OFF;         -- Disable query cache to get accurate time measurements
SELECT ADDRESS
FROM hotel
WHERE Rating = 5 OR Rating = 4;                           -- Query took 0.0003 seconds without index