

-- GoGet is a car-sharing platform in Australia that allows members to book a vehicle hourly or daily. 
-- It provides a flexible alternative to car ownership and offers a range of vehicles located throughout 
-- major cities. Customers must become members and pay an annual fee to use the service, which also offers 
-- business, senior and student accounts.

-- Official website: https://www.goget.com.au/

-- This database can efficiently manage and store data related to customer bookings, invoices, payments, 
-- vehicle availability, and other important information for a car rental service.

DROP VIEW BookingDetails;
DROP VIEW InvoiceDetails;
DROP VIEW PlanType;

DROP TABLE GG_Plans CASCADE;
DROP TABLE GG_PlanRate CASCADE;
DROP TABLE GG_Pod CASCADE;
DROP TABLE GG_Vehicle CASCADE;
DROP TABLE GG_User CASCADE;
DROP TABLE GG_Booking CASCADE;
DROP TABLE GG_Invoice CASCADE;
DROP TABLE GG_Payment CASCADE;
DROP TABLE GG_Maintenance CASCADE;

CREATE TABLE GG_Plans (

    planID          CHAR(2)     NOT NULL,
    planName        TEXT        NOT NULL,
    pricingModel    TEXT        NOT NULL,
    membershipCost  NUMERIC,     
    
    CONSTRAINT GG_PlansPK PRIMARY KEY (planID),
    
    CONSTRAINT GG_Plans_planID CHECK (planID IN (
        'P1',   -- GoStarter
        'P2',   -- GoOccasional
        'P3',   -- GoFrequent
        'P4',   -- GoBusiness
        'P5',   -- GoStudent
        'P6'    -- GoSenior
        )),
    
    CONSTRAINT GG_Plans_pricingModel CHECK (pricingModel IN (
        'Yearly',   -- pay yearly
        'Monthly'   -- pay monthly
        ))
);

CREATE TABLE GG_Pod (
   
    podID           CHAR(4)     NOT NULL,
    streetNo        integer     NOT NULL,
    streetName      TEXT        NOT NULL,
    suburb          TEXT        NOT NULL,
    postcode        integer     NOT NULL,
    state           CHAR(3)     NOT NULL,

    CONSTRAINT GG_PodPK PRIMARY KEY (podID),

    CONSTRAINT GG_Pod_podID CHECK (
        (podID ~ '^P[0-9]{3}$') AND (podID <> 'P000')),

    CONSTRAINT GG_Pod_state CHECK (state IN (
        'NSW', -- New South Wales
        'QLD', -- Queensland
        'VIC'  -- Victoria
    )),

    CONSTRAINT GG_Pod_postcode CHECK (
        postcode >= 1000 AND postcode <=9999
    )
);

CREATE TABLE GG_Vehicle (
    
    vehicleID       CHAR(4)         NOT NULL,
    plate           VARCHAR(6)      NOT NULL,
    podID           CHAR(4)         NOT NULL,
    type	        TEXT            NOT NULL,
    make            TEXT            NOT NULL,
    model	        TEXT            NOT NULL,
    fuelType	    TEXT            NOT NULL,
    capacity        integer         NOT NULL,

    CONSTRAINT GG_VehiclePK PRIMARY KEY (vehicleID),

    CONSTRAINT GG_VehicleFK_Pod FOREIGN KEY (podID) REFERENCES GG_Pod ON DELETE RESTRICT,

    CONSTRAINT GG_Vehicle_vehicleID CHECK (
        (vehicleID ~ '^V[0-9]{3}$') AND (vehicleID <> 'V000')),

    CONSTRAINT GG_Vehicle_fuelType CHECK (fuelType IN (
        'Diesel',
        'Petrol'
    ))
);

CREATE TABLE GG_PlanRate (
   
    planID         CHAR(2)      NOT NULL,
    vehicleID      CHAR(4)      NOT NULL,
    hourlyRate     DECIMAL      NOT NULL,
    costperKM      DECIMAL      NOT NULL,
    dailyRate      integer      NOT NULL,
    kmIncluded     integer      NOT NULL,
    
    CONSTRAINT GG_PlanRatePK PRIMARY KEY (planID, vehicleID),
    
    CONSTRAINT GG_PlanRateFK_Plans FOREIGN KEY (planID) REFERENCES GG_Plans ON DELETE RESTRICT,

    CONSTRAINT GG_PlanRateFK_Vehicle FOREIGN KEY (vehicleID) REFERENCES GG_Vehicle ON DELETE CASCADE,

    CONSTRAINT GG_PlanRate_hourlyRate CHECK (hourlyRate > 0),

    CONSTRAINT GG_PlanRate_costperKM CHECK (costperKM > 0),

    CONSTRAINT GG_PlanRate_dailyRate CHECK (dailyRate > 0),

    CONSTRAINT GG_PlanRate_kmIncluded CHECK (kmIncluded > 0)
);

CREATE TABLE GG_SmartCard (
    smartCardID     CHAR(10),
    
    CONSTRAINT GG_SmartCardPK PRIMARY KEY (smartcardID),
    
    CONSTRAINT GG_SmartCard_smartcardID CHECK (
                (smartcardID LIKE 'GO%' ) OR 
                (smartcardID LIKE 'GF%' ) OR
                (smartcardID LIKE 'GS%' ) OR
                (smartcardID LIKE 'GST%' ) OR
                (smartcardID LIKE 'GSR%' ) OR
                (smartcardID LIKE 'GB%' )
    )
);

CREATE TABLE GG_User (

    userID	        CHAR(7)         NOT NULL,
    name	        TEXT            NOT NULL,
    email	        VARCHAR(255)    NOT NULL,
    phone	        CHAR(10)        NOT NULL,
    address	        TEXT            NOT NULL,
    licenseNo	    CHAR(8)         NOT NULL,
    planID	        CHAR(2)         NOT NULL,
    smartCardID     CHAR(10)        NOT NULL,

    CONSTRAINT GG_UserPK PRIMARY KEY (userID),

    CONSTRAINT GG_UserFK_Plans FOREIGN KEY (planID) REFERENCES GG_Plans ON DELETE RESTRICT,

    CONSTRAINT GG_UserFK_SmartCard FOREIGN KEY (smartCardID) REFERENCES GG_SmartCard ON DELETE RESTRICT,

    CONSTRAINT GG_User_userID CHECK (
        (userID ~ '^U[0-9]{6}$') AND (userID <> 'U000000')
    ),

    CONSTRAINT GG_User_email CHECK (email LIKE '%@%.%'),

    CONSTRAINT GG_User_phone CHECK (phone ~'^04[0-9]{8}$'),

    CONSTRAINT GG_User_licenseNo UNIQUE (licenseNo)

);
    
CREATE TABLE GG_Booking (

    bookingID	            CHAR(8)         NOT NULL,
    userID	                CHAR(7)         NOT NULL,
    vehicleID	            CHAR(4)         NOT NULL,
    startDate	            date            NOT NULL,
    endDate	                date            NOT NULL,
    startTime	            time            NOT NULL,
    endTime	                time            NOT NULL,
    startOdometerReading    integer	        NOT NULL,
    endOdometerReading	    integer         NOT NULL,
    toll                    NUMERIC,

    CONSTRAINT GG_BookingPK PRIMARY KEY (bookingID),

    CONSTRAINT GG_BookingFK_User FOREIGN KEY (userID) REFERENCES GG_User ON DELETE CASCADE,

    CONSTRAINT GG_BookingFK_Vehicle FOREIGN KEY (vehicleID) REFERENCES GG_Vehicle ON DELETE RESTRICT,

    CONSTRAINT GG_Booking_bookingID CHECK (
        (bookingID ~ '^B[0-9]{7}$') AND (bookingID <> 'B000000')),

    CONSTRAINT GG_Booking_DateCheck CHECK (endDate >= startDate),
    
    CONSTRAINT GG_Booking_TimeCheck CHECK (endTime >= startTime),

    CONSTRAINT GG_Booking_OdometerReadingCheck CHECK (endOdometerReading >= startOdometerReading)

);

CREATE TABLE GG_Invoice (

    invoiceID	        CHAR(8)         NOT NULL,
    bookingID	        CHAR(8)         NOT NULL,
    userID	            CHAR(7)         NOT NULL,
    amount              DECIMAL         NOT NULL,
    invoiceDate         date            NOT NULL,
    description         TEXT            NOT NULL,

    CONSTRAINT GG_InvoicePK PRIMARY KEY (invoiceID),

    CONSTRAINT GG_InvoiceFK_User FOREIGN KEY (userID) REFERENCES GG_User ON DELETE CASCADE,

    CONSTRAINT GG_InvoiceFK_Booking FOREIGN KEY (bookingID) REFERENCES GG_Booking ON DELETE CASCADE,

    CONSTRAINT GG_Invoice_invoiceID CHECK (
        (invoiceID ~ '^[A-Z 0-9]{8}$')),
    
    CONSTRAINT GG_Invoice_amount CHECK (amount > 0),

    CONSTRAINT GG_Invoice_description CHECK (description IN(
        'Day Fare',
        'Extra Fare',
        'Toll',
        'Fare'
    ))
);

CREATE TABLE GG_Payment (
    
    paymentID           CHAR(8)         NOT NULL,
    invoiceID	        CHAR(8)         NOT NULL,
    userID	            CHAR(7)         NOT NULL,
    paymentMethod       TEXT            NOT NULL,
    paymentStatus       TEXT            NOT NULL,
    paymentDate         date            NOT NULL,
 
    CONSTRAINT GG_PaymentPK PRIMARY KEY (paymentID),

    CONSTRAINT GG_PaymentFK_User FOREIGN KEY (userID) REFERENCES GG_User ON DELETE CASCADE,

    CONSTRAINT GG_PaymentFK_Invoice FOREIGN KEY (invoiceID) REFERENCES GG_Invoice ON DELETE CASCADE,

    CONSTRAINT GG_Payment_paymentID CHECK (
        (paymentID ~ '[A-Z 0-9]{8}$')),
    
    CONSTRAINT GG_Payment_paymentMethod CHECK (paymentMethod IN (
        'DirectDebit', 
        'PayPal',
        'Credit'
    )),
   
    CONSTRAINT GG_Payment_paymentStatus CHECK (paymentStatus IN (
        'Approved',
        'Pending',
        'Unsuccessful'
    ))
);

CREATE TABLE GG_Maintenance (
    
    maintenanceID           CHAR(4)         NOT NULL,
    vehicleID 	            CHAR(4)         NOT NULL,
    maintenanceDate	        date            NOT NULL,
    service	                TEXT            NOT NULL,
    mileage	                integer         NOT NULL,
    cost                    integer         NOT NULL,
    previousMaintenanceID   CHAR(4),
   
 
    CONSTRAINT GG_MaintenancePK PRIMARY KEY (maintenanceID),

    CONSTRAINT GG_MaintenanceFK_Vehicle FOREIGN KEY (vehicleID) REFERENCES GG_Vehicle ON DELETE CASCADE,

    CONSTRAINT GG_MaintenanceFK_Maintenance FOREIGN KEY (previousMaintenanceID) REFERENCES GG_Maintenance ON DELETE RESTRICT,
    
    CONSTRAINT GG_maintenance_maintenanceID CHECK (
        (maintenanceID ~ '^M[0-9]{3}$') AND (maintenanceID <> 'M000')),
    
    CONSTRAINT GG_maintenance_service CHECK (service IN (
        'Oil change',
        'Fluid replacement',
        'Battery check',
        'Brake inspection',
        'Alignment check',
        'Tire rotation'
    )),  

    CONSTRAINT GG_maintenance_cost CHECK (cost > 0)
);

CREATE VIEW BookingDetails AS
    SELECT bookingID, name, plate, state AS location, endOdometerReading - startOdometerReading AS Distance,
    endDate - startDate AS days, EXTRACT(EPOCH FROM (endTime - startTime)) / 3600 as hours
    FROM GG_Booking, GG_Vehicle, GG_User, GG_Pod
    WHERE GG_Booking.vehicleID = GG_Vehicle.vehicleID 
    AND GG_Booking.userID = GG_User.userID
    AND GG_Vehicle.podID = GG_Pod.podID;


CREATE VIEW InvoiceDetails AS
    SELECT GG_Booking.bookingID, GG_Booking.userID, sum(amount) as totalFare 
    FROM GG_Booking, GG_Invoice
    WHERE GG_Booking.bookingID = GG_Invoice.bookingID
    GROUP BY GG_Booking.bookingID;


CREATE VIEW PlanType AS
    SELECT DISTINCT planName, type, hourlyRate, costperKM, dailyRate from GG_Plans, GG_PlanRate, GG_Vehicle 
    WHERE GG_Plans.planID = GG_PlanRate.planID 
    AND GG_PlanRate.vehicleID = GG_Vehicle.vehicleID
    ORDER BY planName;


INSERT INTO GG_Plans VALUES ('P1','GoFrequent','Monthly',30);
INSERT INTO GG_Plans VALUES ('P2','GoOccasional','Monthly',12);
INSERT INTO GG_Plans VALUES ('P3','GoStarter','Yearly',49);
INSERT INTO GG_Plans VALUES ('P4','GoBusiness','Monthly',NULL);
INSERT INTO GG_Plans VALUES ('P5','GoSenior','Monthly',NULL);
INSERT INTO GG_Plans VALUES ('P6','GoStudent','Yearly',35);

INSERT INTO GG_Pod VALUES ('P001',10,'The Boulevarde','Strathfield',2135,'NSW');
INSERT INTO GG_Pod VALUES ('P002',120,'Spencer Street','Docklands',3008,'VIC');
INSERT INTO GG_Pod VALUES ('P003',22,'William Street','Earlwood',2206,'NSW');
INSERT INTO GG_Pod VALUES ('P004',10,'Ann Street','Fortitude Valley',4006,'QLD');
INSERT INTO GG_Pod VALUES ('P005',120,'King St','Sydney',2000,'NSW');
INSERT INTO GG_Pod VALUES ('P006',20,'Chapel Street','Prahran',3181,'VIC');
INSERT INTO GG_Pod VALUES ('P007',34,'Station Road','Indooroopilly',4068,'QLD');
INSERT INTO GG_Pod VALUES ('P008',12,'Railway Parade','Burwood',2134,'NSW');
INSERT INTO GG_Pod VALUES ('P009',32,'Pacific Highway','North Sydney',2060,'NSW');
INSERT INTO GG_Pod VALUES ('P010',10,'High Street','Armadale',3143,'VIC');
INSERT INTO GG_Pod VALUES ('P011',20,'Macgregor Terrace','Bardon',4065,'QLD');
INSERT INTO GG_Pod VALUES ('P012',150,'Lonsdale Street','Melbourne',3000,'VIC');
INSERT INTO GG_Pod VALUES ('P013',10,'George St','Sydney',2000,'NSW');
INSERT INTO GG_Pod VALUES ('P014',35,'Station Street','Caulfield',3162,'VIC');
INSERT INTO GG_Pod VALUES ('P015',18,'Chermside Street','Teneriffe',4005,'QLD');
INSERT INTO GG_Pod VALUES ('P016',30,'Chandos Street','Ashfield',2131,'NSW');
INSERT INTO GG_Pod VALUES ('P017',30,'Park St','Sydney',2000,'NSW');
INSERT INTO GG_Pod VALUES ('P018',6,'Wilson Street','Newtown',2042,'NSW');
INSERT INTO GG_Pod VALUES ('P019',45,'Mains Road','Sunnybank',4109,'QLD');
INSERT INTO GG_Pod VALUES ('P020',55,'Enoggera Terrace','Red Hill',4059,'QLD');
INSERT INTO GG_Pod VALUES ('P021',45,'Parramatta Road','Homebush',2140,'NSW');
INSERT INTO GG_Pod VALUES ('P022',15,'Campbell Street','Parramatta',2150,'NSW');
INSERT INTO GG_Pod VALUES ('P023',8,'Pearl River Road','Docklands',3008,'VIC');
INSERT INTO GG_Pod VALUES ('P024',45,'Church Street','Parramatta',2150,'NSW');
INSERT INTO GG_Pod VALUES ('P025',123,'Russell Street','Carlton',3053,'VIC');
INSERT INTO GG_Pod VALUES ('P026',10,'Merchant Street','Docklands',3008,'VIC');
INSERT INTO GG_Pod VALUES ('P027',10,'Oxford Street','Bondi Junction',2022,'NSW');
INSERT INTO GG_Pod VALUES ('P028',20,'Bridge Road','Glebe',2037,'NSW');
INSERT INTO GG_Pod VALUES ('P029',12,'Botany Street','Kingsford',2032,'NSW');
INSERT INTO GG_Pod VALUES ('P030',55,'Adelaide Street','Brisbane',4000,'QLD');

INSERT INTO GG_Vehicle VALUES ('V001','RIV234','P001','Small Hatchback','Toyota','Yaris','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V002','XTW289','P002','Small Hatchback','Honda','Jazz','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V003','XGG554','P003','Small Hatchback','Mazda','2','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V004','RSL009','P004','Small Hatchback','Hyundai','Accent','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V005','PJC980','P005','Small Hatchback','Kia','Rio','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V006','ZKB977','P006','Medium Hatchback','Volkswagen','Golf','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V007','RHN476','P007','Medium Hatchback','Ford','Focus','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V008','XJH381','P008','Medium Hatchback','Subaru','Impreza','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V009','UYT840','P009','Medium Hatchback','Peugeot','308','Diesel', 5);
INSERT INTO GG_Vehicle VALUES ('V010','QNB640','P010','Medium Hatchback','Honda','Civic','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V011','NSP005','P011','SUV','Hyundai','Tucson','Diesel', 5);
INSERT INTO GG_Vehicle VALUES ('V012','VNB212','P012','SUV','Kia','Seltos','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V013','SZF473','P013','SUV','Volkswagen','Tiguan','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V014','YQO117','P014','SUV','Mitsubishi','Outlander','Petrol', 7);
INSERT INTO GG_Vehicle VALUES ('V015','WKN819','P015','SUV','Nissan','Pathfinder','Diesel', 7);
INSERT INTO GG_Vehicle VALUES ('V016','TEL624','P016','Medium Van','Toyota','HiAce Commuter','Diesel', 12);
INSERT INTO GG_Vehicle VALUES ('V017','GFO732','P017','Medium Van','Hyundai','iMax','Petrol', 7);
INSERT INTO GG_Vehicle VALUES ('V018','IUB406','P018','Medium Van','Volkswagen','Caravelle','Diesel', 7);
INSERT INTO GG_Vehicle VALUES ('V019','GDA247','P019','Medium Van','Kia','Carnival','Petrol', 8);
INSERT INTO GG_Vehicle VALUES ('V020','YUP818','P020','Medium Van','Mercedes-Benz','Vito','Diesel', 5);
INSERT INTO GG_Vehicle VALUES ('V021','MNO678','P021','Medium Van','BMW','2 Series','Diesel', 5);
INSERT INTO GG_Vehicle VALUES ('V022','PQR123','P022','Small Hatchback','i','A1','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V023','STU456','P023','Small Hatchback','BMW','1 Series','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V024','VWX789','P024','Small Hatchback','Mercedes-Benz','C200','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V025','YZA012','P025','Small Hatchback','Volvo','V40','Diesel', 5);
INSERT INTO GG_Vehicle VALUES ('V026','BCD345','P026','Small Hatchback','Lexus','CT','Petrol', 5);
INSERT INTO GG_Vehicle VALUES ('V027','WXY123','P027','People Mover','Kia','Carnival','Diesel', 8);
INSERT INTO GG_Vehicle VALUES ('V028','YZA456','P028','People Mover','Toyota','Tarago','Petrol', 8);
INSERT INTO GG_Vehicle VALUES ('V029','BCD789','P029','People Mover','Hyundai','iMax','Diesel', 8);
INSERT INTO GG_Vehicle VALUES ('V030','DEF012','P030','People Mover','Volkswagen','Multivan','Diesel', 10);

INSERT INTO GG_PlanRate VALUES ('P1','V001',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V002',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V003',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V004',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V005',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V022',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V023',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V024',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V025',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V026',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P1','V006',8.2,0.44,94,120);
INSERT INTO GG_PlanRate VALUES ('P1','V007',8.2,0.44,94,120);
INSERT INTO GG_PlanRate VALUES ('P1','V008',8.2,0.44,94,120);
INSERT INTO GG_PlanRate VALUES ('P1','V009',8.2,0.44,94,120);
INSERT INTO GG_PlanRate VALUES ('P1','V010',8.2,0.44,94,120);
INSERT INTO GG_PlanRate VALUES ('P1','V011',10.5,0.44,105,120);
INSERT INTO GG_PlanRate VALUES ('P1','V012',10.5,0.44,105,120);
INSERT INTO GG_PlanRate VALUES ('P1','V013',10.5,0.44,105,120);
INSERT INTO GG_PlanRate VALUES ('P1','V014',10.5,0.44,105,120);
INSERT INTO GG_PlanRate VALUES ('P1','V015',10.5,0.44,105,120);
INSERT INTO GG_PlanRate VALUES ('P1','V016',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P1','V017',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P1','V018',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P1','V019',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P1','V020',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P1','V021',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P1','V027',12.7,0.44,142,120);
INSERT INTO GG_PlanRate VALUES ('P1','V028',12.7,0.44,142,120);
INSERT INTO GG_PlanRate VALUES ('P1','V029',12.7,0.44,142,120);
INSERT INTO GG_PlanRate VALUES ('P1','V030',12.7,0.44,142,120);
INSERT INTO GG_PlanRate VALUES ('P2','V001',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V002',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V003',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V004',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V005',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V022',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V023',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V024',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V025',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V026',10.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P2','V006',11.2,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P2','V007',11.2,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P2','V008',11.2,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P2','V009',11.2,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P2','V010',11.2,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P2','V011',14.3,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P2','V012',14.3,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P2','V013',14.3,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P2','V014',14.3,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P2','V015',14.3,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P2','V016',14.3,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P2','V017',14.3,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P2','V018',14.3,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P2','V019',14.3,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P2','V020',14.3,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P2','V021',14.3,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P2','V027',17.3,0.44,155,120);
INSERT INTO GG_PlanRate VALUES ('P2','V028',17.3,0.44,155,120);
INSERT INTO GG_PlanRate VALUES ('P2','V029',17.3,0.44,155,120);
INSERT INTO GG_PlanRate VALUES ('P2','V030',17.3,0.44,155,120);
INSERT INTO GG_PlanRate VALUES ('P3','V001',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V002',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V003',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V004',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V005',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V022',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V023',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V024',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V025',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V026',12.1,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P3','V006',13.1,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P3','V007',13.1,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P3','V008',13.1,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P3','V009',13.1,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P3','V010',13.1,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P3','V011',6.8,0.44,124,120);
INSERT INTO GG_PlanRate VALUES ('P3','V012',6.8,0.44,124,120);
INSERT INTO GG_PlanRate VALUES ('P3','V013',6.8,0.44,124,120);
INSERT INTO GG_PlanRate VALUES ('P3','V014',6.8,0.44,124,120);
INSERT INTO GG_PlanRate VALUES ('P3','V015',6.8,0.44,124,120);
INSERT INTO GG_PlanRate VALUES ('P3','V016',16.8,0.44,118,120);
INSERT INTO GG_PlanRate VALUES ('P3','V017',16.8,0.44,118,120);
INSERT INTO GG_PlanRate VALUES ('P3','V018',16.8,0.44,118,120);
INSERT INTO GG_PlanRate VALUES ('P3','V019',16.8,0.44,118,120);
INSERT INTO GG_PlanRate VALUES ('P3','V020',16.8,0.44,118,120);
INSERT INTO GG_PlanRate VALUES ('P3','V021',16.8,0.44,118,120);
INSERT INTO GG_PlanRate VALUES ('P3','V027',20.3,0.44,167,120);
INSERT INTO GG_PlanRate VALUES ('P3','V028',20.3,0.44,167,120);
INSERT INTO GG_PlanRate VALUES ('P3','V029',20.3,0.44,167,120);
INSERT INTO GG_PlanRate VALUES ('P3','V030',20.3,0.44,167,120);
INSERT INTO GG_PlanRate VALUES ('P4','V001',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V002',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V003',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V004',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V005',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V022',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V023',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V024',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V025',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V026',8.3,0.44,95,120);
INSERT INTO GG_PlanRate VALUES ('P4','V006',10.5,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P4','V007',10.5,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P4','V008',10.5,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P4','V009',10.5,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P4','V010',10.5,0.44,102,120);
INSERT INTO GG_PlanRate VALUES ('P4','V011',13.4,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P4','V012',13.4,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P4','V013',13.4,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P4','V014',13.4,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P4','V015',13.4,0.44,150,120);
INSERT INTO GG_PlanRate VALUES ('P4','V016',13.4,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P4','V017',13.4,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P4','V018',13.4,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P4','V019',13.4,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P4','V020',13.4,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P4','V021',13.4,0.44,110,120);
INSERT INTO GG_PlanRate VALUES ('P4','V027',16.2,0.44,155,120);
INSERT INTO GG_PlanRate VALUES ('P4','V028',16.2,0.44,155,120);
INSERT INTO GG_PlanRate VALUES ('P4','V029',16.2,0.44,155,120);
INSERT INTO GG_PlanRate VALUES ('P4','V030',16.2,0.44,155,120);
INSERT INTO GG_PlanRate VALUES ('P5','V001',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V002',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V003',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V004',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V005',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V022',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V023',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V024',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V025',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V026',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P5','V006',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P5','V007',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P5','V008',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P5','V009',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P5','V010',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P5','V011',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P5','V012',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P5','V013',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P5','V014',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P5','V015',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P5','V016',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P5','V017',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P5','V018',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P5','V019',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P5','V020',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P5','V021',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P5','V027',16.2,0.44,152,120);
INSERT INTO GG_PlanRate VALUES ('P5','V028',16.2,0.44,152,120);
INSERT INTO GG_PlanRate VALUES ('P5','V029',16.2,0.44,152,120);
INSERT INTO GG_PlanRate VALUES ('P5','V030',16.2,0.44,152,120);
INSERT INTO GG_PlanRate VALUES ('P6','V001',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V002',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V003',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V004',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V005',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V022',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V023',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V024',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V025',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V026',7.6,0.44,87,120);
INSERT INTO GG_PlanRate VALUES ('P6','V006',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P6','V007',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P6','V008',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P6','V009',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P6','V010',10.5,0.44,100,120);
INSERT INTO GG_PlanRate VALUES ('P6','V011',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P6','V012',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P6','V013',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P6','V014',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P6','V015',13.4,0.44,113,120);
INSERT INTO GG_PlanRate VALUES ('P6','V016',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P6','V017',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P6','V018',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P6','V019',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P6','V020',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P6','V021',13.4,0.44,108,120);
INSERT INTO GG_PlanRate VALUES ('P6','V027',16.2,0.44,152,120);
INSERT INTO GG_PlanRate VALUES ('P6','V028',16.2,0.44,152,120);
INSERT INTO GG_PlanRate VALUES ('P6','V029',16.2,0.44,152,120);
INSERT INTO GG_PlanRate VALUES ('P6','V030',16.2,0.44,152,120);

INSERT INTO GG_SmartCard VALUES ('GB219T34R6');
INSERT INTO GG_SmartCard VALUES ('GB878T25E3');
INSERT INTO GG_SmartCard VALUES ('GF074T96N2');
INSERT INTO GG_SmartCard VALUES ('GF321H65K9');
INSERT INTO GG_SmartCard VALUES ('GF342E13B6');
INSERT INTO GG_SmartCard VALUES ('GF365T87H3');
INSERT INTO GG_SmartCard VALUES ('GF376T21E9');
INSERT INTO GG_SmartCard VALUES ('GF382J49T7');
INSERT INTO GG_SmartCard VALUES ('GF428K95L6');
INSERT INTO GG_SmartCard VALUES ('GF586R57P4');
INSERT INTO GG_SmartCard VALUES ('GF846S29J5');
INSERT INTO GG_SmartCard VALUES ('GF919V34D6');
INSERT INTO GG_SmartCard VALUES ('GF997G54R2');
INSERT INTO GG_SmartCard VALUES ('GO245G79B1');
INSERT INTO GG_SmartCard VALUES ('GO309R43C6');
INSERT INTO GG_SmartCard VALUES ('GO334L87P9');
INSERT INTO GG_SmartCard VALUES ('GO345G79B1');
INSERT INTO GG_SmartCard VALUES ('GO462K38T7');
INSERT INTO GG_SmartCard VALUES ('GO809S56K1');
INSERT INTO GG_SmartCard VALUES ('GO876U98W4');
INSERT INTO GG_SmartCard VALUES ('GO954V32R6');
INSERT INTO GG_SmartCard VALUES ('GO998E25A1');
INSERT INTO GG_SmartCard VALUES ('GOH25F19D8');
INSERT INTO GG_SmartCard VALUES ('GS1E6C8D2');
INSERT INTO GG_SmartCard VALUES ('GS6C9E2D7');
INSERT INTO GG_SmartCard VALUES ('GS7B5E8D1');
INSERT INTO GG_SmartCard VALUES ('GSR32K16H9');
INSERT INTO GG_SmartCard VALUES ('GSR33D16H9');
INSERT INTO GG_SmartCard VALUES ('GST7D1F6C2');
INSERT INTO GG_SmartCard VALUES ('GST8D6F5B1');

INSERT INTO GG_User VALUES ('U000001','Chloe Cooper','chloe.cooper@gmail.com','0421234567','21 Oxford St, Paddington NSW 2021','12345678','P1', 'GF382J49T7');
INSERT INTO GG_User VALUES ('U000002','Liam Truong','liam.nguyen@hotmail.com','0432345678','12 Smith St, Fitzroy VIC 3065','23456789','P1', 'GF428K95L6');
INSERT INTO GG_User VALUES ('U000003','Ethan Wong','ethan.wong@gmail.com','0423456789','39 Hotham St, St Kilda VIC 3182','34567890','P4', 'GB219T34R6');
INSERT INTO GG_User VALUES ('U000004','Aaron Lee','aaron.lee@yahoo.com','0434567890','56 Wharf Rd, Gladesville NSW 2111','45678901','P1', 'GF376T21E9');
INSERT INTO GG_User VALUES ('U000005','Noah Tan','noah.tan@hotmail.com','0421678901','10 Brighton Rd, St Kilda East VIC 3183','56789012','P6', 'GST7D1F6C2');
INSERT INTO GG_User VALUES ('U000006','Sophia Kim','sophia.kim@gmail.com','0411111111','11 Grandview Rd, Box Hill North VIC 3129','67890123','P2', 'GO309R43C6');
INSERT INTO GG_User VALUES ('U000007','Lucas Singh','lucas.singh@yahoo.com','0422222222','22 Oxford St, Darlinghurst NSW 2010','78901234','P1', 'GF321H65K9');
INSERT INTO GG_User VALUES ('U000008','Mia Baker','mia.baker@hotmail.com','0433333333','4/16 Queens Ave, Hawthorn VIC 3122','89012345','P2', 'GOH25F19D8');
INSERT INTO GG_User VALUES ('U000009','Min Lee','min.lee@gmail.com','0462135790','45 King St, Newtown NSW 2042','90123456','P4', 'GB878T25E3');
INSERT INTO GG_User VALUES ('U000010','Minji Park','minji.park@hotmail.com','0481569324','8/32 Queens Rd, Melbourne VIC 3004','1234567','P5', 'GSR33D16H9');
INSERT INTO GG_User VALUES ('U000011','Emily Nguyen','emily.nguyen@yahoo.com','0439251678','24 Johnson St, Abbotsford VIC 3067','13579246','P6', 'GSR32K16H9');
INSERT INTO GG_User VALUES ('U000012','William Rao','william.rao@gmail.com','0457913824','22 Campbell St, Toowong QLD 4066','24681357','P6', 'GO462K38T7');
INSERT INTO GG_User VALUES ('U000013','Madison Wong','madison.wong@yahoo.com','0401547923','16 Bunnerong Rd, Pagewood NSW 2035','36925814','P1', 'GF997G54R2');
INSERT INTO GG_User VALUES ('U000014','Samuel Kim','samuel.kim@hotmail.com','0418793624','41 Florence St, Mentone VIC 3194','48121620','P4', 'GO998E25A1');
INSERT INTO GG_User VALUES ('U000015','Ava Tan','ava.tan@gmail.com','0472981563','3/7B Victoria St, Brunswick VIC 3056','59202357','P3', 'GO345G79B1');
INSERT INTO GG_User VALUES ('U000016','Henry Singh','henry.singh@yahoo.com','0426187935','9/17-19 Darcy Rd, Westmead NSW 2145','67092348','P1', 'GF074T96N2');
INSERT INTO GG_User VALUES ('U000017','Grace Chen','grace.chen@hotmail.com','0449312765','5/28 Waverley Rd, Malvern East VIC 3145','71235519','P2', 'GO334L87P9');
INSERT INTO GG_User VALUES ('U000018','Justin Mohammed','justin.mohammed@gmail.com','0498732516','7/18 Aspinall St, Nundah QLD 4012','82420367','P1', 'GF586R57P4');
INSERT INTO GG_User VALUES ('U000019','Jennifer Chen','jennifer.chen@hotmail.com','0412639745','42 Station St, Parramatta NSW 2150','93703092','P1', 'GF919V34D6');
INSERT INTO GG_User VALUES ('U000020','Ivy Nguyen','ivy.nguyen@gmail.com','0437521986','17 Richardson St, Essendon VIC 3040','1928374','P2', 'GO245G79B1');
INSERT INTO GG_User VALUES ('U000021','Ashley Tanaka','ashley.tanaka@yahoo.com','0459871423','29 Charlotte St, Wynnum QLD 4178','90283746','P2', 'GO954V32R6');
INSERT INTO GG_User VALUES ('U000022','Haley Wong','haley.wong@hotmail.com','0409478126','6/27 Young St, Cremorne VIC 3121','87461923','P2', 'GO876U98W4');
INSERT INTO GG_User VALUES ('U000023','Jacob Kim','jacob.kim@gmail.com','0425691837','31 Fourth Ave, Campsie NSW 2194','76543210','P6', 'GF342E13B6');
INSERT INTO GG_User VALUES ('U000024','Alex Singh','Alex.singh@yahoo.com','0428365194','9/7-9 Joyce St, Pendle Hill NSW 2145','10293847','P6', 'GST8D6F5B1');
INSERT INTO GG_User VALUES ('U000025','Priscilla Do','priscilla.do@gmail.com','0462159824','61 Davis St, Kew VIC 3101','39482016','P2', 'GO809S56K1');
INSERT INTO GG_User VALUES ('U000026','Isabella Lewis','isabella.lewis@gmail.com','0432819475','15 Mersey Rd, Norlane VIC 3214','82016394','P1', 'GF846S29J5');
INSERT INTO GG_User VALUES ('U000027','Nathan Ho','nathan.ho@hotmail.com','0409518364','8 Derwent St, Sandy Bay TAS 7005','16394720','P3', 'GS1E6C8D2');
INSERT INTO GG_User VALUES ('U000028','Charlotte Patel','charlotte.patel@gmail.com','0478925361','13 Kent St, Epping NSW 2121','94720163','P1', 'GF365T87H3');
INSERT INTO GG_User VALUES ('U000029','Kelly Clark','kelly.clark@yahoo.com','0428513796','33 Balaka Dr, Berwick VIC 3806','20163849','P3', 'GS7B5E8D1');
INSERT INTO GG_User VALUES ('U000030','Will Zhang','will.zhang@hotmail.com','0436715892','15 Devonport St, Fairfield QLD 4103','63849201','P3', 'GS6C9E2D7');

INSERT INTO GG_Booking VALUES ('B0000001','U000019','V009','2022-01-23','2022-01-23','11:00:00', '19:00:00',8123, 8199,3.5);
INSERT INTO GG_Booking VALUES ('B0000002','U000002','V002','2022-03-31','2022-04-01','12:00:00', '12:00:00',11001, 11100,6.2);
INSERT INTO GG_Booking VALUES ('B0000003','U000004','V008','2022-04-12','2022-04-13','09:30:00', '09:30:00',37500, 37800,NULL);
INSERT INTO GG_Booking VALUES ('B0000004','U000013','V013','2022-04-18','2022-04-19','12:00:00', '15:00:00',16245, 16635,8.5);
INSERT INTO GG_Booking VALUES ('B0000005','U000018','V004','2022-05-05','2022-05-06','10:00:00', '12:00:00',45930, 46214,10.5);
INSERT INTO GG_Booking VALUES ('B0000006','U000021','V018','2022-05-26','2022-05-26','07:00:00', '12:00:00',98238, 98315,7.8);
INSERT INTO GG_Booking VALUES ('B0000007','U000030','V011','2022-06-10','2022-06-11','13:30:00', '13:30:00',12510, 12672,NULL);
INSERT INTO GG_Booking VALUES ('B0000008','U000002','V014','2022-06-14','2022-06-15','10:00:00', '10:00:00',12987, 13134,7.25);
INSERT INTO GG_Booking VALUES ('B0000009','U000016','V009','2022-06-22','2022-06-22','09:00:00', '15:30:00',8199, 8368,NULL);
INSERT INTO GG_Booking VALUES ('B0000010','U000021','V015','2022-07-02','2022-07-03','12:30:00', '14:30:00',109301, 109567,4);
INSERT INTO GG_Booking VALUES ('B0000011','U000025','V014','2022-07-12','2022-07-13','09:00:00', '11:30:00',13134, 13527,5.5);
INSERT INTO GG_Booking VALUES ('B0000012','U000021','V028','2022-08-02','2022-08-02','07:00:00', '14:00:00',14874, 15021,NULL);
INSERT INTO GG_Booking VALUES ('B0000013','U000018','V015','2022-08-09','2022-08-09','08:30:00', '12:00:00',109567, 109606,6.75);
INSERT INTO GG_Booking VALUES ('B0000014','U000012','V004','2022-09-08','2022-09-08','09:00:00', '14:00:00',46214, 46289,NULL);
INSERT INTO GG_Booking VALUES ('B0000015','U000023','V022','2022-09-27','2022-09-27','09:00:00', '21:00:00',28765, 28923,6);
INSERT INTO GG_Booking VALUES ('B0000016','U000029','V010','2022-10-21','2022-10-21','10:00:00', '13:00:00',45359, 45432,12.5);
INSERT INTO GG_Booking VALUES ('B0000017','U000012','V019','2022-11-11','2022-11-12','11:00:00', '11:00:00',11834, 12055,NULL);
INSERT INTO GG_Booking VALUES ('B0000018','U000019','V022','2022-11-19','2022-11-19','12:30:00', '19:00:00',223492, 223598,4.5);
INSERT INTO GG_Booking VALUES ('B0000019','U000012','V030','2022-12-17','2022-12-17','08:00:00', '12:30:00',9867, 9903,NULL);
INSERT INTO GG_Booking VALUES ('B0000020','U000014','V010','2022-12-26','2022-12-26','17:00:00', '21:00:00',45432, 45467,6.2);

INSERT INTO GG_Invoice VALUES ('H7J2Q1D9','B0000004','U000013',105,'2022-04-18','Day Fare');
INSERT INTO GG_Invoice VALUES ('F5K6N8E1','B0000004','U000013',150.3,'2022-04-19','Extra Fare');
INSERT INTO GG_Invoice VALUES ('L4M5J7P8','B0000004','U000013',8.5,'2022-04-25','Toll');
INSERT INTO GG_Invoice VALUES ('N9E1H5K6','B0000005','U000018',87,'2022-05-05','Day Fare');
INSERT INTO GG_Invoice VALUES ('P8L9N2J5','B0000005','U000018',87.36,'2022-05-06','Extra Fare');
INSERT INTO GG_Invoice VALUES ('J2P8K6N5','B0000005','U000018',10.5,'2022-05-12','Toll');
INSERT INTO GG_Invoice VALUES ('K6F5D9N2','B0000010','U000021',150,'2022-07-02','Day Fare');
INSERT INTO GG_Invoice VALUES ('M5P8H7Q1','B0000010','U000021',92.84,'2022-07-03','Extra Fare');
INSERT INTO GG_Invoice VALUES ('Q1L4E1N9','B0000010','U000021',4,'2022-07-09','Toll');
INSERT INTO GG_Invoice VALUES ('E1H7F5K6','B0000011','U000025',150,'2022-07-12','Day Fare');
INSERT INTO GG_Invoice VALUES ('N9M5D9J2','B0000011','U000025',155.87,'2022-07-13','Extra Fare');
INSERT INTO GG_Invoice VALUES ('K6J2Q1N9','B0000011','U000025',5.5,'2022-07-19','Toll');
INSERT INTO GG_Invoice VALUES ('D9H7L4N2','B0000001','U000019',94.24,'2022-01-23','Fare');
INSERT INTO GG_Invoice VALUES ('J2N9P8K6','B0000001','U000019',3.5,'2022-01-30','Toll');
INSERT INTO GG_Invoice VALUES ('H7K6F5J2','B0000002','U000002',87,'2022-03-31','Day Fare');
INSERT INTO GG_Invoice VALUES ('L4D9N2M5','B0000002','U000002',6.2,'2022-04-08','Toll');
INSERT INTO GG_Invoice VALUES ('F5P8J2H7','B0000003','U000004',94,'2022-04-12','Day Fare');
INSERT INTO GG_Invoice VALUES ('P8K6N2L4','B0000003','U000004',79.2,'2022-04-13','Extra Fare');
INSERT INTO GG_Invoice VALUES ('J2N9D9L4','B0000006','U000021',105.38,'2022-05-26','Fare');
INSERT INTO GG_Invoice VALUES ('K6P8H7E1','B0000006','U000021',7.8,'2022-06-02','Toll');
INSERT INTO GG_Invoice VALUES ('M5J2N9F5','B0000007','U000030',124,'2022-06-10','Day Fare');
INSERT INTO GG_Invoice VALUES ('N2E1H7L4','B0000007','U000030',18.48,'2022-06-11','Extra Fare');
INSERT INTO GG_Invoice VALUES ('L4K6P8H7','B0000013','U000018',53.91,'2022-08-09','Fare');
INSERT INTO GG_Invoice VALUES ('D9J2M5N9','B0000013','U000018',6.75,'2022-08-16','Toll');
INSERT INTO GG_Invoice VALUES ('J2L4F5P8','B0000015','U000023',160.72,'2022-09-27','Fare');
INSERT INTO GG_Invoice VALUES ('H7M5E1D9','B0000015','U000023',6,'2022-09-29','Toll');
INSERT INTO GG_Invoice VALUES ('F5N9K6J2','B0000016','U000029',71.42,'2022-10-21','Fare');
INSERT INTO GG_Invoice VALUES ('P8D9H7N2','B0000016','U000029',12.5,'2022-10-28','Toll');
INSERT INTO GG_Invoice VALUES ('K6Q1L4E1','B0000017','U000012',108,'2022-11-11','Day Fare');
INSERT INTO GG_Invoice VALUES ('M5H7N9P8','B0000017','U000012',44.44,'2022-11-12','Extra Fare');
INSERT INTO GG_Invoice VALUES ('N2J2F5L4','B0000018','U000019',96.04,'2022-11-19','Fare');
INSERT INTO GG_Invoice VALUES ('E1N9M5K6','B0000018','U000019',4.5,'2022-11-26','Toll');
INSERT INTO GG_Invoice VALUES ('L4K6D9P8','B0000020','U000014',57.4,'2022-12-26','Fare');
INSERT INTO GG_Invoice VALUES ('D9H7J2Q1','B0000020','U000014',6.2,'2023-01-03','Toll');
INSERT INTO GG_Invoice VALUES ('J2N2P8M5','B0000009','U000016',142.61,'2022-06-22','Fare');
INSERT INTO GG_Invoice VALUES ('H7P8K6N9','B0000012','U000021',185.78,'2022-08-02','Fare');
INSERT INTO GG_Invoice VALUES ('F5L4E1H7','B0000014','U000012',71,'2022-09-08','Fare');
INSERT INTO GG_Invoice VALUES ('P8N9J2M5','B0000019','U000012',88.74,'2022-12-17','Fare');
INSERT INTO GG_Invoice VALUES ('K6M5Q1D9','B0000008','U000002',105,'2022-06-14','Day Fare');
INSERT INTO GG_Invoice VALUES ('Q1H7N9K6','B0000008','U000002',11.88,'2022-06-15','Fare');
INSERT INTO GG_Invoice VALUES ('L4F5M5J2','B0000008','U000002',7.25,'2022-06-21','Toll');

INSERT INTO GG_Payment VALUES ('EKPMK853','D9H7L4N2','U000019','DirectDebit','Approved','2022-01-23');
INSERT INTO GG_Payment VALUES ('QNBJN671','J2N9P8K6','U000019','DirectDebit','Approved','2022-01-30');
INSERT INTO GG_Payment VALUES ('TVJZJ246','H7K6F5J2','U000002','DirectDebit','Approved','2022-04-01');
INSERT INTO GG_Payment VALUES ('HLXDL489','L4D9N2M5','U000002','DirectDebit','Approved','2022-04-08');
INSERT INTO GG_Payment VALUES ('VKSBS932','F5P8J2H7','U000004','DirectDebit','Approved','2022-04-12');
INSERT INTO GG_Payment VALUES ('HJLRL155','P8K6N2L4','U000004','DirectDebit','Approved','2022-04-13');
INSERT INTO GG_Payment VALUES ('CMGFG723','H7J2Q1D9','U000013','PayPal','Approved','2022-04-18');
INSERT INTO GG_Payment VALUES ('ZDXWX361','F5K6N8E1','U000013','PayPal','Approved','2022-04-19');
INSERT INTO GG_Payment VALUES ('LVGVG308','L4M5J7P8','U000013','PayPal','Approved','2022-04-25');
INSERT INTO GG_Payment VALUES ('KPFFP456','N9E1H5K6','U000018','DirectDebit','Approved','2022-05-05');
INSERT INTO GG_Payment VALUES ('MQDQD579','P8L9N2J5','U000018','DirectDebit','Approved','2022-05-06');
INSERT INTO GG_Payment VALUES ('JZNZN786','J2P8K6N5','U000018','DirectDebit','Approved','2022-05-12');
INSERT INTO GG_Payment VALUES ('HZBZB812','J2N9D9L4','U000021','PayPal','Approved','2022-05-26');
INSERT INTO GG_Payment VALUES ('KTPTP147','K6P8H7E1','U000021','PayPal','Approved','2022-06-02');
INSERT INTO GG_Payment VALUES ('YJNJN917','M5J2N9F5','U000030','DirectDebit','Approved','2022-06-10');
INSERT INTO GG_Payment VALUES ('LBFBF287','N2E1H7L4','U000030','DirectDebit','Approved','2022-06-11');
INSERT INTO GG_Payment VALUES ('HSGSG521','K6M5Q1D9','U000002','DirectDebit','Approved','2022-06-14');
INSERT INTO GG_Payment VALUES ('TJSJS705','Q1H7N9K6','U000002','DirectDebit','Approved','2022-06-15');
INSERT INTO GG_Payment VALUES ('QXFXF114','L4F5M5J2','U000002','DirectDebit','Approved','2022-06-21');
INSERT INTO GG_Payment VALUES ('PBDBD632','J2N2P8M5','U000016','DirectDebit','Approved','2022-06-22');
INSERT INTO GG_Payment VALUES ('YHBHB864','K6F5D9N2','U000021','PayPal','Approved','2022-07-02');
INSERT INTO GG_Payment VALUES ('FGPGP267','M5P8H7Q1','U000021','PayPal','Approved','2022-07-03');
INSERT INTO GG_Payment VALUES ('XHCHC925','Q1L4E1N9','U000021','PayPal','Approved','2022-07-09');
INSERT INTO GG_Payment VALUES ('DSKSK894','E1H7F5K6','U000025','DirectDebit','Approved','2022-07-12');
INSERT INTO GG_Payment VALUES ('NVTVT449','N9M5D9J2','U000025','DirectDebit','Approved','2022-07-13');
INSERT INTO GG_Payment VALUES ('MQRQR471','K6J2Q1N9','U000025','DirectDebit','Approved','2022-07-19');
INSERT INTO GG_Payment VALUES ('ZWFWF183','H7P8K6N9','U000021','DirectDebit','Approved','2022-08-02');
INSERT INTO GG_Payment VALUES ('LYRYR566','L4K6P8H7','U000018','DirectDebit','Approved','2022-08-09');
INSERT INTO GG_Payment VALUES ('NKMKM283','D9J2M5N9','U000018','DirectDebit','Approved','2022-08-16');
INSERT INTO GG_Payment VALUES ('VDGDG527','F5L4E1H7','U000012','PayPal','Approved','2022-09-08');
INSERT INTO GG_Payment VALUES ('WQSQS349','J2L4F5P8','U000023','DirectDebit','Approved','2022-09-27');
INSERT INTO GG_Payment VALUES ('BTDTD547','H7M5E1D9','U000023','DirectDebit','Approved','2022-09-29');
INSERT INTO GG_Payment VALUES ('JRTRT977','F5N9K6J2','U000029','DirectDebit','Approved','2022-10-21');
INSERT INTO GG_Payment VALUES ('CZPZP712','P8D9H7N2','U000029','DirectDebit','Approved','2022-10-28');
INSERT INTO GG_Payment VALUES ('XYJYJ245','K6Q1L4E1','U000012','DirectDebit','Approved','2022-11-11');
INSERT INTO GG_Payment VALUES ('FZBZB593','M5H7N9P8','U000012','DirectDebit','Approved','2022-11-12');
INSERT INTO GG_Payment VALUES ('PDBDB293','N2J2F5L4','U000019','DirectDebit','Approved','2022-11-19');
INSERT INTO GG_Payment VALUES ('SRLRL915','E1N9M5K6','U000019','DirectDebit','Approved','2022-11-26');
INSERT INTO GG_Payment VALUES ('KXBXB882','P8N9J2M5','U000012','PayPal','Approved','2022-12-17');
INSERT INTO GG_Payment VALUES ('GZPZP238','L4K6D9P8','U000014','DirectDebit','Pending','2022-12-26');
INSERT INTO GG_Payment VALUES ('MVDVD659','D9H7J2Q1','U000014','DirectDebit','Pending','2023-01-03');

INSERT INTO GG_Maintenance VALUES ('M001','V011','2021-11-23','Oil change',11394,45,NULL);
INSERT INTO GG_Maintenance VALUES ('M002','V018','2021-12-17','Oil change',95823,60,NULL);
INSERT INTO GG_Maintenance VALUES ('M003','V022','2022-01-31','Fluid replacement',25473,150,NULL);
INSERT INTO GG_Maintenance VALUES ('M004','V014','2022-03-06','Battery check',13538,25,NULL);
INSERT INTO GG_Maintenance VALUES ('M005','V004','2022-03-18','Oil change',67283,50,NULL);
INSERT INTO GG_Maintenance VALUES ('M006','V011','2022-04-02','Brake inspection',11754,50,'M001');
INSERT INTO GG_Maintenance VALUES ('M007','V002','2022-04-08','Alignment check',11134,120,NULL);
INSERT INTO GG_Maintenance VALUES ('M008','V015','2022-05-14','Oil change',99857,45,NULL);
INSERT INTO GG_Maintenance VALUES ('M009','V018','2022-05-28','Brake inspection',98376,25,'M002');
INSERT INTO GG_Maintenance VALUES ('M010','V015','2022-11-14','Tire rotation',109676,35,'M008');