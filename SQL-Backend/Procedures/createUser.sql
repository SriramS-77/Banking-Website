CREATE OR REPLACE PROCEDURE createUser
    (user_id IN CHAR, name IN CHAR, banking_name IN CHAR, phone IN NUMBER, email IN CHAR,
    line_1 IN CHAR, line_2 IN CHAR, street IN CHAR, city IN CHAR, state IN CHAR, pincode IN NUMBER, date_of_birth IN DATE,
    username IN CHAR, password IN CHAR) AS

cur_date DATE;
city_recorded BOOLEAN := FALSE;
cursor cur is select city from city_state;
cursor cur_users is select username from users;

BEGIN
FOR cur_val in cur
LOOP
    IF cur_val.city=city THEN city_recorded := TRUE;
    END IF;
END LOOP;

IF city_recorded=FALSE THEN insert into city_state values (city, state);
END IF;

FOR cur_val in cur_users
LOOP
    IF cur_val.username = username THEN RAISE_APPLICATION_ERROR(-20000, '$Username is already taken.$');
    END IF;
END LOOP;

select CURRENT_DATE into cur_date from dual;

insert into users values (user_id, name, banking_name, phone, email, line_1, line_2, street, city, pincode, date_of_birth,
                        cur_date, username, password);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, '$Invalid username/password.$');
END;
/