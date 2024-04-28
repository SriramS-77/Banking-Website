CREATE OR REPLACE PROCEDURE createAccount
    (var_username IN CHAR, account_id in CHAR, var_account_type IN CHAR, account_name IN CHAR, balance IN NUMBER) AS

var_user_id users.user_id%type;
var_branch_id NUMERIC(3);
minimum_balance NUMBER;

BEGIN
    
select user_id into var_user_id from users where username=var_username;
select branch_id into var_branch_id from branch b inner join users u on b.city=u.city where user_id=var_user_id fetch first row only;  
select minimum_balance into minimum_balance from account_constraint where account_type=var_account_type and branch_id=var_branch_id;

IF minimum_balance > balance
THEN
    RAISE_APPLICATION_ERROR(-20000, '$Please insert an amount more than the minimum balance of '||minimum_balance||' rupees.$');
END IF;

insert into accounts values (account_id, var_account_type, account_name, balance, var_branch_id, SYSDATE);
insert into account_holders values (var_user_id, account_id, SYSDATE, '11111');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, '$Invalid username/password.$');
END;
/