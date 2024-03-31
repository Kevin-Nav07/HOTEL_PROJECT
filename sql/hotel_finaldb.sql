-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Apr 01, 2024 at 12:02 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hotel_finaldb`
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `availableroomsperarea`
-- (See below for the actual view)
--
CREATE TABLE `availableroomsperarea` (
`Area` varchar(255)
,`AvailableRooms` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `bookinghistory`
--

CREATE TABLE `bookinghistory` (
  `BookingID` int(11) NOT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `RoomNumber` varchar(255) DEFAULT NULL,
  `HotelAddress` varchar(255) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `Status` enum('booked','cancelled','completed') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookinghistory`
--

INSERT INTO `bookinghistory` (`BookingID`, `CustomerID`, `RoomNumber`, `HotelAddress`, `StartDate`, `EndDate`, `Status`) VALUES
(17, 8, 'A103', 'A1 Address', '2024-03-01', '2024-03-04', 'cancelled'),
(20, 11, 'A103', 'A1 Address', '2024-03-12', '2024-03-21', 'completed'),
(21, 11, 'A104', 'A1 Address', '2024-03-05', '2024-03-19', 'cancelled');

--
-- Triggers `bookinghistory`
--
DELIMITER $$
CREATE TRIGGER `set_room_available` AFTER UPDATE ON `bookinghistory` FOR EACH ROW BEGIN
    IF NEW.status = 'cancelled' THEN
        UPDATE Room
        SET booked = 0
        WHERE Room.RoomNumber = NEW.RoomNumber;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `set_room_booked` AFTER INSERT ON `bookinghistory` FOR EACH ROW BEGIN
    IF NEW.status = 'booked' THEN
        UPDATE Room
        SET booked = 1
        WHERE Room.RoomNumber = NEW.RoomNumber;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `booksat`
--

CREATE TABLE `booksat` (
  `HotelAddress` varchar(255) NOT NULL,
  `CustomerID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `booksat`
--

INSERT INTO `booksat` (`HotelAddress`, `CustomerID`) VALUES
('A1 Address', 11);

--
-- Triggers `booksat`
--
DELIMITER $$
CREATE TRIGGER `cancel_bookings_after_deleteOnBooksat` BEFORE DELETE ON `booksat` FOR EACH ROW BEGIN
    UPDATE bookinghistory
    SET status = 'cancelled'
    WHERE CustomerID = OLD.CustomerID AND HotelAddress = OLD.HotelAddress;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `ID` int(11) NOT NULL,
  `UserID` int(11) DEFAULT NULL,
  `Fullname` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Email` varchar(255) DEFAULT NULL,
  `SIN` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`ID`, `UserID`, `Fullname`, `Address`, `Email`, `SIN`) VALUES
(8, 10, 'nas', 'adad', 'nas@gmial.cpm', '21414'),
(11, 21, 'cust1', 'cust 1 add', 'cust1@gmail.com', '12414214 ');

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `before_customer_delete` BEFORE DELETE ON `customer` FOR EACH ROW BEGIN
    -- Delete from renting table
    DELETE FROM renting WHERE CustomerID = OLD.ID;
    
    -- Delete from responsiblefor table
    DELETE FROM responsiblefor WHERE CustomerID = OLD.ID;

    -- Delete from bookinghistory table
    DELETE FROM bookinghistory WHERE CustomerID = OLD.ID;

    -- Delete from booksat table
    DELETE FROM booksat WHERE CustomerID = OLD.ID;
    
    

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `ID` int(11) NOT NULL,
  `UserID` int(11) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Fullname` varchar(255) DEFAULT NULL,
  `HotelAddress` varchar(255) DEFAULT NULL,
  `Role` varchar(255) DEFAULT NULL,
  `Email` varchar(25) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `employee`
--
DELIMITER $$
CREATE TRIGGER `before_delete_on_employee` BEFORE DELETE ON `employee` FOR EACH ROW BEGIN
    DELETE FROM responsiblefor WHERE EmployeeID = OLD.ID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `hotel`
--

CREATE TABLE `hotel` (
  `ADDRESS` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `NumberOfRooms` int(11) DEFAULT NULL,
  `Rating` int(11) DEFAULT NULL CHECK (`Rating` between 1 and 5),
  `ChainName` varchar(255) DEFAULT NULL,
  `Area` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hotel`
--

INSERT INTO `hotel` (`ADDRESS`, `Email`, `NumberOfRooms`, `Rating`, `ChainName`, `Area`) VALUES
('A1 Address', 'hotelA1@chainA.com', 95, 4, 'Chain A', 'Downtown'),
('A2 Address', 'hotelA2@chainA.com', 85, 3, 'Chain A', 'Airport'),
('A3 Address', 'hotelA3@chainA.com', 105, 5, 'Chain A', 'Downtown'),
('A4 Address', 'hotelA4@chainA.com', 90, 3, 'Chain A', 'Suburb'),
('A5 Address', 'hotelA5@chainA.com', 80, 4, 'Chain A', 'Beachfront'),
('A6 Address', 'hotelA6@chainA.com', 110, 5, 'Chain A', 'Downtown'),
('A7 Address', 'hotelA7@chainA.com', 70, 3, 'Chain A', 'Airport'),
('A8 Address', 'hotelA8@chainA.com', 100, 4, 'Chain A', 'Suburb'),
('B1 Address', 'hotelB1@chainB.com', 95, 4, 'Chain B', 'Downtown'),
('B2 Address', 'hotelB2@chainB.com', 85, 3, 'Chain B', 'Airport'),
('B3 Address', 'hotelB3@chainB.com', 105, 5, 'Chain B', 'Downtown'),
('B4 Address', 'hotelB4@chainB.com', 90, 3, 'Chain B', 'Suburb'),
('B5 Address', 'hotelB5@chainB.com', 80, 4, 'Chain B', 'Beachfront'),
('B6 Address', 'hotelB6@chainB.com', 110, 5, 'Chain B', 'Downtown'),
('B7 Address', 'hotelB7@chainB.com', 70, 3, 'Chain B', 'Airport'),
('B8 Address', 'hotelB8@chainB.com', 100, 4, 'Chain B', 'Suburb'),
('C1 Address', 'hotelC1@chainC.com', 100, 4, 'Chain C', 'Downtown'),
('C2 Address', 'hotelC2@chainC.com', 90, 3, 'Chain C', 'Airport'),
('C3 Address', 'hotelC3@chainC.com', 120, 5, 'Chain C', 'Downtown'),
('C4 Address', 'hotelC4@chainC.com', 75, 3, 'Chain C', 'Suburb'),
('C5 Address', 'hotelC5@chainC.com', 95, 4, 'Chain C', 'Beachfront'),
('C6 Address', 'hotelC6@chainC.com', 115, 5, 'Chain C', 'Downtown'),
('C7 Address', 'hotelC7@chainC.com', 85, 3, 'Chain C', 'Airport'),
('C8 Address', 'hotelC8@chainC.com', 105, 4, 'Chain C', 'Suburb'),
('D1 Address', 'hotelD1@chainD.com', 110, 5, 'Chain D', 'Downtown'),
('D2 Address', 'hotelD2@chainD.com', 80, 3, 'Chain D', 'Airport'),
('D3 Address', 'hotelD3@chainD.com', 100, 4, 'Chain D', 'Downtown'),
('D4 Address', 'hotelD4@chainD.com', 90, 3, 'Chain D', 'Suburb'),
('D5 Address', 'hotelD5@chainD.com', 95, 4, 'Chain D', 'Beachfront'),
('D6 Address', 'hotelD6@chainD.com', 115, 5, 'Chain D', 'Downtown'),
('D7 Address', 'hotelD7@chainD.com', 85, 3, 'Chain D', 'Airport'),
('D8 Address', 'hotelD8@chainD.com', 105, 4, 'Chain D', 'Suburb'),
('E1 Address', 'hotelE1@chainE.com', 105, 4, 'Chain E', 'Downtown'),
('E2 Address', 'hotelE2@chainE.com', 100, 3, 'Chain E', 'Airport'),
('E3 Address', 'hotelE3@chainE.com', 115, 5, 'Chain E', 'Downtown'),
('E4 Address', 'hotelE4@chainE.com', 85, 3, 'Chain E', 'Suburb'),
('E5 Address', 'hotelE5@chainE.com', 90, 4, 'Chain E', 'Beachfront'),
('E6 Address', 'hotelE6@chainE.com', 120, 5, 'Chain E', 'Downtown'),
('E7 Address', 'hotelE7@chainE.com', 95, 3, 'Chain E', 'Airport'),
('E8 Address', 'hotelE8@chainE.com', 95, 3, 'Chain E', 'Airport');

--
-- Triggers `hotel`
--
DELIMITER $$
CREATE TRIGGER `hotel_deleted` BEFORE DELETE ON `hotel` FOR EACH ROW BEGIN
    DELETE FROM Room WHERE HotelAddress = OLD.ADDRESS;
    DElETE FROM Employee WHERE HotelAddress = OLD.ADDRESS;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `hotelchain`
--

CREATE TABLE `hotelchain` (
  `NAME` varchar(255) NOT NULL,
  `ADDRESS` varchar(255) NOT NULL,
  `PhoneNumber` varchar(20) DEFAULT NULL,
  `NumberOfHotels` int(11) DEFAULT NULL,
  `Email` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hotelchain`
--

INSERT INTO `hotelchain` (`NAME`, `ADDRESS`, `PhoneNumber`, `NumberOfHotels`, `Email`) VALUES
('Chain A', 'Address A', '123-456-7890', 8, 'emailA@chain.com'),
('Chain B', 'Address B', '234-567-8901', 8, 'emailB@chain.com'),
('Chain C', 'Address C', '345-678-9012', 8, 'emailC@chain.com'),
('Chain D', 'Address D', '456-789-0123', 8, 'emailD@chain.com'),
('Chain E', 'Address E', '567-890-1234', 8, 'emailE@chain.com');

--
-- Triggers `hotelchain`
--
DELIMITER $$
CREATE TRIGGER `delete_hotels_on_chain_delete` AFTER DELETE ON `hotelchain` FOR EACH ROW BEGIN
    DELETE FROM hotel WHERE ChainName = OLD.NAME;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `renting`
--

CREATE TABLE `renting` (
  `RentingID` int(11) NOT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `RoomNumber` varchar(255) DEFAULT NULL,
  `HotelAddress` varchar(255) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `Status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `renting`
--

INSERT INTO `renting` (`RentingID`, `CustomerID`, `RoomNumber`, `HotelAddress`, `StartDate`, `EndDate`, `Status`) VALUES
(2, 11, 'A103', 'A1 Address', '2024-03-12', '2024-03-21', 'Checked-out');

-- --------------------------------------------------------

--
-- Table structure for table `responsiblefor`
--

CREATE TABLE `responsiblefor` (
  `EmployeeID` int(11) NOT NULL,
  `CustomerID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `room`
--

CREATE TABLE `room` (
  `RoomNumber` varchar(255) NOT NULL,
  `HotelAddress` varchar(255) NOT NULL,
  `Extendability` tinyint(1) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `View` enum('sea','mountain','none') DEFAULT NULL,
  `Size` enum('single','family','quad','double','suite') DEFAULT NULL,
  `Amenities` varchar(255) DEFAULT NULL,
  `problems` tinyint(1) DEFAULT NULL,
  `Booked` tinyint(1) DEFAULT NULL,
  `RoomCapacity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `room`
--

INSERT INTO `room` (`RoomNumber`, `HotelAddress`, `Extendability`, `Price`, `View`, `Size`, `Amenities`, `problems`, `Booked`, `RoomCapacity`) VALUES
('A101', 'A1 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 1, 5),
('A102', 'A1 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 1, 4),
('A103', 'A1 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('A104', 'A1 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('A105', 'A1 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('A106', 'A1 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A107', 'A1 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A108', 'A1 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('A109', 'A1 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('A110', 'A1 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('A111', 'A1 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('A112', 'A1 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('A113', 'A1 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('A114', 'A1 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('A115', 'A1 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('A116', 'A1 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('A117', 'A1 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A118', 'A1 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('A119', 'A1 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A120', 'A1 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A201', 'A2 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('A202', 'A2 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('A203', 'A2 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('A204', 'A2 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('A205', 'A2 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('A206', 'A2 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A207', 'A2 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A208', 'A2 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('A209', 'A2 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('A210', 'A2 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('A211', 'A2 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('A212', 'A2 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('A213', 'A2 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('A214', 'A2 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('A215', 'A2 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('A216', 'A2 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('A217', 'A2 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A218', 'A2 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('A219', 'A2 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A220', 'A2 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A301', 'A3 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('A302', 'A3 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('A303', 'A3 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('A304', 'A3 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('A305', 'A3 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('A306', 'A3 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A307', 'A3 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A308', 'A3 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('A309', 'A3 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('A310', 'A3 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('A311', 'A3 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('A312', 'A3 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('A313', 'A3 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('A314', 'A3 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('A315', 'A3 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('A316', 'A3 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('A317', 'A3 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A318', 'A3 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('A319', 'A3 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A320', 'A3 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A401', 'A4 Address', 0, 170.00, 'sea', 'family', 'tv', 1, 0, 5),
('A402', 'A4 Address', 1, 200.00, 'mountain', 'quad', 'air condition', 0, 0, 4),
('A403', 'A4 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('A404', 'A4 Address', 1, 150.00, 'sea', 'suite', 'air condition', 1, 0, 3),
('A405', 'A4 Address', 0, 110.00, 'mountain', 'double', 'tv', 1, 0, 2),
('A406', 'A4 Address', 1, 120.00, 'sea', 'single', 'fridge', 0, 0, 1),
('A407', 'A4 Address', 0, 130.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('A408', 'A4 Address', 1, 180.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A409', 'A4 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('A410', 'A4 Address', 0, 90.00, 'mountain', 'suite', 'fridge', 1, 0, 3),
('A411', 'A4 Address', 1, 175.00, 'sea', 'double', 'tv', 0, 0, 2),
('A412', 'A4 Address', 1, 130.00, 'mountain', 'single', 'air condition', 0, 0, 1),
('A413', 'A4 Address', 0, 200.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A414', 'A4 Address', 1, 160.00, 'sea', 'single', 'fridge', 1, 0, 1),
('A415', 'A4 Address', 1, 190.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('A416', 'A4 Address', 0, 100.00, 'mountain', 'double', 'tv', 1, 0, 2),
('A417', 'A4 Address', 1, 150.00, 'sea', 'suite', 'fridge', 0, 0, 3),
('A418', 'A4 Address', 0, 120.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('A419', 'A4 Address', 1, 180.00, 'sea', 'double', 'tv', 0, 0, 2),
('A420', 'A4 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('A501', 'A5 Address', 0, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('A502', 'A5 Address', 1, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('A503', 'A5 Address', 0, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('A504', 'A5 Address', 1, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('A505', 'A5 Address', 0, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('A506', 'A5 Address', 0, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A507', 'A5 Address', 1, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A508', 'A5 Address', 0, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('A509', 'A5 Address', 1, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('A510', 'A5 Address', 0, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('A511', 'A5 Address', 1, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('A512', 'A5 Address', 0, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('A513', 'A5 Address', 0, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('A514', 'A5 Address', 1, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('A515', 'A5 Address', 0, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('A516', 'A5 Address', 1, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('A517', 'A5 Address', 0, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A518', 'A5 Address', 0, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('A519', 'A5 Address', 1, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A520', 'A5 Address', 0, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A601', 'A6 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('A602', 'A6 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 0, 0, 4),
('A603', 'A6 Address', 1, 200.00, 'sea', 'single', 'fridge', 1, 0, 1),
('A604', 'A6 Address', 0, 120.00, 'mountain', 'double', 'tv', 1, 0, 2),
('A605', 'A6 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('A606', 'A6 Address', 0, 190.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A607', 'A6 Address', 1, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A608', 'A6 Address', 0, 170.00, 'sea', 'double', 'tv', 1, 0, 2),
('A609', 'A6 Address', 1, 100.00, 'mountain', 'single', 'air condition', 0, 0, 1),
('A610', 'A6 Address', 0, 160.00, 'sea', 'double', 'fridge', 1, 0, 2),
('A611', 'A6 Address', 1, 130.00, 'mountain', 'suite', 'tv', 0, 0, 3),
('A612', 'A6 Address', 0, 140.00, 'sea', 'double', 'air condition', 1, 0, 2),
('A613', 'A6 Address', 0, 170.00, 'sea', 'suite', 'fridge', 0, 0, 3),
('A614', 'A6 Address', 1, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('A615', 'A6 Address', 0, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('A616', 'A6 Address', 1, 110.00, 'mountain', 'double', 'fridge', 1, 0, 2),
('A617', 'A6 Address', 0, 180.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A618', 'A6 Address', 0, 190.00, 'sea', 'double', 'air condition', 0, 0, 2),
('A619', 'A6 Address', 1, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A620', 'A6 Address', 0, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A701', 'A7 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('A702', 'A7 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 0, 0, 4),
('A703', 'A7 Address', 1, 200.00, 'sea', 'single', 'fridge', 1, 0, 1),
('A704', 'A7 Address', 0, 120.00, 'mountain', 'double', 'tv', 1, 0, 2),
('A705', 'A7 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('A706', 'A7 Address', 1, 190.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A707', 'A7 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A708', 'A7 Address', 1, 170.00, 'sea', 'double', 'tv', 1, 0, 2),
('A709', 'A7 Address', 0, 100.00, 'mountain', 'single', 'air condition', 0, 0, 1),
('A710', 'A7 Address', 1, 160.00, 'sea', 'double', 'fridge', 1, 0, 2),
('A711', 'A7 Address', 0, 130.00, 'mountain', 'suite', 'tv', 0, 0, 3),
('A712', 'A7 Address', 1, 140.00, 'sea', 'double', 'air condition', 1, 0, 2),
('A713', 'A7 Address', 1, 170.00, 'sea', 'suite', 'fridge', 0, 0, 3),
('A714', 'A7 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('A715', 'A7 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('A716', 'A7 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('A717', 'A7 Address', 1, 180.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A718', 'A7 Address', 1, 190.00, 'sea', 'double', 'air condition', 0, 0, 2),
('A719', 'A7 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A720', 'A7 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A801', 'A8 Address', 1, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A802', 'A8 Address', 0, 150.00, 'mountain', 'family', 'air condition', 0, 0, 5),
('A803', 'A8 Address', 1, 200.00, 'sea', 'quad', 'fridge', 1, 0, 4),
('A804', 'A8 Address', 0, 120.00, 'mountain', 'double', 'tv', 1, 0, 2),
('A805', 'A8 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('A806', 'A8 Address', 1, 190.00, 'sea', 'suite', 'tv', 0, 0, 3),
('A807', 'A8 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A808', 'A8 Address', 1, 170.00, 'sea', 'double', 'tv', 1, 0, 2),
('A809', 'A8 Address', 0, 100.00, 'mountain', 'single', 'air condition', 0, 0, 1),
('A810', 'A8 Address', 1, 160.00, 'sea', 'double', 'fridge', 1, 0, 2),
('A811', 'A8 Address', 0, 130.00, 'mountain', 'suite', 'tv', 0, 0, 3),
('A812', 'A8 Address', 1, 140.00, 'sea', 'double', 'air condition', 1, 0, 2),
('A813', 'A8 Address', 1, 170.00, 'sea', 'suite', 'fridge', 0, 0, 3),
('A814', 'A8 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('A815', 'A8 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('A816', 'A8 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('A817', 'A8 Address', 1, 180.00, 'sea', 'suite', 'tv', 1, 0, 3),
('A818', 'A8 Address', 1, 190.00, 'sea', 'double', 'air condition', 0, 0, 2),
('A819', 'A8 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('A820', 'A8 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B101', 'B1 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 1, 5),
('B102', 'B1 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('B103', 'B1 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('B104', 'B1 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('B105', 'B1 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('B106', 'B1 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B107', 'B1 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B108', 'B1 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('B109', 'B1 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B110', 'B1 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('B111', 'B1 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('B112', 'B1 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('B113', 'B1 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('B114', 'B1 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('B115', 'B1 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('B116', 'B1 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('B117', 'B1 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B118', 'B1 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('B119', 'B1 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B120', 'B1 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B201', 'B2 Address', 1, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B202', 'B2 Address', 0, 150.00, 'mountain', 'family', 'air condition', 1, 0, 5),
('B203', 'B2 Address', 1, 200.00, 'sea', 'quad', 'fridge', 0, 0, 4),
('B204', 'B2 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('B205', 'B2 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('B206', 'B2 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B207', 'B2 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B208', 'B2 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('B209', 'B2 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B210', 'B2 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('B211', 'B2 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('B212', 'B2 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('B213', 'B2 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('B214', 'B2 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('B215', 'B2 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('B216', 'B2 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('B217', 'B2 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B218', 'B2 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('B219', 'B2 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B220', 'B2 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B301', 'B3 Address', 1, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B302', 'B3 Address', 0, 150.00, 'mountain', 'family', 'air condition', 1, 0, 5),
('B303', 'B3 Address', 1, 200.00, 'sea', 'quad', 'fridge', 0, 0, 4),
('B304', 'B3 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('B305', 'B3 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('B306', 'B3 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B307', 'B3 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B308', 'B3 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('B309', 'B3 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B310', 'B3 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('B311', 'B3 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('B312', 'B3 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('B313', 'B3 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('B314', 'B3 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('B315', 'B3 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('B316', 'B3 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('B317', 'B3 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B318', 'B3 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('B319', 'B3 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B320', 'B3 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B401', 'B4 Address', 0, 170.00, 'sea', 'double', 'tv', 1, 0, 2),
('B402', 'B4 Address', 1, 200.00, 'mountain', 'family', 'air condition', 0, 0, 5),
('B403', 'B4 Address', 1, 160.00, 'sea', 'quad', 'fridge', 0, 0, 4),
('B404', 'B4 Address', 1, 150.00, 'sea', 'suite', 'air condition', 1, 0, 3),
('B405', 'B4 Address', 0, 110.00, 'mountain', 'double', 'tv', 1, 0, 2),
('B406', 'B4 Address', 1, 120.00, 'sea', 'single', 'fridge', 0, 0, 1),
('B407', 'B4 Address', 0, 130.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B408', 'B4 Address', 1, 180.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B409', 'B4 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('B410', 'B4 Address', 0, 90.00, 'mountain', 'suite', 'fridge', 1, 0, 3),
('B411', 'B4 Address', 1, 175.00, 'sea', 'double', 'tv', 0, 0, 2),
('B412', 'B4 Address', 1, 130.00, 'mountain', 'single', 'air condition', 0, 0, 1),
('B413', 'B4 Address', 0, 200.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B414', 'B4 Address', 1, 160.00, 'sea', 'single', 'fridge', 1, 0, 1),
('B415', 'B4 Address', 1, 190.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('B416', 'B4 Address', 0, 100.00, 'mountain', 'double', 'tv', 1, 0, 2),
('B417', 'B4 Address', 1, 150.00, 'sea', 'suite', 'fridge', 0, 0, 3),
('B418', 'B4 Address', 0, 120.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B419', 'B4 Address', 1, 180.00, 'sea', 'double', 'tv', 0, 0, 2),
('B420', 'B4 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('B501', 'B5 Address', 0, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B502', 'B5 Address', 1, 150.00, 'mountain', 'family', 'air condition', 1, 0, 5),
('B503', 'B5 Address', 0, 200.00, 'sea', 'quad', 'fridge', 0, 0, 4),
('B504', 'B5 Address', 1, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('B505', 'B5 Address', 0, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('B506', 'B5 Address', 0, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B507', 'B5 Address', 1, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B508', 'B5 Address', 0, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('B509', 'B5 Address', 1, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B510', 'B5 Address', 0, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('B511', 'B5 Address', 1, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('B512', 'B5 Address', 0, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('B513', 'B5 Address', 0, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('B514', 'B5 Address', 1, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('B515', 'B5 Address', 0, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('B516', 'B5 Address', 1, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('B517', 'B5 Address', 0, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B518', 'B5 Address', 0, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('B519', 'B5 Address', 1, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B520', 'B5 Address', 0, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B601', 'B6 Address', 1, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B602', 'B6 Address', 0, 150.00, 'mountain', 'family', 'air condition', 1, 0, 5),
('B603', 'B6 Address', 1, 200.00, 'sea', 'quad', 'fridge', 0, 0, 4),
('B604', 'B6 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('B605', 'B6 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('B606', 'B6 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B607', 'B6 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B608', 'B6 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('B609', 'B6 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B610', 'B6 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('B611', 'B6 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('B612', 'B6 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('B613', 'B6 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('B614', 'B6 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('B615', 'B6 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('B616', 'B6 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('B617', 'B6 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B618', 'B6 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('B619', 'B6 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B620', 'B6 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B701', 'B7 Address', 1, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B702', 'B7 Address', 0, 150.00, 'mountain', 'family', 'air condition', 1, 0, 5),
('B703', 'B7 Address', 1, 200.00, 'sea', 'quad', 'fridge', 0, 0, 4),
('B704', 'B7 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('B705', 'B7 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('B706', 'B7 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B707', 'B7 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B708', 'B7 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('B709', 'B7 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B710', 'B7 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('B711', 'B7 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('B712', 'B7 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('B713', 'B7 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('B714', 'B7 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('B715', 'B7 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('B716', 'B7 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('B717', 'B7 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B718', 'B7 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('B719', 'B7 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B720', 'B7 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B801', 'B8 Address', 1, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B802', 'B8 Address', 0, 150.00, 'mountain', 'family', 'air condition', 1, 0, 5),
('B803', 'B8 Address', 1, 200.00, 'sea', 'quad', 'fridge', 0, 0, 4),
('B804', 'B8 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('B805', 'B8 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('B806', 'B8 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('B807', 'B8 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B808', 'B8 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('B809', 'B8 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('B810', 'B8 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('B811', 'B8 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('B812', 'B8 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('B813', 'B8 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('B814', 'B8 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('B815', 'B8 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('B816', 'B8 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('B817', 'B8 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('B818', 'B8 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('B819', 'B8 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('B820', 'B8 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('C101', 'C1 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('C102', 'C1 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('C103', 'C1 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('C104', 'C1 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('C105', 'C1 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('C106', 'C1 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('C107', 'C1 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('C108', 'C1 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('C109', 'C1 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('C110', 'C1 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('C111', 'C1 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('C112', 'C1 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('C113', 'C1 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('C114', 'C1 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('C115', 'C1 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('C116', 'C1 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('C117', 'C1 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('C118', 'C1 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('C119', 'C1 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('C120', 'C1 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('C601', 'C6 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('C602', 'C6 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('C603', 'C6 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('C604', 'C6 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('C605', 'C6 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('C606', 'C6 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('C607', 'C6 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('C608', 'C6 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('C609', 'C6 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('C610', 'C6 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('C611', 'C6 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('C612', 'C6 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('C613', 'C6 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('C614', 'C6 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('C615', 'C6 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('C616', 'C6 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('C617', 'C6 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('C618', 'C6 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('C619', 'C6 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('C620', 'C6 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('C701', 'C7 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('C702', 'C7 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('C703', 'C7 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('C704', 'C7 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('C705', 'C7 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('C706', 'C7 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('C707', 'C7 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('C708', 'C7 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('C709', 'C7 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('C710', 'C7 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('C711', 'C7 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('C712', 'C7 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('C713', 'C7 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('C714', 'C7 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('C715', 'C7 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('C716', 'C7 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('C717', 'C7 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('C718', 'C7 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('C719', 'C7 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('C720', 'C7 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('C801', 'C8 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('C802', 'C8 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('C803', 'C8 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('C804', 'C8 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('C805', 'C8 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('C806', 'C8 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('C807', 'C8 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('C808', 'C8 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('C809', 'C8 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('C810', 'C8 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('C811', 'C8 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('C812', 'C8 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('C813', 'C8 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('C814', 'C8 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('C815', 'C8 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('C816', 'C8 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('C817', 'C8 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('C818', 'C8 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('C819', 'C8 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('C820', 'C8 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D101', 'D1 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('D102', 'D1 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('D103', 'D1 Address', 0, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('D104', 'D1 Address', 1, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('D105', 'D1 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('D106', 'D1 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D107', 'D1 Address', 1, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D108', 'D1 Address', 0, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('D109', 'D1 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('D110', 'D1 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('D111', 'D1 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('D112', 'D1 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('D113', 'D1 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('D114', 'D1 Address', 1, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('D115', 'D1 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('D116', 'D1 Address', 1, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('D117', 'D1 Address', 0, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('D118', 'D1 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('D119', 'D1 Address', 1, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D120', 'D1 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D201', 'D2 Address', 0, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('D202', 'D2 Address', 1, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('D203', 'D2 Address', 0, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('D204', 'D2 Address', 1, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('D205', 'D2 Address', 0, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('D206', 'D2 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D207', 'D2 Address', 1, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D208', 'D2 Address', 0, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('D209', 'D2 Address', 1, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('D210', 'D2 Address', 0, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('D211', 'D2 Address', 1, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('D212', 'D2 Address', 0, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('D213', 'D2 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('D214', 'D2 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('D215', 'D2 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('D216', 'D2 Address', 1, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('D217', 'D2 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('D218', 'D2 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('D219', 'D2 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D220', 'D2 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D301', 'D3 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('D302', 'D3 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('D303', 'D3 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('D304', 'D3 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('D305', 'D3 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('D306', 'D3 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D307', 'D3 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D308', 'D3 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('D309', 'D3 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('D310', 'D3 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('D311', 'D3 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('D312', 'D3 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('D313', 'D3 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('D314', 'D3 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('D315', 'D3 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('D316', 'D3 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('D317', 'D3 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('D318', 'D3 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('D319', 'D3 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D320', 'D3 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D401', 'D4 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('D402', 'D4 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('D403', 'D4 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('D404', 'D4 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('D405', 'D4 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('D406', 'D4 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D407', 'D4 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D408', 'D4 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('D409', 'D4 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('D410', 'D4 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('D411', 'D4 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('D412', 'D4 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('D413', 'D4 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('D414', 'D4 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('D415', 'D4 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('D416', 'D4 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('D417', 'D4 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('D418', 'D4 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('D419', 'D4 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D420', 'D4 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D501', 'D5 Address', 0, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('D502', 'D5 Address', 1, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('D503', 'D5 Address', 0, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('D504', 'D5 Address', 1, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('D505', 'D5 Address', 0, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('D506', 'D5 Address', 0, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D507', 'D5 Address', 1, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D508', 'D5 Address', 0, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('D509', 'D5 Address', 1, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('D510', 'D5 Address', 0, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('D511', 'D5 Address', 1, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('D512', 'D5 Address', 0, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('D513', 'D5 Address', 0, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('D514', 'D5 Address', 1, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('D515', 'D5 Address', 0, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('D516', 'D5 Address', 1, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('D517', 'D5 Address', 0, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('D518', 'D5 Address', 0, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('D519', 'D5 Address', 1, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D520', 'D5 Address', 0, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D601', 'D6 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('D602', 'D6 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('D603', 'D6 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('D604', 'D6 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('D605', 'D6 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('D606', 'D6 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D607', 'D6 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D608', 'D6 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('D609', 'D6 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('D610', 'D6 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('D611', 'D6 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('D612', 'D6 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('D613', 'D6 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('D614', 'D6 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('D615', 'D6 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('D616', 'D6 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('D617', 'D6 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('D618', 'D6 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('D619', 'D6 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D620', 'D6 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D701', 'D7 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('D702', 'D7 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('D703', 'D7 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('D704', 'D7 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('D705', 'D7 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('D706', 'D7 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D707', 'D7 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D708', 'D7 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('D709', 'D7 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('D710', 'D7 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('D711', 'D7 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('D712', 'D7 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('D713', 'D7 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('D714', 'D7 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('D715', 'D7 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('D716', 'D7 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('D717', 'D7 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('D718', 'D7 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('D719', 'D7 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D720', 'D7 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D801', 'D8 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('D802', 'D8 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('D803', 'D8 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('D804', 'D8 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('D805', 'D8 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('D806', 'D8 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('D807', 'D8 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D808', 'D8 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('D809', 'D8 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('D810', 'D8 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('D811', 'D8 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('D812', 'D8 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('D813', 'D8 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('D814', 'D8 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('D815', 'D8 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('D816', 'D8 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('D817', 'D8 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('D818', 'D8 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('D819', 'D8 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('D820', 'D8 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E101', 'E1 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('E102', 'E1 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('E103', 'E1 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('E104', 'E1 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('E105', 'E1 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('E106', 'E1 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E107', 'E1 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E108', 'E1 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('E109', 'E1 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E110', 'E1 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('E111', 'E1 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('E112', 'E1 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('E113', 'E1 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('E114', 'E1 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('E115', 'E1 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('E116', 'E1 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('E117', 'E1 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E118', 'E1 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('E119', 'E1 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E120', 'E1 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E201', 'E2 Address', 1, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E202', 'E2 Address', 0, 150.00, 'mountain', 'double', 'air condition', 1, 0, 2),
('E203', 'E2 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('E204', 'E2 Address', 0, 120.00, 'mountain', 'family', 'tv', 0, 0, 5),
('E205', 'E2 Address', 1, 180.00, 'sea', 'quad', 'air condition', 0, 0, 4),
('E206', 'E2 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E207', 'E2 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E208', 'E2 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('E209', 'E2 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E210', 'E2 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('E211', 'E2 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('E212', 'E2 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('E213', 'E2 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('E214', 'E2 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('E215', 'E2 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('E216', 'E2 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('E217', 'E2 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E218', 'E2 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('E219', 'E2 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E220', 'E2 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E301', 'E3 Address', 1, 175.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E302', 'E3 Address', 0, 150.00, 'mountain', 'double', 'air condition', 1, 0, 2),
('E303', 'E3 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('E304', 'E3 Address', 0, 120.00, 'mountain', 'family', 'tv', 0, 0, 5),
('E305', 'E3 Address', 1, 180.00, 'sea', 'quad', 'air condition', 0, 0, 4),
('E306', 'E3 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E307', 'E3 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E308', 'E3 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('E309', 'E3 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E310', 'E3 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('E311', 'E3 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('E312', 'E3 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('E313', 'E3 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('E314', 'E3 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('E315', 'E3 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('E316', 'E3 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('E317', 'E3 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E318', 'E3 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('E319', 'E3 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E320', 'E3 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E401', 'E4 Address', 0, 170.00, 'sea', 'family', 'tv', 1, 0, 5),
('E402', 'E4 Address', 1, 200.00, 'mountain', 'quad', 'air condition', 0, 0, 4),
('E403', 'E4 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('E404', 'E4 Address', 1, 150.00, 'sea', 'suite', 'air condition', 1, 0, 3),
('E405', 'E4 Address', 0, 110.00, 'mountain', 'double', 'tv', 1, 0, 2),
('E406', 'E4 Address', 1, 120.00, 'sea', 'single', 'fridge', 0, 0, 1),
('E407', 'E4 Address', 0, 130.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E408', 'E4 Address', 1, 180.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E409', 'E4 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('E410', 'E4 Address', 0, 90.00, 'mountain', 'suite', 'fridge', 1, 0, 3),
('E411', 'E4 Address', 1, 175.00, 'sea', 'double', 'tv', 0, 0, 2),
('E412', 'E4 Address', 1, 130.00, 'mountain', 'single', 'air condition', 0, 0, 1),
('E413', 'E4 Address', 0, 200.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E414', 'E4 Address', 1, 160.00, 'sea', 'single', 'fridge', 1, 0, 1),
('E415', 'E4 Address', 1, 190.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('E416', 'E4 Address', 0, 100.00, 'mountain', 'double', 'tv', 1, 0, 2),
('E417', 'E4 Address', 1, 150.00, 'sea', 'suite', 'fridge', 0, 0, 3),
('E418', 'E4 Address', 0, 120.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E419', 'E4 Address', 1, 180.00, 'sea', 'double', 'tv', 0, 0, 2),
('E420', 'E4 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('E501', 'E5 Address', 0, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('E502', 'E5 Address', 1, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('E503', 'E5 Address', 0, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('E504', 'E5 Address', 1, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('E505', 'E5 Address', 0, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('E506', 'E5 Address', 0, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E507', 'E5 Address', 1, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E508', 'E5 Address', 0, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('E509', 'E5 Address', 1, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E510', 'E5 Address', 0, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('E511', 'E5 Address', 1, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('E512', 'E5 Address', 0, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('E513', 'E5 Address', 0, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('E514', 'E5 Address', 1, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('E515', 'E5 Address', 0, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('E516', 'E5 Address', 1, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('E517', 'E5 Address', 0, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E518', 'E5 Address', 0, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('E519', 'E5 Address', 1, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E520', 'E5 Address', 0, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E601', 'E6 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('E602', 'E6 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('E603', 'E6 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('E604', 'E6 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('E605', 'E6 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('E606', 'E6 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E607', 'E6 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E608', 'E6 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('E609', 'E6 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E610', 'E6 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('E611', 'E6 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('E612', 'E6 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('E613', 'E6 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('E614', 'E6 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('E615', 'E6 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('E616', 'E6 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('E617', 'E6 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E618', 'E6 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('E619', 'E6 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E620', 'E6 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E701', 'E7 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('E702', 'E7 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4),
('E703', 'E7 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('E704', 'E7 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('E705', 'E7 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('E706', 'E7 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E707', 'E7 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E708', 'E7 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('E709', 'E7 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E710', 'E7 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('E711', 'E7 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('E712', 'E7 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('E713', 'E7 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('E714', 'E7 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('E715', 'E7 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('E716', 'E7 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('E717', 'E7 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E718', 'E7 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('E719', 'E7 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E720', 'E7 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E801', 'E8 Address', 1, 175.00, 'sea', 'family', 'tv', 0, 0, 5),
('E802', 'E8 Address', 0, 150.00, 'mountain', 'quad', 'air condition', 1, 0, 4);
INSERT INTO `room` (`RoomNumber`, `HotelAddress`, `Extendability`, `Price`, `View`, `Size`, `Amenities`, `problems`, `Booked`, `RoomCapacity`) VALUES
('E803', 'E8 Address', 1, 200.00, 'sea', 'single', 'fridge', 0, 0, 1),
('E804', 'E8 Address', 0, 120.00, 'mountain', 'double', 'tv', 0, 0, 2),
('E805', 'E8 Address', 1, 180.00, 'sea', 'suite', 'air condition', 0, 0, 3),
('E806', 'E8 Address', 1, 190.00, 'sea', 'suite', 'tv', 1, 0, 3),
('E807', 'E8 Address', 0, 80.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E808', 'E8 Address', 1, 170.00, 'sea', 'double', 'tv', 0, 0, 2),
('E809', 'E8 Address', 0, 100.00, 'mountain', 'single', 'air condition', 1, 0, 1),
('E810', 'E8 Address', 1, 160.00, 'sea', 'double', 'fridge', 0, 0, 2),
('E811', 'E8 Address', 0, 130.00, 'mountain', 'suite', 'tv', 1, 0, 3),
('E812', 'E8 Address', 1, 140.00, 'sea', 'double', 'air condition', 0, 0, 2),
('E813', 'E8 Address', 1, 170.00, 'sea', 'suite', 'fridge', 1, 0, 3),
('E814', 'E8 Address', 0, 90.00, 'mountain', 'single', 'tv', 1, 0, 1),
('E815', 'E8 Address', 1, 200.00, 'sea', 'single', 'air condition', 0, 0, 1),
('E816', 'E8 Address', 0, 110.00, 'mountain', 'double', 'fridge', 0, 0, 2),
('E817', 'E8 Address', 1, 180.00, 'sea', 'suite', 'tv', 0, 0, 3),
('E818', 'E8 Address', 1, 190.00, 'sea', 'double', 'air condition', 1, 0, 2),
('E819', 'E8 Address', 0, 70.00, 'mountain', 'single', 'fridge', 0, 0, 1),
('E820', 'E8 Address', 1, 150.00, 'sea', 'suite', 'tv', 1, 0, 3);

-- --------------------------------------------------------

--
-- Stand-in structure for view `totalcapacityperhotel`
-- (See below for the actual view)
--
CREATE TABLE `totalcapacityperhotel` (
`Address` varchar(255)
,`ChainName` varchar(255)
,`TotalCapacity` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `Username` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `role` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`UserID`, `Username`, `Password`, `Email`, `role`) VALUES
(10, 'NasifC', 'cook', 'nasif@gmail.com', 'Customer'),
(11, 'jdoe', 'password123', 'jdoe@example.com', 'Employee'),
(12, 'msmith', 'password456', 'msmith@example.com', 'Employee'),
(21, 'cust1', 'cook', 'cust1@gmail.com', 'Customer');

-- --------------------------------------------------------

--
-- Structure for view `availableroomsperarea`
--
DROP TABLE IF EXISTS `availableroomsperarea`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `availableroomsperarea`  AS SELECT `h`.`Area` AS `Area`, count(`r`.`RoomNumber`) AS `AvailableRooms` FROM (`hotel` `h` join `room` `r` on(`h`.`ADDRESS` = `r`.`HotelAddress`)) WHERE `r`.`Booked` = 0 GROUP BY `h`.`Area` ;

-- --------------------------------------------------------

--
-- Structure for view `totalcapacityperhotel`
--
DROP TABLE IF EXISTS `totalcapacityperhotel`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `totalcapacityperhotel`  AS SELECT `h`.`ADDRESS` AS `Address`, `h`.`ChainName` AS `ChainName`, sum(`r`.`RoomCapacity`) AS `TotalCapacity` FROM (`hotel` `h` join `room` `r` on(`h`.`ADDRESS` = `r`.`HotelAddress`)) GROUP BY `h`.`ADDRESS`, `h`.`ChainName` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookinghistory`
--
ALTER TABLE `bookinghistory`
  ADD PRIMARY KEY (`BookingID`),
  ADD KEY `CustomerID` (`CustomerID`),
  ADD KEY `RoomNumber` (`RoomNumber`,`HotelAddress`);

--
-- Indexes for table `booksat`
--
ALTER TABLE `booksat`
  ADD PRIMARY KEY (`HotelAddress`,`CustomerID`),
  ADD KEY `CustomerID` (`CustomerID`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `Email` (`Email`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `UserID` (`UserID`),
  ADD KEY `HotelAddress` (`HotelAddress`);

--
-- Indexes for table `hotel`
--
ALTER TABLE `hotel`
  ADD PRIMARY KEY (`ADDRESS`),
  ADD KEY `ChainName` (`ChainName`);

--
-- Indexes for table `hotelchain`
--
ALTER TABLE `hotelchain`
  ADD PRIMARY KEY (`NAME`);

--
-- Indexes for table `renting`
--
ALTER TABLE `renting`
  ADD PRIMARY KEY (`RentingID`),
  ADD KEY `CustomerID` (`CustomerID`);

--
-- Indexes for table `responsiblefor`
--
ALTER TABLE `responsiblefor`
  ADD PRIMARY KEY (`EmployeeID`,`CustomerID`),
  ADD KEY `CustomerID` (`CustomerID`);

--
-- Indexes for table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`RoomNumber`,`HotelAddress`),
  ADD KEY `fk_HotelAddress` (`HotelAddress`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Username` (`Username`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookinghistory`
--
ALTER TABLE `bookinghistory`
  MODIFY `BookingID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `renting`
--
ALTER TABLE `renting`
  MODIFY `RentingID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookinghistory`
--
ALTER TABLE `bookinghistory`
  ADD CONSTRAINT `bookinghistory_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`ID`),
  ADD CONSTRAINT `bookinghistory_ibfk_2` FOREIGN KEY (`RoomNumber`,`HotelAddress`) REFERENCES `room` (`RoomNumber`, `HotelAddress`);

--
-- Constraints for table `booksat`
--
ALTER TABLE `booksat`
  ADD CONSTRAINT `booksat_ibfk_1` FOREIGN KEY (`HotelAddress`) REFERENCES `hotel` (`ADDRESS`),
  ADD CONSTRAINT `booksat_ibfk_2` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`ID`);

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`);

--
-- Constraints for table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`),
  ADD CONSTRAINT `employee_ibfk_2` FOREIGN KEY (`HotelAddress`) REFERENCES `hotel` (`ADDRESS`);

--
-- Constraints for table `hotel`
--
ALTER TABLE `hotel`
  ADD CONSTRAINT `hotel_ibfk_1` FOREIGN KEY (`ChainName`) REFERENCES `hotelchain` (`NAME`);

--
-- Constraints for table `renting`
--
ALTER TABLE `renting`
  ADD CONSTRAINT `renting_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`ID`);

--
-- Constraints for table `responsiblefor`
--
ALTER TABLE `responsiblefor`
  ADD CONSTRAINT `responsiblefor_ibfk_1` FOREIGN KEY (`EmployeeID`) REFERENCES `employee` (`ID`),
  ADD CONSTRAINT `responsiblefor_ibfk_2` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`ID`);

--
-- Constraints for table `room`
--
ALTER TABLE `room`
  ADD CONSTRAINT `fk_HotelAddress` FOREIGN KEY (`HotelAddress`) REFERENCES `hotel` (`ADDRESS`),
  ADD CONSTRAINT `room_ibfk_1` FOREIGN KEY (`HotelAddress`) REFERENCES `hotel` (`ADDRESS`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
