USE [master];
GO

-- Drop the database if it exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Project')
BEGIN
    ALTER DATABASE [Project] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Project];
END;
GO

-- Create a new database
CREATE DATABASE [Project];
GO

USE [Project];
GO

-- ===================== HOTEL TABLE =====================
CREATE TABLE Hotel (
    Hotel_id INT PRIMARY KEY,
    Hotel_Name VARCHAR(50) NOT NULL,
    Street VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL CHECK (Country = 'USA'),
    Zip_code INT NOT NULL,
    Phone_Number VARCHAR(50) NOT NULL
);
GO

-- ===================== GUESTS TABLE =====================
CREATE TABLE Guests (
    Guest_id INT PRIMARY KEY,
    First_name VARCHAR(20) NOT NULL,
    Last_name VARCHAR(20) NOT NULL,
    Age INT CHECK (Age >= 18) NOT NULL,
    Phone_Number VARCHAR(20) NOT NULL,
    Email_id VARCHAR(70) UNIQUE NOT NULL,
    Street VARCHAR(50) NOT NULL,
    City VARCHAR(20) NOT NULL,
    State VARCHAR(20) NOT NULL,
    Country VARCHAR(10) NOT NULL,
    Zip_Code INT NOT NULL,
    Credit_Card VARCHAR(20) NOT NULL,
    ID_Proof VARCHAR(50) NOT NULL
);
GO

-- ===================== ROOM TYPE TABLE =====================
CREATE TABLE Room_Type (
    Room_Type_id INT PRIMARY KEY,
    Type_name VARCHAR(20) NOT NULL,
    On_Season CHAR(1) NOT NULL CHECK (On_Season IN ('Y', 'N')),
    Cost INT NOT NULL CHECK (Cost > 0)
);
GO

-- ===================== ROOMS TABLE =====================
CREATE TABLE Rooms (
    Room_id INT PRIMARY KEY,
    Room_Number INT NOT NULL UNIQUE,
    Hotel_id INT NOT NULL,
    Room_Type_id INT NOT NULL,
    Is_Available CHAR(1) NOT NULL CHECK (Is_Available IN ('Y', 'N')),
    CONSTRAINT FK_Rooms_Hotel FOREIGN KEY (Hotel_id) REFERENCES Hotel (Hotel_id),
    CONSTRAINT FK_Rooms_RoomType FOREIGN KEY (Room_Type_id) REFERENCES Room_Type (Room_Type_id)
);
GO

-- ===================== HOTEL SERVICES TABLE =====================
CREATE TABLE Hotel_Services (
    Hotel_Services_id INT PRIMARY KEY,
    Service_Name VARCHAR(50) NOT NULL UNIQUE,
    Service_Cost INT NOT NULL CHECK (Service_Cost >= 0)
);
GO

-- ===================== RESERVATION TABLE =====================
CREATE TABLE Reservation (
    Reservation_id INT PRIMARY KEY,
    Reservation_Date DATE NOT NULL DEFAULT GETDATE(),
    Check_in_Date DATE NOT NULL,
    Check_out_Date DATE NOT NULL CHECK (Check_out_Date > Check_in_Date),
    No_of_Rooms INT NOT NULL CHECK (No_of_Rooms > 0),
    Hotel_id INT NOT NULL,
    Guest_id INT NOT NULL,
    Has_Reservation CHAR(1) NOT NULL CHECK (Has_Reservation IN ('Y', 'N')),
    Is_Canceled CHAR(1) DEFAULT 'N' CHECK (Is_Canceled IN ('Y', 'N')),
    CONSTRAINT FK_Reservation_Hotel FOREIGN KEY (Hotel_id) REFERENCES Hotel (Hotel_id),
    CONSTRAINT FK_Reservation_Guest FOREIGN KEY (Guest_id) REFERENCES Guests (Guest_id)
);
GO

-- Computed Column: Number of Days Stayed
SELECT 
    Reservation_id, 
    Reservation_Date, 
    No_of_Rooms, 
    Has_Reservation, 
    DATEDIFF(DAY, Check_in_Date, Check_out_Date) AS No_of_days_stayed
FROM Reservation;
GO

-- ===================== CANCELATION TABLE =====================
CREATE TABLE Cancelation (
    Cancelation_id INT PRIMARY KEY,
    Reservation_id INT NOT NULL,
    Canceled_Date DATE NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Cancelation_Reservation FOREIGN KEY (Reservation_id) REFERENCES Reservation (Reservation_id)
);
GO

-- ===================== ROOMS BOOKED TABLE =====================
CREATE TABLE Rooms_Booked (
    Rooms_Booked_id INT PRIMARY KEY,
    Reservation_id INT NOT NULL,
    Room_id INT NOT NULL,
    CONSTRAINT FK_RoomsBooked_Reservation FOREIGN KEY (Reservation_id) REFERENCES Reservation (Reservation_id),
    CONSTRAINT FK_RoomsBooked_Room FOREIGN KEY (Room_id) REFERENCES Rooms (Room_id)
);
GO

-- ===================== HOTEL SERVICES USED TABLE =====================
CREATE TABLE Hotel_Services_Used (
    Service_Used_Id INT PRIMARY KEY,
    Hotel_Services_Id INT NOT NULL,
    Service_date DATE NOT NULL DEFAULT GETDATE(),
    Reservation_Id INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    CONSTRAINT FK_ServiceUsed_Service FOREIGN KEY (Hotel_Services_Id) REFERENCES Hotel_Services (Hotel_Services_id),
    CONSTRAINT FK_ServiceUsed_Reservation FOREIGN KEY (Reservation_Id) REFERENCES Reservation (Reservation_id)
);
GO

-- ===================== INVOICE TABLE =====================
CREATE TABLE Invoice (
    Invoice_id INT PRIMARY KEY,
    Invoice_Date DATE NOT NULL DEFAULT GETDATE(),
    Reservation_id INT NOT NULL,
    Total_amount INT NOT NULL CHECK (Total_amount >= 0),
    CONSTRAINT FK_Invoice_Reservation FOREIGN KEY (Reservation_id) REFERENCES Reservation (Reservation_id)
);
GO

-- ===================== PAYMENTS TABLE =====================
CREATE TABLE Payments (
    Payment_Id INT PRIMARY KEY,
    Payment_Mode VARCHAR(15) NOT NULL CHECK (Payment_Mode IN ('Cash', 'Card', 'Online')),
    Status VARCHAR(15) NOT NULL CHECK (Status IN ('Pending', 'Completed', 'Failed')),
    Invoice_id INT NOT NULL,
    CONSTRAINT FK_Payment_Invoice FOREIGN KEY (Invoice_id) REFERENCES Invoice (Invoice_id)
);
GO

-- ===================== RESERVATION AUDIT TABLE =====================
CREATE TABLE ReservationAudit (
    ReservationAuditID INT IDENTITY(1,1) PRIMARY KEY,
    Reservation_id VARCHAR(4) NOT NULL,
    Check_in_Date VARCHAR(15) NOT NULL,
    Check_out_Date VARCHAR(15) NULL,
    Guest_id VARCHAR(5) NOT NULL,
    Is_Canceled CHAR(2) CHECK (Is_Canceled IN ('Y', 'N')),
    [Action] CHAR(1) NOT NULL CHECK ([Action] IN ('I', 'U', 'D')), -- Insert, Update, Delete
    ActionDate DATETIME DEFAULT GETDATE() NOT NULL
);
GO
