// On page load, set the dropdown value from storage
window.onload = function() {
    let savedValue = sessionStorage.getItem("contactFormCategory");
    if (savedValue) {
        document.getElementById("contact_form_category").value = savedValue;
    }
};

// When the dropdown value changes, saves it to storage
$( document ).ready(function() {
    $('#contact_form_category').on('change', function () {
        sessionStorage.setItem("contactFormCategory", $(this).val());
    })
})