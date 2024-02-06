# Car Rental Service Database Design 🚘 

This project is dedicated to developing a sophisticated database tailored for Go Get, an Australian car rental service. The database encompasses crucial aspects such as user details, vehicle information, booking records, invoices, and maintenance services. 

By leveraging PostgreSQL, the aim is to enhance data management efficiency, enabling seamless insights into car models and booking patterns. This initiative aligns with optimising overall operational performance and facilitating informed decision-making within the framework of Go Get Car Rental Service.

## ⚙️ Build Steps

- Formulated ERD capturing user, vehicle, booking, invoice, and maintenance service relationships.
- Created a PostgreSQL database with 10 tables, 3 views, keys, and data integrity constraints.
- Optimised query performance through indexing and query optimisation.
- Utilised SQL queries for insights and report generation on car models and booking patterns.


## 🎞️ Demo & Snippets
### 1. ERD
<div style="text-align: justify;">
Prior to constructing the PostgreSQL database, I meticulously crafted an Entity-Relationship Diagram (ERD) to comprehensively encapsulate entities, their attributes, and intricate relationships. The ERD incorporates primary keys for unique entity identification and employs foreign keys to delineate associations between tables. This strategic design facilitates the establishment of a robust and interlinked database structure.
</div>

![ERD](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/ERD.png)

### 2. Tables and views
The database is constructed with 10 tables and 3 views.
### View 1: Booking Details
![alt text](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/View1.png)
![alt text](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/View1.png)

### View 2: Booking Details
![alt text](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/View2.png)

### View 3: Plan Type 
![alt text](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/View3.png)

### 3. Check Statements
To ensure data integrity, I used the CHECK constraints to limit the range of vvalues that can 
he CHECK constraint is used to limit the range of values that can be inserted into a column. It ensures that the values in a column meet specific conditions defined by the user.

![alt text](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/Check.png)

### 3. Queries
To retrieve certain insights from the database, I have conducted different types of queries as follow.

![Query1](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/Query1.png)
![Query2](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/Query2.png)
![Query3](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/Query3.png)
![Query4](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/Query4.png)
![Query5](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/Query5.png)
![Query6](https://github.com/hnhaa/Go-Get-Database-Design/blob/main/Images/Query6.png)
