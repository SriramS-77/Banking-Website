CREATE OR REPLACE PROCEDURE transact
    (transaction_id IN CHAR, sender_id IN CHAR, var_password IN CHAR, sender_account_id IN CHAR, receiver_account_id IN CHAR,
    amount IN NUMBER, date_of_transaction DATE, recurring IN NUMBER) AS

cur_date DATE;
actual_password VARCHAR2(20);
var_minimum_balance NUMBER;
var_branch_id NUMBER;
var_account_type VARCHAR2(10);
remaining_balance NUMBER;
receiver_exists BOOLEAN := FALSE;

cursor cur_users is select account_id from accounts;

BEGIN
select CURRENT_DATE into cur_date from dual;

IF sender_account_id = receiver_account_id
THEN
   RAISE_APPLICATION_ERROR(-20000, '$You cannot send money to the same account.$');
END IF;

FOR cur_val in cur_users
LOOP
    IF cur_val.account_id = receiver_account_id THEN receiver_exists := TRUE;
    END IF;
END LOOP;

IF receiver_exists = FALSE
THEN
   RAISE_APPLICATION_ERROR(-20000, '$Receiver account does not exist.$');
END IF;

select password into actual_password from users where user_id = sender_id;

IF var_password <> actual_password 
THEN
   RAISE_APPLICATION_ERROR(-20000, '$Incorrect password!$');
END IF;

select branch_id, account_type, balance into var_branch_id, var_account_type, remaining_balance from accounts where account_id=sender_account_id;

select minimum_balance into var_minimum_balance from account_constraint where branch_id=var_branch_id and account_type=var_account_type;

IF remaining_balance - amount < var_minimum_balance THEN
    RAISE_APPLICATION_ERROR(-20000, '$Insufficient balance in Account$');

ELSIF date_of_transaction <= cur_date THEN
    update accounts set balance = balance + amount where account_id=receiver_account_id;
    update accounts set balance = balance - amount where account_id=sender_account_id; 
    
    insert into transactions values (transaction_id, sender_id, sender_account_id, receiver_account_id, amount,
                                     'success', cur_date, recurring);

ELSE 
    insert into transactions values (transaction_id, sender_id, sender_account_id, receiver_account_id, amount,
                                     'pending', date_of_transaction, recurring);
END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, '$Invalid account/user info.$');
END;
/