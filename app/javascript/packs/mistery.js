const checkboxclickmistery = () => {
  $(document).ready(function(){
    $(".mistery-choice").click(function(){
      if ($(this).parent().hasClass('active')) {
        $(this).parent().removeClass("active");
      } else {
        if($('.parent-class-mistery.active').length < 1) {
         $(this).parent().addClass("active");
        }else {
          // remove active from one of the previously selected cards
          let element = document.querySelector('.parent-class-mistery.active');
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
const checkonemistery = () => {
$('.check-mistery').on('change', function() {
   if($('.check-mistery:checked').length > 1) {
       $('.check-mistery:checked').forEach( (element) => {
          element.checked = false;
       });
       this.checked = true;
   }
});
}
export { checkboxclickmistery, checkonemistery };

