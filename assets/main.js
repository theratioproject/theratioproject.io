window.onscroll = function() {myFunction()};

var mainBar = document.getElementById("mainBar");
var sticky = mainBar.offsetTop;

function myFunction() {
  if (window.pageYOffset >= sticky) {
    mainBar.classList.add("sticky")
  } else {
    mainBar.classList.remove("sticky");
  }
}

function viewFullMenu() {
  var x = document.getElementById("mainBar");
  if (x.className === "navbar") {
    x.className += " responsive";
  } else {
    x.className = "navbar";
  }
}

var slideIndex = 0;
showSlides();

function showSlides() {
  var i;
  var slides = document.getElementsByClassName("mySlides");
  var dots = document.getElementsByClassName("dot");
  for (i = 0; i < slides.length; i++) {
    slides[i].style.display = "none";  
  }
  slideIndex++;
  if (slideIndex > slides.length) {slideIndex = 1}    
  for (i = 0; i < dots.length; i++) {
    dots[i].className = dots[i].className.replace(" active", "");
  }
  slides[slideIndex-1].style.display = "block"; 
  dots[slideIndex-1].className += " active";
  setTimeout(showSlides, 59000); // Change image every 2 seconds
}