require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class ArrivalDeparture < OneBusRecord

	def time_to_arrival
		Time.at(data.scheduledArrivalTime / 1000) - Time.now
	end
	
	def time_to_arrival_in_words
		distance_of_time_in_words(Time.at(data.scheduledArrivalTime / 1000), Time.now)
	end
end
