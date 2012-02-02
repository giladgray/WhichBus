alert("hello")

# simplify HTML
tag = (tagname, classes, body) -> 
  $(tagname).addClass(classes).html(body)
div = (classes, body = null) ->
  tag "<div>", classes, body
span = (classes, body = null) ->
  tag "<span>", classes, body
link = (href, body, classes) ->
  $("<a>").addClass(classes).attr("href", href).html(body)
  
stopDisplay = (stop) ->
  display = $("<div>").addClass "row display well journey"
  display.append link("/stop/#{stop.id}", stop.name, "journey description")
  display.append span("journey time", stop.distance.toFixed(2) + "mi")

journeyDisplay = (journey) ->
  _div = $("<div>").addClass("row display well journey");
  `//create the link button for the route
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
    .append(div("row small "+colorizeStatus(journey[2].status), journey[2].status)))`

detectBrowser = () ->
  mapdiv = $("#map_canvas")
  mapdiv.css 'width', '100%'
  if 'iPhone' in navigator.userAgent or 'Android' in navigator.userAgent
    mapdiv.css 'height', '200px'
  else
    mapdiv.css 'height', '600px'
    
# rock some geolocation
yesLocation = (position) ->
  pos = latlng position.coords.latitude, position.coords.longitude
noLocation = () ->
  msg = "Geolocation Error: "
  switch error.code
    when error.TIMEOUT
      msg += "Timeout"
    when error.POSITION_UNAVAILABLE
      msg += "Position unavailable"
    when error.PERMISSION_DENIED
      msg += "Permission denied"
    when error.UNKNOWN_ERROR
      msg += "Unknown error"
  alert(msg)
geolocate = () ->
  navigator.geolocation.getCurrentPosition yesLocation, noLocation

# simplify Google Maps API
latlng = (lat, lng) ->
  new google.maps.LatLng(lat, lng)
  
marker = (title, position, group, handler) ->
  alert "new marker in #{@map}"
  alert "no map!" unless @map?
  mrkr = new google.maps.Marker({map: @map, position: position, title: title})
  google.maps.event.addListener(mrkr, 'click', handler) if handler?
  group.push(mrkr) if group?
  mrkr
  
clearMarkerGroup = (group) ->
  if group?
    marker.setMap(null) for marker in group
    group.splice 0, group.length
    
initializeMap = (clickHandler, doGeolocate = true) ->
  defaultPosition = latlng(47.652709,-122.32149)
  detectBrowser()
  options = 
    zoom: 11
    center: defaultPosition
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true
  
  @map = new google.maps.Map(document.getElementById("map_canvas"), options)
  @clickMarker = marker("Seattle", defaultPosition)
  @nearbyMarkers = []
  map.setCenter defaultPosition
  google.maps.event.addListener(@map, 'click', (event) -> clickHandler event.latLng)
  geolocate() if doGeolocate
window.initializeMap = initializeMap
  
showStopMarker = (position) ->
  @clickMarkers.setPosition(position)
  
# map click handlers
nothing = (event) ->

window.loadNearbyStops = (position) ->
  clearMarkerGroup @nearbyMarkers
  @clickMarker.setPosition(position) 
  url = "/stop.json"
  list = $("#model-list")
  list.fadeOut 'fast'
  $.get url, {lat: position.lat(), lon: position.lng(), api: yes}, (result) ->
    for stop in result
      list.append(stopDisplay(stop)).fadeIn()
      marker(stop.name, latlng(stop.latitude, stop.longitude), @nearbyMarkers, clickStopMarker(stop))
      
clickStopMarker = (stop) -> () ->
  $("#page-title-header").text(this.title)
  loadStopData stop.id
  
loadStopData = (stopId) ->
  url = "/stop/#{stopId}/schedule"
  list = $("#model-list")
  list.fadeOut()
  $.get url, {api:yes}, (result) ->
    list.html(result).fadeIn
      
# initialize the map immediately
alert("done")