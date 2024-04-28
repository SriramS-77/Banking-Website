let rupee = new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
});

const logout = () => {
    localStorage.clear();
    window.location.replace('../test2/index2.html');
}

async function get_notification(){
    let res = await fetch("/get_notifications", {
        method: "POST",
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({'session_token': localStorage.getItem('session_token')})
    });
    let response = await res.json();
    if (response.status === 'Failed') {
        alert(response.message);
    }
    let notifications = response.notifications;
    if (notifications[0] === undefined) {
        alert('No unread notifications.');
        return;
    }
    // console.log(notifications.length, notifications[0].length);
    notifications.forEach((row_ele) => {
        alert(row_ele[0]);
    });
}

function goto_account() {
    let selectElement = document.getElementById("accounts");
    if (selectElement.value === 'all') {
        return;
    }
    localStorage.setItem('account_id', selectElement.value);
    console.log('Account ID ', selectElement.value);
    window.location.href = '../test4/account.html';
}

async function manage_accounts() {
    window.location.href = '../test4/manage.html';
}

window.onload = async function(){
    const name = document.getElementById('name');
    const banking_name = document.getElementById('banking_name');
    const email = document.getElementById('email');
    const phone = document.getElementById('phone');
    const address = document.getElementById('address');
    const username = document.getElementById('username');

    let session_token = localStorage.getItem('session_token');
    const res = await fetch("/login_info", {
        method: "POST",
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({'session_token': session_token})
    });
    const a = await res.json();
    if (a.Login_Status === "Failed") {
        alert(a.Message);
        return;
    }
    username.innerHTML = a.username;
    name.innerHTML = a.name;
    banking_name.innerHTML = a.banking_name
    email.innerHTML = a.email;
    phone.innerHTML = a.phone;
    address.innerHTML = a.address;

    let accounts = a.accounts;
    let selectAccountElement = document.getElementById('accounts');
    let accountOptionElement;
    for (let i=0; i<accounts.length; i++) {
        accountOptionElement = new Option(accounts[i][1].concat(" | ", accounts[i][0].concat(": ", accounts[i][2]) ), accounts[i][0]);
        selectAccountElement.appendChild(accountOptionElement);
        // selectAccountElement.add(accountOptionElement, undefined);
    }

    let tableElement = document.getElementById("transaction_table");
    for (let i=0; i<tableElement.children.length; i++) {
        let childElement = tableElement.children[i];
        for (let j = 0; j<childElement.children.length; j++) {
            let child = childElement.children[j];
            for (let k=0; k<child.children.length; k++) {
                child.children[k].classList.add('transaction');
            }
        }
    }
    getAccount();
}

// const tableElement = document.getElementById("transaction_table");
// const selectAccountElement = document.getElementById('accounts');
// selectAccountElement.addEventListener("click", getAccount);

const getAccount = async () => {
    let selectAccountElement = document.getElementById('accounts');
    let account = selectAccountElement.value;
    if (account === 'all') {
        console.log('ALLLLLLL');
    }
    let tableElement = document.getElementById("transaction_table");
    let transactionBodyElement = document.getElementById('transaction_body')
    if (transactionBodyElement != null) {
        tableElement.removeChild(transactionBodyElement);
    }
    transactionBodyElement = document.createElement("tbody");
    transactionBodyElement.setAttribute("id", "transaction_body");
    tableElement.appendChild(transactionBodyElement);
    let session_token = localStorage.getItem('session_token');
    let res = await fetch("/get_transactions", {method: "POST",
                                    headers: {'Content-Type': 'application/json'},
                                    body: JSON.stringify({'session_token': session_token, 'account_id': account})});
    let response = await res.json();
    let transactions = response.transactions;
    let rowElement; let dataElement;
    transactions.forEach((row_ele) => {
        rowElement = document.createElement("tr");
        row_ele.forEach((ele) => {
            if (ele === row_ele[6]) {
                ele = rupee.format(ele);
            }
            dataElement = document.createElement('td');
            dataElement.appendChild(new Text(ele));
            rowElement.appendChild(dataElement);
            if (ele === "DEBIT") {
                rowElement.classList.add("debit");
            }
            else if (ele === "CREDIT") {
                rowElement.classList.add("credit");
            }
        });
        transactionBodyElement.appendChild(rowElement);
    });
}

window.addEventListener("DOMContentLoaded", (event) => {
    let selectElement = document.getElementById('accounts');
    if (selectElement)
        selectElement.addEventListener("change", getAccount, false);
})
