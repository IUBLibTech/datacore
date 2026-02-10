// On page load, set values from storage
window.onload = function() {
    let contact_form_category = sessionStorage.getItem("contactFormCategory");
    if (contact_form_category) {
        document.getElementById("contact_form_category").value = contact_form_category;
    }
    let contact_form_name = sessionStorage.getItem("contactFormName");
    if (contact_form_name) {
        document.getElementById("contact_form_name").value = contact_form_name;
    }
    let contact_form_email = sessionStorage.getItem("contactFormEmail");
    if (contact_form_email) {
        document.getElementById("contact_form_email").value = contact_form_email;
    }
};

// When the dropdown value changes, saves it to storage
$( document ).ready(function() {
    $('#contact_form_category').on('change', function () {
        sessionStorage.setItem("contactFormCategory", $(this).val());
    })
    $('#contact_form_name').on('change', function () {
        sessionStorage.setItem("contactFormName", $(this).val());
    })
    $('#contact_form_email').on('change', function () {
        sessionStorage.setItem("contactFormEmail", $(this).val());
    })
})
