// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function geolocate() {
	navigator.geolocation.getCurrentPosition(foundLocation, noLocation);
}

var returnData;
function foundLocation(position) {
	var latitude = position.coords.latitude;
	var longitude = position.coords.longitude;
	var userLocation = latitude + ', ' + longitude;
	$("#user_location").html(userLocation);
	
	$.getJSON("stop.json", { lat: latitude, lon: longitude },
		function(data) {
			alert("stops achieved.");
			returnData = data;
			var list = $("#stop-list");
			$(data).each(function() {
				list.append($("<li>").text($(this).name));
			});
			//$("#user_location").html(data);
		});
}
function noLocation() {
	alert("Geolocation failed! Sucks for you.");
}