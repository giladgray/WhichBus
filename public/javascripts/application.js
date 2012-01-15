// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function geolocate() {
	navigator.geolocation.getCurrentPosition(foundLocation, noLocation);
}

var returnData, list;
function foundLocation(position) {
	var latitude = position.coords.latitude;
	var longitude = position.coords.longitude;
	var userLocation = latitude + ', ' + longitude;
	$("#user_location").html(userLocation);
	
	$.getJSON("stop.json", { lat: latitude, lon: longitude },
		function(data) {
			returnData = data;
			$("#stop_count").text(data.length);
			list = $("#stop_list");
			data.each(function(stop) {
				//add a list item for each stop with a link to the stop page
				var li = $("<li>");
				li.append($("<a>").attr("href", "stop/" + stop.id)
								.text(stop.name)).append(" ");
				li.append($("<span>").addClass("distance")
								   .text(stop.distance.toFixed(2) + " mi"));
				list.append(li);
			});
		});
}

function noLocation() {
	alert("Geolocation failed! Sucks for you.");
}