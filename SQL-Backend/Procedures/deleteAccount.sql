CREATE OR REPLACE FUNCTION deleteAccount
    (var_username IN CHAR, var_account_id IN CHAR, account_name IN CHAR, password IN CHAR)
    RETURN NUMBER AS

var_user_id users.user_id%type;
var_balance NUMBER;
var_account_name VARCHAR2(20);
var_password VARCHAR2(20);

BEGIN
    
select user_id, password into var_user_id, var_password from users where username=var_username;
select balance, account_name into var_balance, var_account_name from accounts where account_id=var_account_id;

IF var_account_name <> account_name
THEN
     RAISE_APPLICATION_ERROR(-20000, '$Account ID and name do not match. Please try again.$');

ELSIF var_password <> password
THEN
    RAISE_APPLICATION_ERROR(-20000, '$Incorrect Password. Please try again.$');

END IF;

delete from account_holders where account_id=var_account_id and user_id=var_user_id;
delete from accounts where account_id=var_account_id;

RETURN var_balance;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, '$Invalid account. Please try again.$');
END;
/