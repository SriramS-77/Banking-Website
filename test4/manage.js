const logout = () => {
    localStorage.clear();
    window.location.replace('../test2/index2.html');
}

let rupee = new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
});


function click_create_hide_account_button () {
    let create_hide_account_button_element = document.getElementById("create-hide-button");
    let delete_hide_account_button_element = document.getElementById("delete-hide-button");
    if (create_hide_account_button_element.value === "Create Account"){
        if (delete_hide_account_button_element.value === "Hide Form") {
            click_delete_hide_account_button();
        }
        document.getElementById('create-account-form').style.display='block';
        create_hide_account_button_element.value = "Hide Form";
    }
    else {
        document.getElementById('create-account-form').style.display='none';
        create_hide_account_button_element.value = "Create Account";
    }
}

function click_delete_hide_account_button () {
    let create_hide_account_button_element = document.getElementById("create-hide-button");
    let delete_hide_account_button_element = document.getElementById("delete-hide-button");
    if (delete_hide_account_button_element.value === "Delete Account"){
        if (create_hide_account_button_element.value === "Hide Form") {
            click_create_hide_account_button();
        }
        document.getElementById('delete-account-form').style.display='block';
        delete_hide_account_button_element.value = "Hide Form";
    }
    else {
        document.getElementById('delete-account-form').style.display='none';
        delete_hide_account_button_element.value = "Delete Account";
    }
}

async function get_accounts () {
    console.log('Getting Accounts...');
    let tableElement = document.getElementById('account_table');
    let tableBodyElement = document.getElementById('account_body');
    let session_token = localStorage.getItem('session_token');
    let res = await fetch('/get_accounts', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({'session_token': session_token})
    });
    let response = await res.json();
    if (response.login_status === 'Failed') {
        alert(response.message);
        return;
    }
    let accounts = response.accounts;
    let accountRowElement=null, accountCellElement=null;
    accounts.forEach((row_ele) => {
        accountRowElement = document.createElement('tr');
        row_ele.forEach((ele) => {
            if (ele === row_ele[3] || ele === row_ele[5]) {
                ele = rupee.format(ele);
            }
            accountCellElement = document.createElement('td');
            accountCellElement.appendChild(new Text(ele));
            accountRowElement.appendChild(accountCellElement);
        });
        tableBodyElement.appendChild(accountRowElement);
    });
}

async function create_account () {
    let account_form = document.getElementById("create-account-form");
    let formData = new FormData(account_form);
    formData.append('session_token', localStorage.getItem('session_token'));
    let res = await fetch("/create_account", {method: "POST", body: formData});
    let response = await res.json()
    if (response.status === "Failed") {
        alert(response.message);
    }
    else {
        alert("Account created successfully!");
        document.getElementById("create-account-form").reset();
    }
}

async function delete_account() {
    let account_form = document.getElementById("delete-account-form");
    let formData = new FormData(account_form);
    formData.append('session_token', localStorage.getItem('session_token'));
    let res = await fetch("/delete_account", {method: "POST", body: formData});
    let response = await res.json()
    if (response.status === "Failed") {
        alert(response.message);
    }
    else if (response.status === "Success") {
        alert("Account deleted successfully!");
        let message = `Remaining balance of ${rupee.format(response.remaining_balance)} has been withdrawn from the account!`
        alert(message);
        document.location.reload();
        // document.getElementById("create-account-form").reset();
    }
    else {
        alert("Server Error. Please wait some time and try later.");
    }
}

window.addEventListener('DOMContentLoaded', get_accounts(), false);