-- Table structure for table `bookinghistory`
CREATE TABLE `bookinghistory` (
  `BookingID` int(11) NOT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `RoomNumber` varchar(255) DEFAULT NULL,
  `HotelAddress` varchar(255) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `Status` enum('booked','cancelled','completed') DEFAULT NULL,
  PRIMARY KEY (`BookingID`),
  CONSTRAINT `bookinghistory_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`ID`),
  CONSTRAINT `bookinghistory_ibfk_2` FOREIGN KEY (`RoomNumber`, `HotelAddress`) REFERENCES `room` (`RoomNumber`, `HotelAddress`)
);

-- Table structure for table `booksat`
CREATE TABLE `booksat` (
  `HotelAddress` varchar(255) NOT NULL,
  `CustomerID` int(11) NOT NULL,
  PRIMARY KEY (`HotelAddress`, `CustomerID`),
  CONSTRAINT `booksat_ibfk_1` FOREIGN KEY (`HotelAddress`) REFERENCES `hotel` (`ADDRESS`),
  CONSTRAINT `booksat_ibfk_2` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`ID`)
);

-- Table structure for table `customer`
CREATE TABLE `customer` (
  `ID` int(11) NOT NULL,
  `UserID` int(11) DEFAULT NULL,
  `Fullname` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Email` varchar(255) DEFAULT NULL,
  `SIN` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`)
);

-- Table structure for table `employee`
CREATE TABLE `employee` (
  `ID` int(11) NOT NULL,
  `UserID` int(11) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Fullname` varchar(255) DEFAULT NULL,
  `HotelAddress` varchar(255) DEFAULT NULL,
  `Role` varchar(255) DEFAULT NULL,
  `Email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`),
  CONSTRAINT `employee_ibfk_2` FOREIGN KEY (`HotelAddress`) REFERENCES `hotel` (`ADDRESS`)
);

-- Table structure for table `hotel`
CREATE TABLE `hotel` (
  `ADDRESS` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `NumberOfRooms` int(11) DEFAULT NULL,
  `Rating` int(11) DEFAULT NULL CHECK (`Rating` between 1 and 5),
  `ChainName` varchar(255) DEFAULT NULL,
  `Area` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ADDRESS`),
  CONSTRAINT `hotel_ibfk_1` FOREIGN KEY (`ChainName`) REFERENCES `hotelchain` (`NAME`)
);

-- Table structure for table `hotelchain`
CREATE TABLE `hotelchain` (
  `NAME` varchar(255) NOT NULL,
  `ADDRESS` varchar(255) NOT NULL,
  `PhoneNumber` varchar(20) DEFAULT NULL,
  `NumberOfHotels` int(11) DEFAULT NULL,
  `Email` varchar(255) NOT NULL,
  PRIMARY KEY (`NAME`)
);

-- Table structure for table `renting`
CREATE TABLE `renting` (
  `RentingID` int(11) NOT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `RoomNumber` varchar(255) DEFAULT NULL,
  `HotelAddress` varchar(255) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `Status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`RentingID`),
  CONSTRAINT `renting_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`ID`)
);

-- Table structure for table `responsiblefor`
CREATE TABLE `responsiblefor` (
  `EmployeeID` int(11) NOT NULL,
  `CustomerID` int(11) NOT NULL,
  PRIMARY KEY (`EmployeeID`, `CustomerID`),
  CONSTRAINT `responsiblefor_ibfk_1` FOREIGN KEY (`EmployeeID`) REFERENCES `employee` (`ID`),
  CONSTRAINT `responsiblefor_ibfk_2` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`ID`)
);

-- Table structure for table `room`
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
  `RoomCapacity` int(11) DEFAULT NULL,
  PRIMARY KEY (`RoomNumber`, `HotelAddress`),
  CONSTRAINT `fk_HotelAddress` FOREIGN KEY (`HotelAddress`) REFERENCES `hotel` (`ADDRESS`)
);

-- Table structure for table `users`
CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `Username` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `role` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`UserID`)
);
