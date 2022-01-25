
#Create Database
create database Instacart;
use Instacart;

#SQL statements to Create Tables
create table aisles
	(aisle_id VARCHAR(3) NOT NULL,
	aisle VARCHAR(33),
	PRIMARY KEY (aisle_id) );
    
create table departments
	(department_id INT NOT NULL,
	department VARCHAR(15),
	PRIMARY KEY (department_id));
    
create table orders
	(order_id VARCHAR(8) NOT NULL,
	user_id VARCHAR(6),
    eval_set VARCHAR(5),
    order_number VARCHAR(3),
    order_dow CHAR(1),
    order_hour_of_day VARCHAR(2),
    days_since_prior VARCHAR(4),
	PRIMARY KEY (order_id));
    
create table products
	(product_id VARCHAR(5) NOT NULL,
	product_name VARCHAR(100) NOT NULL,
    aisle_id VARCHAR(5),
    department_id INT,
	PRIMARY KEY (product_id));
    
create table order_products_train
	(order_id VARCHAR(8),
	product_id VARCHAR(5),
    add_to_cart_order VARCHAR(5),
    reordered CHAR(1),
	PRIMARY KEY (order_id, product_id));
    
create table order_products__prior
	(order_id VARCHAR(8),
	product_id VARCHAR(5),
    add_to_cart_order VARCHAR(5),
    reordered CHAR(1),
	PRIMARY KEY (order_id, product_id));
 
 #Dropping tables
SET FOREIGN_KEY_CHECKS=0; DROP TABLE orders; SET FOREIGN_KEY_CHECKS=1;
 
#SQL statements to add foreign keys to tables
alter table products ADD constraint productid foreign key(aisle_id) references aisles(aisle_id);
alter table products ADD constraint depid foreign key(department_id) references departments(department_id); 

alter table order_products_train ADD constraint prodid_train foreign key(product_id) references products(product_id);
alter table order_products_train ADD constraint ordid_train foreign key(order_id) references orders(order_id);

alter table order_products__prior ADD constraint prodid_prior foreign key(product_id) references products(product_id);
alter table order_products__prior ADD constraint ordid_prior foreign key(order_id) references orders(order_id);

#SQL statements to create tables with foreign keys:
create table products
	(product_id VARCHAR(5) NOT NULL,
	product_name VARCHAR(100) NOT NULL,
    aisle_id VARCHAR(3),
    department_id INT,
	PRIMARY KEY (product_id), 
    foreign key (aisle_id) references aisles(aisle_id),
    foreign key (department_id) references departments(department_id));

create table order_products_train
	(order_id VARCHAR(8),
	product_id VARCHAR(5),
    add_to_cart_order VARCHAR(5),
    reordered CHAR(1),
	PRIMARY KEY (order_id, product_id), 
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id));
    
create table order_products__prior
	(order_id VARCHAR(8),
	product_id VARCHAR(5),
    add_to_cart_order VARCHAR(5),
    reordered CHAR(1),
	PRIMARY KEY (order_id, product_id), 
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id));
    
#SQL statements for loading data

#Aisles table
load data local infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/aisles.csv'
into table aisles
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
               ignore 1 rows;

#Departments table
load data local infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/departments.csv'
into table departments
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
               ignore 1 rows;

#Orders table
load data local infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
into table orders
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
               ignore 1 rows;

#Products table
load data local infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
into table products
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
               ignore 1 rows;

#order_products_train table
load data local infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_products__train.csv'
into table order_products_train
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
               ignore 1 rows;

#order_products__prior table
load data local infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_products__prior.csv'
into table order_products__prior
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
               ignore 1 rows;