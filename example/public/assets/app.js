const toggler = document.querySelector(".button-sidebar");
toggler.addEventListener("click",function(){
    
    document.querySelector("#sidebar").classList.toggle("collapsed");

});

window.addEventListener('resize', checkScreenSize);
function checkScreenSize(isFirstLoad = false) {
    const element = document.getElementById("sidebar");
    if (window.innerWidth < 750) {
        if(isFirstLoad){
            element.style.display = "none";
            setTimeout(() => {
                element.style.display = "block";
            },500);
        }
        document.querySelector("#sidebar").classList.add("collapsed"); 
    } else {
        document.querySelector("#sidebar").classList.remove("collapsed"); 
    }
}

checkScreenSize(true);