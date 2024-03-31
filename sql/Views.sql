CREATE VIEW AvailableRoomsPerArea AS
SELECT h.Area, COUNT(r.RoomNumber) AS AvailableRooms
FROM Hotel h
JOIN Room r ON h.Address = r.HotelAddress
WHERE r.Booked = FALSE
GROUP BY h.Area;

CREATE VIEW TotalCapacityPerHotel AS
SELECT h.Address, h.ChainName, SUM(r.RoomCapacity) AS TotalCapacity
FROM Hotel h
JOIN Room r ON h.Address = r.HotelAddress
GROUP BY h.Address, h.ChainName;
