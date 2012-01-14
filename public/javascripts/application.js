// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
  navigator.geolocation.getCurrentPosition(foundLocation, noLocation);
})

function foundLocation(position) {
	var lat = position.coords.latitude;
	var lon = position.coords.longitude;
	var userLocation = lat + ', ' + lon;
	$("#user_location").html(userLocation);
}
function noLocation() {
}