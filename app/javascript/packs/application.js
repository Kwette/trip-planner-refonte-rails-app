import "bootstrap";
import "slick-carousel";
import "../plugins/slider-criteria";
import "../plugins/slider";
import { checkboxclickmistery, checkonemistery } from './mistery';
import '../plugins/flatpickr';
import { checkboxclickculture, checkboxclickbeach, checkboxclickvisit, checkboxclicksport, checktwoculture, checktwosport, checktwovisit, checktwobeach } from './form';
import { initMapbox } from '../plugins/init_mapbox';
import {scrollFunction} from '../components/topbutton';
import {topFunction} from '../components/topbutton';
import { initRangeSlider } from '../components/sliders';


initMapbox();

// scrollFunction();
// topFunction();

// add active class on choosen activities
checkboxclickculture();
checkboxclickbeach();
checkboxclickvisit();
checkboxclicksport();
checktwoculture();
checktwosport();
checktwovisit();
checktwobeach();

checkboxclickmistery();
checkonemistery();

