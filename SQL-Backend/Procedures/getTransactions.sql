CREATE or REPLACE PROCEDURE getTransactions (
    user_account_id IN CHAR, cur OUT SYS_REFCURSOR
) AS 

BEGIN
    OPEN cur FOR
    SELECT * FROM (
        (SELECT to_char(date_of_transaction, 'dd-MON-yyyy | hh24:mi:ss') as date_of_transaction, 'DEBIT' as type, sender_account_id, sender_account_name, receiver_account_id, receiver_account_name,
                (-1 * amount) as amount, status, recurring
                FROM transaction_view t1
                WHERE sender_account_id = user_account_id)
    UNION
        (SELECT to_char(date_of_transaction, 'dd-MON-yyyy | hh24:mi:ss') as date_of_transaction, 'CREDIT' as type, receiver_account_id, receiver_account_name, sender_account_id, sender_account_name,
                (1 * amount) as amount, status, recurring
                FROM transaction_view t2
                WHERE receiver_account_id = user_account_id)
                ) ORDER BY date_of_transaction DESC;
END;
/
