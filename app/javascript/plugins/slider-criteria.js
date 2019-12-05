import { initRangeSlider } from '../components/sliders';

$('.criteria-slider').slick({
  autoplay:false,
  swipe: false,
  arrows:false,
  prevArrow:'<button type="button" class="slick-prev"></button>',
  nextArrow:'<button type="button" class="slick-next"></button>',
  centerMode:true,
  slidesToShow:1,
  dots: true,
  infinite: false,
  centerMode: false,
  cssEase: 'linear',
  dotted: false
});

const btns = document.querySelectorAll(".btn-next");

btns.forEach((btn) => {
  btn.addEventListener('click', () => {
    $('.criteria-slider').slick('slickNext');
    initRangeSlider();

  })
})
