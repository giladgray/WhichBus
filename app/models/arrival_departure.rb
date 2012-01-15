require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class ArrivalDeparture < OneBusRecord

	def time_to_arrival(from_time = Time.now)
		Time.at(data.scheduledArrivalTime / 1000) - from_time
	end
	
	def time_to_arrival_in_words(from_time = Time.now)
		distance_of_time_in_words(Time.at(data.scheduledArrivalTime / 1000), from_time)
	end
	
	def time_to_departure_in_words(from_time = Time.now)
		distance_of_time_in_words(Time.at(data.predictedDepartureTime / 1000), from_time)
	end
	
	def css_class_for_arrival_time(from_time = Time.now)
		case time_to_arrival(from_time) / 60
		when -1000...0
			"gone"
		when 0..6
			"now"
		when 7...15
			"soon"
		when 15..30
			"soonish"
		else
			"later"
		end
	end
	
	def time_to_arrival_short(from_time = Time.now)
		minutes = (Time.at(data.scheduledArrivalTime / 1000) - from_time) / 60
		result = minutes < 0 ? "-" : ""
		minutes = minutes.to_int.abs
		case
		when minutes <= 1
			result = "Now!"
		when minutes < 60
			result << "#{minutes}m"
		when minutes < (60*24)
			hours = (minutes / 60).round
			mins = minutes%60
			result << "#{hours}h"
			result << ",#{mins}m" if mins > 0
		else
			# TODO: days, hours, minutes
			result << "#{(minutes / 1440).round}d"
		end
		result
    end

end
