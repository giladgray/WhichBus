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