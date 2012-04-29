# BOOM jQUERY
$(document).ready ->
	# make the little x button work
	clearButtons = $("span.clear-input")
	clearButtons.hide().click ->
		$(this).prev("input.input-text").val('').focus()
	# add some fancy disappearing magic to it
	clearButtons.prev("input.input-text").focusin ->
		$(this).next().fadeIn('fast') #if $(this).val() == ""
	clearButtons.prev("input.input-text").focusout ->
		$(this).next().fadeOut('slow') if $(this).val() == ""
		
	$("#hereButton").click ->
		loadNearestStop(latlng(47.65, -122.32))

	# Switching between commenting and route info on route pages
	$('.route_switch').on 'click', (event) ->
		if $(this).html().indexOf('Route') != -1
			$(this).html 'Show Comments'
			$('#model-list').animate opacity: '1.0', 200 
			$('#comments').animate opacity: '0.0', 200
		else 
			$(this).html('Show Route Info')
			$('#model-list').animate opacity: '0.0', 200
			$('#comments').animate opacity: '1.0', 200

