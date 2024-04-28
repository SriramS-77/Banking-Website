CREATE OR REPLACE TRIGGER commenceTransactions
AFTER LOGON ON DATABASE

DECLARE
cursor c is select * from transactions where status='pending';
sender_balance NUMBER;
sender_account_name VARCHAR2(20);
sender_account_type VARCHAR2(20);
sender_branch_id NUMBER;
sender_minimum_balance NUMBER;
BEGIN

FOR i IN c LOOP
    select balance, account_type, account_name, branch_id
        into sender_balance, sender_account_type, sender_account_name, sender_branch_id
        from accounts
        where account_id=i.sender_account_id;

    select minimum_balance into sender_minimum_balance
        from account_constraint
        where branch_id=sender_branch_id and account_type=sender_account_type;

    IF sender_balance - i.amount < sender_minimum_balance
    THEN
        insert into notifications values ('Your account '||sender_account_name||' did not have enough balance for transaction, '||i.transaction_id||', for amount of '||i.amount||'. Hence, the transaction failed.',
                                        1, i.sender_id);
        update transactions set status='failed' where transaction_id=i.transaction_id;
    ELSE
        insert into notifications values ('Your account '||sender_account_name||' successfully made the scheduled transaction, '||i.transaction_id||', for amount of '||i.amount||' to account '||i.receiver_account_id||' on '||i.date_of_transaction||'.',
                                        1, i.sender_id);
        update accounts set balance = balance + i.amount where account_id=i.receiver_account_id;
        update accounts set balance = balance - i.amount where account_id=i.sender_account_id;
        update transactions set status='success' where transaction_id=i.transaction_id;
    END IF;
END LOOP;
END;
/