# BOOM jQUERY
$(document).ready ->
  # make the little x button work
  clearButtons = $("span.clear-input.button")
  clearButtons.hide().click ->
    $(this).prev("input.input-text").val('').focus()
  # add some fancy disappearing magic to it
  clearButtons.prev("input.input-text").focusin ->
    $(this).next().fadeIn('fast') if $(this).val() == ""
  clearButtons.prev("input.input-text").focusout ->
    $(this).next().fadeOut('slow') if $(this).val() == ""
  $("#hereButton").click ->
  	loadNearestStop(latlng(47.65, -122.32))
