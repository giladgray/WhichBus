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
			returnData = data;
			$("#stop-count").text(data.length);
			var list = $("#stop-list");
			data.each(function(stop) {
				//add a list item for each stop with a link to the stop page
				list.append($("<li>").append(
					$("<a>").attr("href", "stop/" + stop.id)
							.append(stop.name)
							.append(" (" + stop.distance + " mi)"));
			});
		});
}

function noLocation() {
	alert("Geolocation failed! Sucks for you.");
}