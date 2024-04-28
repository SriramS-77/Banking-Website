CREATE or REPLACE PROCEDURE getAccounts (
    var_username IN CHAR, cur OUT SYS_REFCURSOR
) AS 

var_user_id VARCHAR2(20);

BEGIN
    select user_id into var_user_id from users where username=var_username; 
    OPEN cur FOR
    SELECT account_name, account_id, account_type, balance, interest, minimum_balance, to_char(date_of_start, 'dd-MON-yyyy | hh24:mi:ss') FROM (
        (
            SELECT account_name, account_id, account_type, balance, date_of_start, branch_id
                FROM accounts
                NATURAL RIGHT OUTER JOIN account_holders 
                WHERE user_id=var_user_id
        )
        NATURAL LEFT OUTER JOIN account_constraint
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        RAISE_APPLICATION_ERROR(-20000, '$Invalid Username, Please Login Again.$');

END;
/