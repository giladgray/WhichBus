// ...
//= require jquery
//= require jquery_ujs
//= require mapping
//= require awesome
//= require_tree .

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

function loadingSpinner() {
  var opts = {
    lines: 12, // The number of lines to draw
    length: 0, // The length of each line
    width: 8, // The line thickness
    radius: 10, // The radius of the inner circle
    color: '#bff3cd', // #rgb or #rrggbb
    speed: 1.4, // Rounds per second
    trail: 50, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: true // Whether to use hardware acceleration
  };
  var target = document.getElementById('loading_spinner');
  var spinner = new Spinner(opts).spin(target);
}