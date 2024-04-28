import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.11.0/firebase-app.js';
import { getAuth, RecaptchaVerifier, signInWithPhoneNumber } from 'https://www.gstatic.com/firebasejs/10.11.0/firebase-auth.js';

const username = document.getElementById("username")
const password = document.getElementById("password")
let otp_tries = 0;

const firebaseConfig = await fetch("../Firebase/firebase.config.json")
    .then((response) => response.json());

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

function onCaptchaVerify () {
    if (! window.recaptchaVerifier) {
        let recaptcha_element = document.getElementById("recaptcha-container");
        window.recaptchaVerifier = new RecaptchaVerifier(auth, recaptcha_element, {
          'size': 'invisible',
          'callback': (response) => {
            // reCAPTCHA solved, allow signInWithPhoneNumber.
            signInWithPhoneNumber(auth, '+91-' + localStorage.getItem('phone_number'), window.recaptchaVerifier).then(
                (confirmation_result) => {
                    console.log(confirmation_result);
                    alert('SMS sent successfully to your phone number');
                    let otp_div_element = document.getElementById("otp-div");
                    otp_div_element.style.display = 'block';
                    window.confirmation_result = confirmation_result;
                }).catch((error) => {
                    console.log(error);
                    alert('Error, SMS not sent. Please try again.');
                    window.recaptchaVerifier = null;
                    onCaptchaVerify();
            });
          },
          'expired-callback': () => {
            // Response expired. Ask user to solve reCAPTCHA again.
            localStorage.clear();
            alert('Time expired. Reloading page...');
            window.location.reload();
          }
        });
        if (window.recaptchaVerifier){
            window.recaptchaVerifier.verify();
        }
    }
}

function verifyOTP () {
    let otp_input_element = document.getElementById("otp-input");
    let code = otp_input_element.value;
    code = Number.parseInt(code);
    console.log('OTP --->', code);
    window.confirmation_result.confirm(code).then((result) => {
        let user = result.user;
        alert('OTP correct!!!');
        console.log(user);
        successful_sign_in();
    }).catch((error) => {
        otp_tries++;
        if (otp_tries === 3) {
            localStorage.clear();
            alert("Invalid OTP! 3 Tries done! Reloading page...");
            window.location.reload();
        }
        else {
            alert(`Invalid OTP! ${3 - otp_tries} tries remaining.`);
        }
    });
}


let otp_input_element = document.getElementById('otp-input');
otp_input_element.addEventListener("keydown", function (e) {
    if (e.code === "Enter") {
        verifyOTP();
        console.log('Function called by pressing Enter key!!!');
    }
});


const successful_sign_in = () => {
    window.location.href = "../test3/index3.html";
}

const verifyLogin = async () => {
    if(username.value.trim() === "" || password.value.trim() === ""){
        alert("Error! Fill all the Fields before Submitting!");
    }
    else{
        const res = await fetch("/login", {
            method: "POST",
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({'username': username.value, 'password': password.value})
        });
        const a = await res.json();
        console.log(a.Login_Status);
        if (a.Login_Status === "Success"){
            localStorage.setItem("session_token", a.Session_Token);
            localStorage.setItem("phone_number", a.phone_number);
            localStorage.setItem("username", username.value.trim());
            console.log("Session Token: ", a.Session_Token);
            // onCaptchaVerify();
            successful_sign_in();
        }
        else{
            username.value = ""
            password.value = ""
            alert(a.Message);
        }
    }
}

const signUp = () => {
    window.location.href = "../test3/signup.html";
}

window.verifyOTP = verifyOTP;
window.verifyLogin = verifyLogin;
window.signUp = signUp;
