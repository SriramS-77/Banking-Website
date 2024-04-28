let receiver_account_id_element = document.getElementById("receiver-account-id");
let amount_element = document.getElementById("amount");
let password_element = document.getElementById("password");

async function submit_transaction () {
    if (receiver_account_id_element.value.trim() === "" ||
        amount_element.value.trim() === "" ||
        password_element.value.trim() === "") {
        alert("Please fill all the fields!");
        return;
    }
    else if (Number.parseInt(amount_element.value) <= 0) {
        alert("Please input a proper amount to send.");
        return;
    }
    let transaction_form = document.getElementById("transact-form");
    const formData = new FormData(transaction_form);
    formData.append('session_token', localStorage.getItem('session_token'));
    formData.append('sender_account_id', localStorage.getItem('account_id'));
    let res = await fetch("/transact", {
        method: "POST",
        // headers: {'Content-Type': 'multipart/form-data'},
        body: formData
    })
    let response = await res.json()
    alert(`Transaction: ${response.transaction_status}`);
    if (response.transaction_status === "Failed") {
        alert(response.message);
    }
}

window.addEventListener('load', (event) => {
    let date_element = document.getElementById("transaction_date_element");
    let date_value = new Date().toISOString().split("T")[0];
    date_element.value = date_value;
    date_element.min = date_value;
})