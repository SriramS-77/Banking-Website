CREATE or REPLACE PROCEDURE getAllTransactions (
    var_username IN CHAR, cur OUT SYS_REFCURSOR
) AS

var_user_id VARCHAR2(20);
BEGIN
    SELECT user_id INTO var_user_id FROM users WHERE username = var_username;

    OPEN cur FOR
    SELECT * FROM (
        (SELECT to_char(date_of_transaction, 'dd-MON-yyyy | hh24:mi:ss') as date_of_transaction, 'DEBIT' as type, sender_account_id, sender_account_name, receiver_account_id, receiver_account_name,
                    (-1 * amount) as amount, status, recurring
        FROM transaction_view t INNER JOIN account_holders a
            ON t.sender_account_id = a.account_id
        WHERE user_id = var_user_id)
    UNION
        (SELECT to_char(date_of_transaction, 'dd-MON-yyyy | hh24:mi:ss') as date_of_transaction, 'CREDIT' as type, sender_account_id, sender_account_name, receiver_account_id, receiver_account_name,
                    (1 * amount) as amount, status, recurring
        FROM transaction_view t INNER JOIN account_holders a
            ON t.receiver_account_id = a.account_id
        WHERE user_id = var_user_id)
                ) ORDER BY date_of_transaction DESC;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, '$Invalid user. Please try again.$');
END;
/
