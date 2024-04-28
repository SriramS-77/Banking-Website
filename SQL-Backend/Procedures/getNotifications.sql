CREATE OR REPLACE PROCEDURE getNotifications (
    var_username IN CHAR, cur OUT SYS_REFCURSOR 
) AS

var_user_id VARCHAR2(10);
branch_id NUMBER;
BEGIN
select user_id into var_user_id from users where username=var_username;
select branch_id into branch_id from account_holders natural join users natural join accounts where username=var_username fetch first row only;

open cur for select note
    from notifications
    where ref_id=branch_id AND domain=5 OR
          ref_id=var_user_id AND domain=1; 

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, '$You have no accounts, and hence no notifications.$'); 
END;
/