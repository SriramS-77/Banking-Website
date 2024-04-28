CREATE OR REPLACE TRIGGER notification_trigger
after update of interest, minimum_balance OR delete on account_constraint

FOR EACH ROW
BEGIN
CASE
    WHEN UPDATING ('interest')
    THEN
        insert into notifications values ('Pay Attention!
'||'Your branch' || chr(39) || 's interest rate for account type: ' || :new.account_type || ' is changing from ' || :old.interest || ' to ' || :new.interest || ' % per annum.',
                                            5, :new.branch_id);
    WHEN UPDATING ('minimum_balance')
    THEN
        insert into notifications values ('Pay Attention!
'||'Your branch' || chr(39) || 's minimum balance for account type: ' || :new.account_type || ' is changing from ' || :old.minimum_balance || ' to ' || :new.minimum_balance || ' rupees.',
                                            5, :new.branch_id);
    WHEN DELETING
    THEN
        insert into notifications values ('Pay Attention!
'||'Your branch is no longer providing service for accounts of type: ' || :old.account_type || '\nPlease move it elsewhere.',
                                            5, :old.branch_id);

END CASE;
END;
/