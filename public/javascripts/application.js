// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function toggleHidden() {
	btn = $("#toggleButton");
	if(btn.text().startsWith("Show"))
		btn.text("Hide Boring Routes");
	else
		btn.text("Show Boring Routes");
	$(".row.journey.hidden").toggle();
}


/* Google Maps JS */
function geolocate() {
	navigator.geolocation.getCurrentPosition(initializeMap, noLocation);
}

function noLocation() {
	alert("Geolocation failed!");
}

function initializeMap(position) {

	var latitude = position.coords.latitude;
	var longitude = position.coords.longitude;
	var myLatlng = new google.maps.LatLng(latitude,longitude);
	
  var myOptions = {
    zoom: 14,
    center: new google.maps.LatLng(latitude, longitude),
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    minzoom: 10,
    disableDefaultUI: true
  }

  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

  var marker = new google.maps.Marker({
      position: myLatlng,
      map: map,
      title:"Your Location"
  });
}

window.onload = geolocate;
/* Google Maps JS END */