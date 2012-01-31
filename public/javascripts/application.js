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
var map, clickMarker;
var nearbyMarkers = new Array();
var pos;
function detectBrowser() {
	var useragent = navigator.userAgent;
  var mapdiv = $("#map_canvas");

	mapdiv.css('width', '100%');
	if (useragent.indexOf('iPhone') != -1 || useragent.indexOf('Android') != -1) {
	  mapdiv.css('height', '200px');
	} else {
	  mapdiv.css('height', '600px');
	}
}
      
function geolocate() {
	navigator.geolocation.getCurrentPosition(function(position) {
      pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
      clickMarker = marker("Your Location", pos);
      centerMap(pos);
    }, noLocation);
}

function noLocation() {
  msg = "Geolocation Error: ";
  switch (error.code) {
    case error.TIMEOUT:
      msg += "Timeout";
      break;
    case error.POSITION_UNAVAILABLE:
      msg += "Position unavailable";
      break;
    case error.PERMISSION_DENIED:
      msg += "Permission denied";
      break;
    case error.UNKNOWN_ERROR:
      msg += "Unknown error";
      break;
  }
  alert(msg);
}

//call this in onload and pass the clickHandler function name. easy!
function initializeMap(clickHandler, doGeolocate) {
  var defaultPosition = new google.maps.LatLng(47.652709,-122.32149);
  
  //default map options!
  var myOptions = {
    zoom: 11,
    center: defaultPosition,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    disableDefaultUI: true
  }

  detectBrowser();
  //build the map, add a click handler
  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  google.maps.event.addListener(map, 'click', function(event) {
    clickHandler(event.latLng);
  });
	clickMarker = marker("Seattle", defaultPosition);

  if(doGeolocate != false)
    geolocate();
}

function centerMap(position) {
  //clicks at the given position which calls whatever clickHandler was specified in initializeMap
  google.maps.event.trigger(map, 'click', {latLng: position});
  if(map.zoom < 13)
    map.setZoom(14);
}

//creates a maps.LatLng with the given coordinates. easy!
function latlng(lat, lng) {
  return new google.maps.LatLng(lat, lng);
}
//creates a maps.Marker with the given title and position 
//and adds it to the given marker group (an array of markers)
function marker(title, position, group, handler) {
  var marker = new google.maps.Marker({
    map: map,
    position: position,
    title: title,
  });
  if(handler != undefined)
    google.maps.event.addListener(marker, 'click', handler);
  
  if(group != undefined)
    group.push(marker);
    
  return marker;
}

//given an array of markers, removes all of them from the map and empties the array.
function clearMarkerGroup(group) {
  if(group != null) {
    $.each(group, function(index, marker) {
      marker.setMap(null);
    });
    group.splice(0, group.length);   
  }
}

function showStopMarker(position) {
  clickMarker.setPosition(position);
  map.setCenter(position);
}

function doNothing(event) {
}

var result, click;
function loadNearbyStops(position) {
  //clear the list of nearby markers
  clearMarkerGroup(nearbyMarkers);
  
  clickMarker.setPosition(position);
  //perform an AJAX request to stop#index with the user's location
  var url = "/stop.json";
  $("#results").text("You clicked at (" + position.lat() + "," + position.lng() +")").append("<br/>");
  $("#model-list").fadeOut('fast');
  $.get(url, { "lat": position.lat(), "lon": position.lng(), "api":"yes" }, function (data) {
    result = data
    //$("#model-list").html(data);
    //the API returns a JSON array of stops
    //iterate through the array and display each one in the list column and create a marker for its
    $.each(data, function(index, stop) {
      $("#model-list").append(createStopDisplay(stop));
      var m = marker(stop.name, new google.maps.LatLng(stop.lat, stop.lon), nearbyMarkers, clickStopMarker(stop));
    });
    $("#model-list").fadeIn();
  });
}

function clickStopMarker(stop) { 
	return function() {
		$("#page-title-header").text(this.title);
		loadStopData(stop.id);
	};
}

function loadStopData(stopId) {
  var url = "/stop/" + stopId + "/schedule";
  $("#model-list").slideUp();
  $("#model-list").text("");
  $.get(url, { "api":"yes" }, function (data) {
    result = data
    $("#model-list").html(data);
    //the API returns a JSON array of stops
    //iterate through the array and display each one in the list column and create a marker for its
    /*$.each(data, function(index, stop) {
      $("#model-list").append(createArrivalDisplay(stop));
      //var m = marker(stop.name, new google.maps.LatLng(stop.lat, stop.lon), nearbyMarkers);
    });*/
    $("#model-list").fadeIn();
  });
}

//builds the HTML to display a stop using the journey CSS classes
function createStopDisplay(stop) {
  var div = $("<div>").addClass("row display well journey");
  div.append($("<span>").addClass("journey description").html($("<a>").attr("href", "/stop/" + stop.id).text(stop.name)));
  div.append($("<span>").addClass("journey time").html($("<div>").addClass("row").text(stop.distance.toFixed(2) + "mi")));
  return div;
}

function createJourneyDisplay(journey) {
	/* [from, route, arrival, to]
	html << content_tag(:div, arrival.display_arrival_time, :class=>"row small")
		html << content_tag(:div, arrival.time_to_arrival_in_words(@time), :class=>"row #{arrival.css_class_for_arrival_time(@time)}")
		html << content_tag(:div, arrival.prediction_difference, :class=>"row small #{arrival.css_class_for_time_difference}") 
		<span class="journey route">
			<%= route_button(journey[1]) %>
			link_to(route.shortName, route_path(route.id), :class=>"button radius whichbus-green")
		</span>
		<span class="journey description">
			<a href="stop/<%= journey[0].id %>">
				<h5><%= truncate(journey[0].name, :length => 35) %></h5>
				<h6>&rArr;<%= truncate(journey[3].name, :length => 35) %></h6>
			</a>
		</span>
		<span class="journey time">
			<%= predicted_time(journey[2]) %>
		</span>*/
	var div = $("<div>").addClass("row display well journey");
	div.append($("<span>").addClass("journey route").html(
		$("<a>").addClass("button radius whichbus-green").attr("href", "route/" + journey[1].id).text(journey[1].shortName)
	));
	div.append($("<span>").addClass("journey description").html($("<a>").attr("href", "stop/"+journey[0].id).html(
		$("<h5>").text(journey[0].name)
	)));
	var time = $("<span>").addClass("journey time");
	time.html($("<div>").addClass("row small").text(journey[2].arrival));
	time.append($("<div>").addClass("row").text(journey[2].wait_time));
	time.append($("<div>").addClass("row small").text(journey[2].status));
	div.append(time);
	return div;
}

function createArrivalDisplay(arrival) {
  return arrival;
}

function showJourney(from, to) {
	initializeMap(doNothing);
	var url = "/options.json";
	$.get(url, { "from" : from, "to" : to }, function(data) {
		result = data;
		title = $("<h3>").append($("<em>").text("From: ")).append(result["from"].name).append("<br>");
		title.append($("<em>").text("To: ")).append(result["to"].name);
		$("#page-title").html(title).fadeIn();
		
		$.each(result["trips"], function(index, trip) {
			//output trip
			$("#model-list").append(createJourneyDisplay(trip).fadeIn());
		});
	});
}

/*window.onload = geolocate;*/

/* Google Maps JS END */