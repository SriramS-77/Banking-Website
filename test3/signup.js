const name = document.getElementById("name")
const banking_name = document.getElementById("banking_name")
const email = document.getElementById("email")
const phone = document.getElementById("phone")
const dob = document.getElementById("dob")
const line_1 = document.getElementById("line_1")
const line_2 = document.getElementById("line_2")
const street = document.getElementById("street")
const city = document.getElementById("city")
const state = document.getElementById("state")
const pincode = document.getElementById("pincode")
const username = document.getElementById("username")
const password = document.getElementById("password")

const verifySignup = async () => {
    if(name.value.trim() === "" || banking_name.value.trim() === "" || email.value.trim() === "" || phone.value.trim() === "" ||
       street.value.trim() === "" || city.value.trim() === "" || state.value.trim() === "" || pincode.value.trim() === "" ||
       username.value.trim() === "" || password.value.trim() === ""){
        alert("Error! Fill all the Fields before Submitting!");
    }
    else{
        const res = await fetch("/signup", {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({'name': name.value, 'banking_name': banking_name.value, 'email': email.value, 'phone_no': phone.value, 'dob': dob.value,
                                        'address': {'line_1': line_1.value, 'line_2': line_2.value, 'street': street.value, 'city': city.value,
                                                    'state': state.value, 'pincode': pincode.value},
                                        'username': username.value, 'password': password.value})
        });
        const response = await res.json();
        if (response.Signup_Status === "Success"){
            localStorage.setItem("session_token", response.Session_Token);
            localStorage.setItem("username", username.value.trim());
            alert('Signed up successfully, Redirecting to main page...')
            window.location.href = "../test3/index3.html"
        }
        else {
            window.reload();
            alert(response.Message);
        }
    }
}