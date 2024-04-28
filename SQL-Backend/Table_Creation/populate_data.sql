insert into city_state values ('Chennai', 'Tamil Nadu');
insert into city_state values ('Bangalore', 'Karnataka');
insert into city_state values ('Kolkata', 'West Bengal');
insert into city_state values ('Hyderabad', 'Telangana');
insert into city_state values ('Thiruvananthapuram', 'Kerala');
insert into city_state values ('Mumbai', 'Maharashtra');
insert into city_state values ('Madurai', 'Tamil Nadu');

insert into branch values (101, 'ABC', 'Chennai');
insert into branch values (102, 'EFG', 'Kolkata');
insert into branch values (103, 'HIJ', 'Mumbai');
insert into branch values (104, 'LMN', 'Hyderabad');
insert into branch values (105, 'OPQ', 'Thiruvananthapuram');
insert into branch values (106, 'RST', 'Bangalore');
insert into branch values (107, 'UVW', 'Madurai');

insert into account_constraint values (101, 'Savings',  6.02, 5050);
insert into account_constraint values (101, 'Funds',    8.04, 50000);
insert into account_constraint values (101, 'Business', 4.01, 1000);
insert into account_constraint values (102, 'Savings',  6.24, 6000);
insert into account_constraint values (102, 'Funds',    8.23, 45000);
insert into account_constraint values (102, 'Business', 3.89, 0);
insert into account_constraint values (103, 'Savings',  5.98, 5000);
insert into account_constraint values (103, 'Funds',    8.11, 48000);
insert into account_constraint values (103, 'Business', 3.95, 0);
insert into account_constraint values (104, 'Savings',  6.32, 5500);
insert into account_constraint values (104, 'Funds',    8.22, 60000);
insert into account_constraint values (104, 'Business', 4.04, 2000);
insert into account_constraint values (105, 'Savings',  6.23, 5750);
insert into account_constraint values (105, 'Funds',    8.13, 55000);
insert into account_constraint values (105, 'Business', 4.11, 1500);
insert into account_constraint values (106, 'Savings',  6.09, 6400);
insert into account_constraint values (106, 'Funds',    8.15, 50000);
insert into account_constraint values (106, 'Business', 4.08, 0);
insert into account_constraint values (107, 'Savings',  7.09, 7400);
insert into account_constraint values (107, 'Funds',    7.15, 40000);
insert into account_constraint values (107, 'Business', 5.08, 0);

insert into users values ('iprwirns77', 'Sriram Sunderrajan', 'SriramS77', 0123456789, 'sriram12345@gmail.com',
                        'Plot 35', 'Laksh Sagar', 'Swami Theru', 'Chennai', 666666,
                        '09-JUL-2004', '17-APR-2024', 'sriram', 'sriram');
insert into users values ('polkgthrye', 'Akshay Kanna', 'Pilot Idiot', 8585858585, 'akshay@gmail.com',
                        'Plot 25', 'Sagar Road', 'Rahul street', 'Madurai', 625009,
                        '11-MAY-2005', '18-APR-2024', 'akshay', 'akshay');

insert into accounts values ('1234qwer', 'Savings', 'Sriram77-Savings', 30000, 101, '17-APR-2024');
insert into accounts values ('qwer1234', 'Savings', 'Pilot-Savings', 20000, 107, '18-APR-2024');

insert into account_holders values ('iprwirns77', '1234qwer', '17-APR-2024', '11111');
insert into account_holders values ('polkgthrye', 'qwer1234', '18-APR-2024', '11111');

insert into transactions values ('ierhdloedy', 'iprwirns77', '1234qwer', 'qwer1234', 500, 'success', '18-APR-2024', 0);
