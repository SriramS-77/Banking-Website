create view transaction_view as ( 
    select date_of_transaction, sender_account_type, sender_account_name, sender_account_id,
    account_type as receiver_account_type, account_name as receiver_account_name, receiver_account_id,
    amount, status, recurring from
    (select date_of_transaction, account_type as sender_account_type, account_name as sender_account_name, sender_account_id,
    receiver_account_id, amount, status, recurring 
    from transactions t left outer join accounts s_a on t.sender_account_id=s_a.account_id) t1
    left outer join accounts r_a on t1.receiver_account_id=r_a.account_id
    );