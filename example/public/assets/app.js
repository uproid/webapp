const toggler = document.querySelector(".button-sidebar");
toggler.addEventListener("click",function(){
    document.querySelector("#sidebar").classList.toggle("collapsed");
});