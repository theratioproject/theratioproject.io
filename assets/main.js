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

