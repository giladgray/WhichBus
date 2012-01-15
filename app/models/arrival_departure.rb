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

end
