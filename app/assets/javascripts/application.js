// ...
//= require jquery
//= require jquery_ujs
//= require mapping
//= require_tree .

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/* NOTE: I'm commenting out javascript as I translate it to coffeescript */

/*function tag(tag, classes, text) {
  return $(tag).addClass(classes).html(text);
}
function div(classes, text) {
  return tag("<div>", classes, text);
}
function span(classes, text) {
  return tag("<span>", classes, text);
}
function link(href, text, classes) {
  return $("<a>").addClass(classes).attr("href", href).html(text);
}*/

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
/*function detectBrowser() {
	var useragent = navigator.userAgent;
  var mapdiv = $("#map_canvas");

	mapdiv.css('width', '100%');
	if (useragent.indexOf('iPhone') != -1 || useragent.indexOf('Android') != -1) {
	  mapdiv.css('height', '200px');
	} else {
	  mapdiv.css('height', '600px');
	}
}*/
      
/*function geolocate() {
	navigator.geolocation.getCurrentPosition(function(position) {
      pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
      clickMarker = marker("Your Location", pos);
      centerMap(pos);
      console.log("geolocation successful");
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
}*/

//call this in onload and pass the clickHandler function name. easy!
/*function initializeMap(clickHandler, doGeolocate) {
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
  console.log("creating map...");
  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  google.maps.event.addListener(map, 'click', function(event) {
    clickHandler(event.latLng);
  });
	clickMarker = marker("Seattle", defaultPosition);
  console.log("map initialized");

  if(doGeolocate != false)
    geolocate();
}*/

function centerMap(position) {
  //clicks at the given position which calls whatever clickHandler was specified in initializeMap
  google.maps.event.trigger(map, 'click', {latLng: position});
  if(map.zoom < 13)
    map.setZoom(14);
}

//creates a maps.LatLng with the given coordinates. easy!
/*function latlng(lat, lng) {
  return new google.maps.LatLng(lat, lng);
}*/
//creates a maps.Marker with the given title and position 
//and adds it to the given marker group (an array of markers)
/*function marker(title, position, group, handler) {
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
}*/

//given an array of markers, removes all of them from the map and empties the array.
/*function clearMarkerGroup(group) {
  if(group != undefined) {
    $.each(group, function(index, marker) {
      marker.setMap(null);
    });
    group.splice(0, group.length);   
  }
}*/

/*function showStopMarker(position) {
  clickMarker.setPosition(position);
  map.setCenter(position);
}*/

/*function doNothing(event) {
  //an empty click handler
}
*/
var result, click;
/*function loadNearbyStops(position) {
  //clear the list of nearby markers
  clearMarkerGroup(nearbyMarkers);
  
  clickMarker.setPosition(position);
  //$("#results").text("You clicked at (" + position.lat() + "," + position.lng() +")").append("<br/>");
  //perform an AJAX request to stop#index with the user's location
  var url = "/stop.json";
  $("#model-list").fadeOut('fast');
  $.get(url, { "lat": position.lat(), "lon": position.lng(), "api":"yes" }, function (data) {
    result = data
    //the API returns a JSON array of stops
    //iterate through the array and display each one in the list column and create a marker for it
    $.each(data, function(index, stop) {
      $("#model-list").append(createStopDisplay(stop));
      var m = marker(stop.name, new google.maps.LatLng(stop.lat, stop.lon), nearbyMarkers, clickStopMarker(stop));
    });
    $("#model-list").fadeIn();
  });
}*/

/*function clickStopMarker(stop) { 
	return function() {
		$("#page-title-header").text(this.title);
		loadStopData(stop.id);
	};
}*/

/*function loadStopData(stopId) {
  var url = "/stop/" + stopId + "/schedule";
  $("#model-list").slideUp();
  $("#model-list").text("");
  $.get(url, { "api":"yes" }, function (data) {
    result = data
    //the API returns the stop's schedule data formatted as HTML so we just plop it into the model-list
    $("#model-list").html(data);
	
    //the API returns a JSON array of stops
    //iterate through the array and display each one in the list column and create a marker for its
    /*$.each(data, function(index, stop) {
      $("#model-list").append(createArrivalDisplay(stop));
      //var m = marker(stop.name, new google.maps.LatLng(stop.lat, stop.lon), nearbyMarkers);
    });*/
    /*$("#model-list").fadeIn();
  });
}*/

//builds the HTML to display a stop using the journey CSS classes
/*function createStopDisplay(stop) {
  var _div = $("<div>").addClass("row display well journey");
  //div.append(tag("<span>", "journey description", link("stop/" + stop.id, stop.name)));
  _div.append(link("stop/" + stop.id, stop.name, "journey description"));
  _div.append(span("journey time", stop.distance.toFixed(2) + "mi"));
  return div;
}*/

/*function createJourneyDisplay(journey) {
  // [from, route, arrival, to]
	var _div = $("<div>").addClass("row display well journey");
  //create the link button for the route
	_div.append($("<span>").addClass("journey route").html(
    link("route/" + journey[1].id, journey[1].shortName, "button radius whichbus-green")
	));
  //create the description span in the middle with the headsign and route name
	_div.append($("<span>").addClass("journey description").html(
    $("<a>").attr("href", "stop/"+journey[0].id)
      .html(tag("<small>", "headsign radius", journey[2].tripHeadsign))
      .append("<br/>")
	    .append($("<h5>").text(journey[0].name))));
      
  //create the journey's time display (time/minutes/delay)
	//TODO: colorize times. we no longer have access to the Ruby methods so we'll have to write our own in JS
	_div.append($("<span>").addClass("journey time")
    .html(div("row small", journey[2].arrival))
    .append(div("row "+colorizeTime(journey[2].wait_minutes), journey[2].wait_time))
    .append(div("row small "+colorizeStatus(journey[2].status), journey[2].status)));
    
	return _div;
}*/
//returns the CSS class for the wait time
function colorizeTime(time) {
  if(time < 0)
    return "gone";
  else if(time < 6)
    return "now";
  else if(time < 16)
    return "soon";
  else if(time < 36)
    return "soonish";
  else
    return "later";
}
//returns the CSS class for the journey status
function colorizeStatus(status) {
  if(status.indexOf("early") > -1)
    return "early";
  else if (status.indexOf("late") > -1)
    return "late";
  else
    return "";
}

function createArrivalDisplay(arrival) {
  return arrival;
}

function showJourney(from, to) {
	initializeMap(doNothing);
	var url = "/options.json";
	//call the options.json API to calculate the possible routes 
	$.get(url, { "from" : from, "to" : to }, function(data) {
		result = data;
    from = result["from"];
    to = result["to"];
		//returns three things: from, to, and trips
		//build title from the first two items
		title = $("<h3>").append($("<em>").text("From: ")).append(from.name).append("<br>");
		title.append($("<em>").text("To: ")).append(to.name);
    marker(from.name, latlng(from.latitude, from.longitude));
    marker(to.name, latlng(to.latitude, to.longitude));
		$("#page-title").html(title).fadeIn();
		//iterate through trips, adding journey row for each one
		$.each(result["trips"], function(index, trip) {
			//output trip
			$("#model-list").append(createJourneyDisplay(trip).fadeIn());
		});
	});
}

/*window.onload = geolocate;*/

/* Google Maps JS END */