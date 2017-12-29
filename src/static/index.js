// pull in desired CSS/SASS files
//require('./styles/main.scss');
//var $ = jQuery = require( '../../node_modules/jquery/dist/jquery.js' );           // <--- remove if jQuery not needed
//require( '../../node_modules/bootstrap-sass/assets/javascripts/bootstrap.js' );   // <--- remove if Bootstrap's JS not needed

var Elm = require('../elm/Main');
var element = document.createElement("div");
// parent.setAttribute(name, value);
document.body.prepend(element);
Elm.Main.embed(element);
