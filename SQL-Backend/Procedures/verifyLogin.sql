CREATE OR REPLACE PROCEDURE verifyLogin
    (var_username IN CHAR, password IN CHAR) IS

actualPassword users.password%type;
BEGIN

select password into actualPassword from users where username=var_username;

IF password != actualPassword THEN
    RAISE_APPLICATION_ERROR(-20000, '$Invalid username/password.$');
ELSE
    DBMS_OUTPUT.PUT_LINE('Password and Username verified.');
END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, '$Invalid username/password.$');
END;
/