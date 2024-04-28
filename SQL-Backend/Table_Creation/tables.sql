drop table transactions;
drop table account_holders;
drop table users;
drop table accounts;
drop table account_constraint;
drop table branch;
drop table notifications;

drop table city_state;

create table city_state (city VARCHAR2(20), state VARCHAR2(20),
                    PRIMARY KEY (city));

create table branch (branch_id NUMBER(3), branch_name VARCHAR2(20), city VARCHAR2(20),
                    PRIMARY KEY (branch_id),
                    FOREIGN KEY (city) REFERENCES city_state);

create table account_constraint (branch_id NUMBER(3), account_type VARCHAR2(10), interest NUMBER(4,2),
                    minimum_balance NUMBER(8,2),
                    FOREIGN KEY (branch_id) REFERENCES branch);

create table users (user_id VARCHAR2(10), name VARCHAR2(30) not null, banking_name VARCHAR2(30) not null, phone NUMBER(10) not null, email VARCHAR2(30) not null, 
                    line_1 VARCHAR2(20), line_2 VARCHAR2(20), street VARCHAR2(20), city VARCHAR2(20), pincode NUMBER(6),
                    date_of_birth DATE, date_of_joining DATE, username VARCHAR2(20) not null, password VARCHAR2(20) not null,
                    PRIMARY KEY (user_id),
                    FOREIGN KEY (city) REFERENCES city_state);

create table accounts (account_id VARCHAR2(8), account_type VARCHAR2(10) not null, account_name VARCHAR2(20), balance NUMBER(10,2) not null,
                    branch_id NUMBER(3) not null, date_of_start DATE,
                    PRIMARY KEY (account_id));

create table account_holders (user_id VARCHAR2(10) not null, account_id VARCHAR2(8) not null, date_of_joining DATE, privilege CHAR(10),
                    FOREIGN KEY (user_id) REFERENCES users, FOREIGN KEY (account_id) REFERENCES accounts);

create table transactions (transaction_id VARCHAR2(10), sender_id VARCHAR2(10) not null, sender_account_id VARCHAR2(8), receiver_account_id VARCHAR2(8),
                    amount NUMBER(8,2) not null, status VARCHAR2(10) not null, date_of_transaction DATE, recurring NUMBER(1),
                    PRIMARY KEY (transaction_id),
                    FOREIGN KEY (sender_id) REFERENCES users,
                    FOREIGN KEY (sender_account_id) REFERENCES accounts ON DELETE SET NULL,
                    FOREIGN KEY (receiver_account_id) REFERENCES accounts ON DELETE SET NULL);

create table notifications (note VARCHAR2(1000), domain NUMERIC(2), ref_id VARCHAR2(10),
                    PRIMARY KEY (note, domain, ref_id));