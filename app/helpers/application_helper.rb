module ApplicationHelper
	def route_button(route)
		link_to(route.shortName, route_path(route.id), :class=>"button radius")
	end
	
	def predicted_time(arrival)
		# if we have a real prediction....
		if arrival.predictedDepartureTime > 0
			html = ""
			html << content_tag(:div, arrival.predicted_departure_time, :class=>"row small")
			html << content_tag(:div, arrival.time_to_departure_in_words(@time), :class=>"row #{arrival.css_class_for_arrival_time(@time)}")
			html << content_tag(:div, arrival.predicted_departure_difference, :class=>"row small #{arrival.css_class_for_time_difference}")
			# must call this method for the HTML to appear properly on the page
			html.html_safe
		# otherwise use scheduled time
		else
			scheduled_time(arrival)
		end
	end
	
	def scheduled_time(arrival)
		html = ""
		html << content_tag(:div, arrival.scheduled_arrival_time, :class=>"row small")
		html << content_tag(:div, arrival.time_to_arrival_in_words(@time), :class=>"row #{arrival.css_class_for_arrival_time(@time)}")
		html << content_tag(:div, "scheduled", :class=>"row small")
		html.html_safe
	end
end
