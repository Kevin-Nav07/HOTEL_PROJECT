
--Delete all hotels associated with hotel chain if hotel chain was deleted
DELIMITER //

CREATE TRIGGER delete_hotels_on_chain_delete
AFTER DELETE ON hotelchain
FOR EACH ROW
BEGIN
    DELETE FROM hotel WHERE ChainName = OLD.NAME;
END;
//

DELIMITER ;
--FOREIGN KEY (`ChainName`) in hotel  REFERENCES `hotelchain` (`NAME`);

----------------------------------------------------------------------------------------

--Delete all rooms associated and employees that work at that hotel  if that hotel was deleted 
DELIMITER //
CREATE TRIGGER hotel_deleted
BEFORE DELETE ON hotel
FOR EACH ROW
BEGIN
    DELETE FROM Room WHERE HotelAddress = OLD.ADDRESS;
    DElETE FROM Employee WHERE HotelAddress = OLD.ADDRESS;
END
//
DELIMITER ;

--FOREIGN KEY (`HotelAddress`) in room  REFERENCES `hotel` (`ADDRESS`);
----------------------------------------------------------------------------------------

--After a room is booked it, the 'booked' status of a room is now 1 to indiacte that it is booked and not available 
DELIMITER //

CREATE TRIGGER set_room_booked_flag
AFTER INSERT ON BookingHistory
FOR EACH ROW
BEGIN
    UPDATE Room
    SET booked = 1
    WHERE Room.RoomNumber = NEW.RoomNumber;
END;
//

DELIMITER ;

----------------------------------------------------------------------------------------

DELIMITER //

CREATE TRIGGER set_room_available
AFTER INSERT ON BookingHistory
FOR EACH ROW
BEGIN
    UPDATE Room
    IF NEW.status = 'cancelled' THEN
        UPDATE Room
        SET booked = 0
        WHERE Room.RoomNumber = NEW.RoomNumber;
    END IF;
END
//

DELIMITER ;

----------------------------------------------------------------------------------------


--when customer does not book at hotel  anymore then all bookings that customer did in bookinghistory table are set to cancelled in status 
DELIMITER //
CREATE TRIGGER cancel_bookings_after_deleteOnBooksat
BEFORE DELETE ON booksat
FOR EACH ROW
BEGIN
    UPDATE bookinghistory
    SET status = 'cancelled'
    WHERE CustomerID = OLD.CustomerID AND HotelAddress = OLD.HotelAddress;
END;
 //
DELIMITER ;






----------------------------------------------------------------------------------------

DELIMITER //
CREATE TRIGGER after_delete_on_customer 
AFTER DELETE ON customer
FOR EACH ROW
BEGIN
    -- Delete from user table
    DELETE FROM users WHERE UserID = OLD.UserID;

    -- Delete from responsible_for table
    DELETE FROM responsiblefor WHERE CustomerID = OLD.UserID;

    -- Delete from bookinghistory table
    DELETE FROM bookinghistory WHERE CustomerID = OLD.UserID;

    -- Delete from booksat table
    DELETE FROM booksat WHERE CustomerID = OLD.UserID;
END;
//
DELIMITER ;


----------------------------------------------------------------------------------------

DELIMITER //
CREATE TRIGGER after_delete_on_employee
AFTER DELETE ON employee
FOR EACH ROW
BEGIN
    -- Delete from users table
    DELETE FROM users WHERE UserID = OLD.UserID;

    -- Delete from responsiblefor table
    DELETE FROM responsiblefor WHERE EmployeeID = OLD.UserID;
END;
//
DELIMITER ;