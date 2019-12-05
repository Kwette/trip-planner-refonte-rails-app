import "rangeslider.js";
// import "rangeslider.js/dist/rangeslider.css";

function findGradientColor() {
  const newColor = {};
  /*console.log(this.$element[0].closest("div").querySelector(".rangeslider__fill"));*/
  const el = this.$element[0].closest("div");
  const rangeFill = el.querySelector(".rangeslider__fill");
  /*console.log(rangeFill);*/

  const blue = {r:84, g:72, b:255}
  const red = {r:63, g:207, b:142}

  function findPercent() {
    const range = el.querySelector(".rangeslider").offsetWidth;
      /*console.log(range);*/
    const size = el.querySelector(".rangeslider__fill").offsetWidth;
     /* console.log(size);*/
    return size / range * 100;
  };

  const newValue = (red, blue) => {
    return(blue + Math.round((red - blue) * findPercent() / 100));
  };

  const colorHexa = (newValue) => {
    newValue = Math.min(newValue, 255);   // not more than 255
    newValue = Math.max(newValue, 0);     // not less than 0
    const str = newValue.toString(16);
    if (str.length < 2) {
        str = "0" + str;
    }
    return(str);
  };


  newColor.r = newValue(red.r, blue.r);
  newColor.g = newValue(red.g, blue.g);
  newColor.b = newValue(red.b, blue.b);
  newColor.cssColor = "#" + colorHexa(newColor.r) + colorHexa(newColor.g) + colorHexa(newColor.b)  ;

  rangeFill.style.backgroundColor = newColor.cssColor;
};

const initRangeSlider = () => {

  $('input[type="range"]').rangeslider({
    polyfill: false,
    onSlide: findGradientColor
  });
};

export { initRangeSlider };
