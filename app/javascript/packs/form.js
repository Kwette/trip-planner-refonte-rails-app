/*const checkboxclic = () => {
document.querySelectorAll(".activity-choice").forEach((element) =>{
  element.addEventListener("click", (event) => {
    event.currentTarget.classList.toggle("active");
  });
});
}*/

const checkboxclickculture = () => {
  $(document).ready(function(){
    $(".acti-culture").click(function(){
        if ($(this).parent().hasClass('active')) {
           $(this).parent().removeClass("active");
       } else {
        if($('.parent-class-culture.active').length < 2) {
         $(this).parent().addClass("active");
        } else {
          // remove active from one of the previously selected cards
          let element = document.querySelectorAll('.parent-class-culture.active')[1];
          if (element){
            $(element).removeClass("active");
            $(element).find("input[type=checkbox]").prop("checked", false);
            $(this).parent().addClass("active");
          }
        }
      }
    });
  });
}
const checkboxclicksport = () => {
  $(document).ready(function(){
    $(".acti-sport").click(function(){
      if ($(this).parent().hasClass('active')) {
        $(this).parent().removeClass("active");
      } else {
        if($('.parent-class-sport.active').length < 2) {
         $(this).parent().addClass("active");
        } else {
          // remove active from one of the previously selected cards
          let element = document.querySelectorAll('.parent-class-sport.active')[1];
          if (element){
            $(element).removeClass("active");
            $(element).find("input[type=checkbox]").prop("checked", false);
            $(this).parent().addClass("active");
          }
        }
      }
    });
  });
}
const checkboxclickvisit = () => {
  $(document).ready(function(){
    $(".acti-visit").click(function(){
      if ($(this).parent().hasClass('active')) {
        $(this).parent().removeClass("active");
      } else {
        if($('.parent-class-visit.active').length < 2) {
         $(this).parent().addClass("active");
        } else {
          // remove active from one of the previously selected cards
          let element = document.querySelectorAll('.parent-class-visit.active')[1];
          if (element){
            $(element).removeClass("active");
            $(element).find("input[type=checkbox]").prop("checked", false);
            $(this).parent().addClass("active");
          }
        }
      }
    });
  });
}
const checkboxclickbeach = () => {
  $(document).ready(function(){
    $(".acti-beach").click(function(){
      if ($(this).parent().hasClass('active')) {
        $(this).parent().removeClass("active");
      } else {
        if($('.parent-class-beach.active').length < 2) {
         $(this).parent().addClass("active");
        } else {
          // remove active from one of the previously selected cards
          let element = document.querySelectorAll('.parent-class-beach.active')[1];
          if (element){
            $(element).removeClass("active");
            $(element).find("input[type=checkbox]").prop("checked", false);
            $(this).parent().addClass("active");
          }
        }
      }
    });
  });
}

const checktwoculture = () => {
$('.check-culture').on('change', function() {
   if($('.check-culture:checked').length > 2) {
       this.checked = false;
   }
});
}
const checktwosport = () => {
$('.check-sport').on('change', function() {
   if($('.check-sport:checked').length > 2) {
       this.checked = false;
   }
});
}
const checktwovisit = () => {
$('.check-visit').on('change', function() {
   if($('.check-visit:checked').length > 2) {
       this.checked = false;
   }
});
}
const checktwobeach = () => {
$('.check-beach').on('change', function() {
   if($('.check-beach:checked').length > 2) {
       this.checked = false;
   }
});
}


export { checkboxclickculture, checkboxclickbeach, checkboxclickvisit, checkboxclicksport, checktwoculture, checktwosport, checktwovisit, checktwobeach };

