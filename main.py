import asyncio
import random
import string
import json
import oracledb
from fastapi import FastAPI
from fastapi import Request
from fastapi.responses import *
from fastapi.staticfiles import StaticFiles
from hypercorn.asyncio import serve
from hypercorn.config import Config
from oracledb.exceptions import DatabaseError

month_mapping = {'01': 'JAN', '02': 'FEB', '03': 'MAR', '04': 'APR', '05': 'MAY', '06': 'JUN',
                 '07': 'JUL', '08': 'AUG', '09': 'SEP', '10': 'OCT', '11': 'NOV', '12': 'DEC'}

# with open("./SQL-Server/database.config.json") as json_file:
with open("../WebServer/SQL-Server/database.config.json") as json_file:
    database_config_json = json.load(json_file)
print(database_config_json)

connection = oracledb.connect(
    user=database_config_json["user"],
    password=database_config_json["password"],
    dsn=database_config_json["dsn"]
)

print("Connected to database.")
connection.autocommit = True
cursor = connection.cursor()

session = dict()

config = Config()
config.bind = ["localhost:8080"]
app = FastAPI()

def get_error_message(e):
    err = e.args[0]
    err_message = err.message.split("$")[1]
    print('\nDatabase error:', err.code)
    print(err_message)
    return err_message

def create_random_session_token():
    while True:
        session_token = ''.join(random.choices(string.digits, k=5))
        if session_token not in session.keys():
            break
    return session_token
def create_random_string(n: int):
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=n))

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/main")
async def root():
    return FileResponse("test2/index2.html", media_type="text/html")

def verifyLogin(username: str, password: str) -> (bool, str):
    try:
        cursor.callproc('verifyLogin', [username, password])

        cursor.execute(f"""SELECT phone from users where username = '{username}'""")
        phone = cursor.fetchone()[0]
    except DatabaseError as e:
        err = e.args[0]
        err_message = err.message.split("$")[1]
        print('\nDatabase error:', err.code)
        print(err_message)
        return False, {'Message': err_message}
    else:
        print('User verified')
        return True, {'Message': "Success", 'phone_number': phone}

def get_accounts(session_token: str):
    username = session[session_token]
    cursor.execute(f"""SELECT user_id from users WHERE username='{username}'""")
    user_id = cursor.fetchone()[0]
    cursor.execute(f"""SELECT account_id, account_name, account_type from account_holders natural join accounts WHERE user_id='{user_id}'""")
    accounts = cursor.fetchall()
    return accounts


def getUserInfo(session_token: str):
    username = session[session_token]
    cursor.execute(f"""SELECT username, name, banking_name, email, date_of_birth, phone, street, city, pincode FROM users WHERE username='{username}'""")
    info = cursor.fetchone()
    print(info)
    cursor.execute(f"""SELECT state from city_state where city='{info[7]}'""")
    state = cursor.fetchone()[0]
    return {'username': info[0], 'name': info[1], 'banking_name': info[2], 'email': info[3], 'dob': info[4].strftime("%m/%d/%Y"), 'phone': info[5],
            'address': f"{info[6]}, {info[7]}, {state}, {info[8]}"}

def signUp(data: dict):
    user_id: str = create_random_string(10)
    name, banking_name, email, phone_no, dob, address, username, password = data['name'], data['banking_name'], data['email'], data['phone_no'], data['dob'], data['address'], data['username'], data['password']
    line_1, line_2, street, city, state, pincode = address['line_1'], address['line_2'], address['street'], address['city'], address['state'], address['pincode']
    dob = dob.split('-')
    formatted_dob = '-'.join([dob[2], month_mapping[dob[1]], dob[0]])
    print('Formatted DOB: ', formatted_dob)
    # cursor.execute(f"""INSERT INTO user_info VALUES('{name}', '{email}', '{phone_no}', '{username}')""")
    try:
        cursor.callproc('createUser', [user_id, name, banking_name, phone_no, email,
                                                        line_1, line_2, street, city, state, int(pincode), formatted_dob,
                                                        username, password])
    except DatabaseError as e:
        return False, {'Signup_Status': 'Failed', 'Message': get_error_message(e)}
    else:
        return True, {'Signup_Status': 'Success'}

def get_user_accounts(data: dict):
    if 'session_token' not in data.keys() or data['session_token'] not in session.keys():
        return False, {'login_status': 'Failed', 'message': 'You session token expired. Please login again.'}
    username = session[data['session_token']]
    cur = cursor.var(oracledb.CURSOR)
    cursor.callproc('getAccounts', [username, cur])
    cur: oracledb.Cursor = cur.values[0]
    accounts = cur.fetchall()
    print(accounts)
    return True, {'login_status': 'Success', 'accounts': accounts}


def create_account(data: dict):
    if 'session_token' not in data.keys() or data['session_token'] not in session.keys():
        return False, {'login_status': 'Failed', 'message': 'You session token expired. Please login again.'}
    username = session[data['session_token']]
    try:
        account_id = create_random_string(8)
        cursor.callproc('createAccount', [username, account_id, data['account_type'], data['account_name'], data['balance']])
    except DatabaseError as e:
        return False, {'status': 'Failed', 'message': get_error_message(e)}
    else:
        return True, {'status': 'Success'}

def delete_account(data: dict):
    if 'session_token' not in data.keys() or data['session_token'] not in session.keys():
        return False, {'login_status': 'Failed', 'message': 'You session token expired. Please login again.'}
    username = session[data['session_token']]
    try:
        remaining_balance = cursor.callfunc('deleteAccount', float, [username, data['account_id'], data['account_name'], data['password']])
        print('sucessssssssssssssss')
        return True, {'status': 'Success', 'remaining_balance': remaining_balance}
    except DatabaseError as e:
        print('errorrrrrrrrrr')
        return False, {'status': 'Failed', 'message': get_error_message(e)}

def get_transactions(session_token, account_id):
    if session_token not in session.keys():
        return False, {'status': 'Failed', 'message': 'You session token expired. Please login again.'}
    username = session[session_token]
    cur = cursor.var(oracledb.CURSOR)
    if account_id.lower() == 'all':
        cursor.callproc('getAllTransactions', [username, cur])
    else:
        cursor.callproc('getTransactions', [account_id, cur])
    cur: oracledb.Cursor = cur.values[0]
    transactions = cur.fetchall()
    print(transactions)
    return True, {'status': 'Success', 'transactions': transactions}


def commit_transaction(data: dict):
    if 'session_token' not in data.keys() or data['session_token'] not in session.keys():
        return False, {'transaction_status': 'Failed', 'message': 'You session token expired. Please login again.'}
    username = session[data['session_token']]
    cursor.execute(f"""SELECT user_id from users WHERE username='{username}'""")
    user_id = cursor.fetchone()[0]
    transaction_id = create_random_string(10)
    try:
        transaction_date = data['date_of_transaction'].split('-')
        formatted_transaction_date = '-'.join([transaction_date[2], month_mapping[transaction_date[1]], transaction_date[0]])
        print(transaction_date, formatted_transaction_date)
        cursor.callproc('transact', [transaction_id, user_id, data['password'],
                                     data['sender_account_id'], data['receiver_account_id'],
                                     data['amount'], formatted_transaction_date, 0])
    except DatabaseError as e:
        return False, {'transaction_status': 'Failed', 'message': get_error_message(e)}
    else:
        return True, {'transaction_status': 'Success'}

def get_notifications(session_token: str):
    username = session[session_token]
    try:
        cur = cursor.var(oracledb.CURSOR)
        cursor.callproc('getNotifications', [username, cur])
        cur: oracledb.Cursor = cur.values[0]
        notifications = cur.fetchall()
        print(notifications)
    except DatabaseError as e:
        return False, {'status': 'Failed', 'message': get_error_message(e)}
    else:
        return True, {'status': 'Success', 'notifications': notifications}

@app.post("/login")
async def root(request: Request):
    data = await request.json()
    print(data['username'], data['password'])
    res, response = verifyLogin(data['username'], data['password'])
    if res:
        print('Success!!!!!!!!!!!!!!!')
        session_token = create_random_session_token()
        session[session_token] = data['username']
        print('Updated session tokens', session)
        response["Login_Status"] = "Success"
        response["Session_Token"] = session_token
        print('Sending to Client --->', response)
        return JSONResponse(content=response)
    else:
        print('Failed!!!!!!!!!!!!!!!')
        response["Login_Status"] = "Failed"
        return JSONResponse(content=response)

@app.post("/signup")
async def root(request: Request):
    data = await request.json()
    print(data)
    success, response = signUp(data)
    if success:
        session_token = create_random_session_token()
        session[session_token] = data['username']
        response['Session_Token'] = session_token
    return JSONResponse(content=response)

@app.post("/login_info")
async def root(request: Request):
    data = await request.json()
    session_token = data['session_token']
    print(session_token)
    if session_token in session.keys():
        user_info = getUserInfo(session_token)
        accounts = get_accounts(session_token)
        user_info['Login_Status'] = 'Success'
        user_info['accounts'] = accounts
        print('Login Info ---> ', user_info)
        return JSONResponse(content=user_info)
    else:
        return JSONResponse(content={'Login_Status': 'Failed', 'Message': 'Session timed out. Please login again.'})

@app.post("/get_accounts")
async def root(request: Request):
    data = await request.json()
    ret, response = get_user_accounts(data)
    return JSONResponse(content=response)

@app.post("/create_account")
async def root(request: Request):
    data = await request.form()
    print(dict(data))
    ret, response = create_account(dict(data))
    return JSONResponse(content=response)

@app.post("/delete_account")
async def root(request: Request):
    data = await request.form()
    print(dict(data))
    ret, response = delete_account(data)
    return JSONResponse(content=response)

@app.post("/get_transactions")
async def root(request: Request):
    data = await request.json()
    session_token = data['session_token']
    account_id = data['account_id']
    ret, response = get_transactions(session_token, account_id)
    return JSONResponse(content=response)

@app.post("/transact")
async def root(request: Request):
    data = await request.form()
    print(dict(data))
    ret, response = commit_transaction(dict(data))
    return JSONResponse(content=response)

@app.post("/get_notifications")
async def root(request: Request):
    data = await request.json()
    session_token = data['session_token']
    ret, response = get_notifications(session_token)
    return JSONResponse(content=response)

# app.mount("/Firebase", StaticFiles(directory="./Firebase"))
app.mount("/Firebase", StaticFiles(directory="../WebServer/Firebase"))
app.mount("/test2", StaticFiles(directory="./test2"))
app.mount("/test3", StaticFiles(directory="./test3"))
app.mount("/test4", StaticFiles(directory="./test4"))
app.mount("/res/Images", StaticFiles(directory="./res/Images"))

asyncio.run(serve(app, config))
