// When the user scrolls down 20px from the top of the document, show the button
window.onscroll = function() {scrollFunction()};

function scrollFunction() {
  if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
    document.getElementById("myBtn").style.display = "block";
    document.getElementById("tripper_navbar").classList.add("navbar-scrolled");

  } else {
    document.getElementById("myBtn").style.display = "none";
    document.getElementById("tripper_navbar").classList.remove("navbar-scrolled");

  }
}

// When the user clicks on the button, scroll to the top of the document
function topFunction() {
  document.body.scrollTop = 0; // For Safari
  document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
}
const topbtn = document.querySelector('#myBtn');
topbtn.addEventListener("click", topFunction);

export { topFunction };
