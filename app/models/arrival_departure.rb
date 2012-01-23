require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

#TODO: sometimes predicted times are 0. this is bad and should be replaced with scheduled
#when prediced times = 0 then prediction = -15000d 

class ArrivalDeparture < OneBusRecord
	@@time_format = "%l:%M%P"
	
  def all_times
    "#{scheduled_arrival_time}/#{predicted_arrival_time} => #{scheduled_departure_time}/#{predicted_departure_time}"
  end
  
  def print_html(time = Time.now)
    #content_tag(:div, predicted_departure_time, :class=>"row small")
    content_tag(:div, time_to_departure_in_words(time), :class=>"row #{css_class_for_arrival_time(time)}").to_s
    #content_tag(:div, predicted_departure_difference, :class=>"row small #{css_class_for_time_difference}")
  end
  
  def self.convert_time(time)
		Time.at(time / 1000).strftime(@@time_format)
  end
  
	def predicted_arrival_time
		self.class.convert_time(data.predictedArrivalTime)
	end
  
	def predicted_departure_time
		self.class.convert_time(data.predictedDepartureTime)
	end
	
	def scheduled_arrival_time
		Time.at(data.scheduledArrivalTime / 1000).strftime(@@time_format)
	end
	
	def scheduled_departure_time
		Time.at(data.scheduledDepartureTime / 1000).strftime(@@time_format)
	end
	
	def time_to_arrival(from_time = Time.now)
		Time.at(data.scheduledArrivalTime / 1000) - from_time
	end
	
	def time_to_departure(from_time = Time.now)
		Time.at(data.predictedDepartureTime / 1000) - from_time
	end
	
	def time_to_arrival_in_words(from_time = Time.now)
		ArrivalDeparture.time_to_words_short((Time.at(data.scheduledArrivalTime / 1000) - from_time) / 60)
	end
	
	def time_to_departure_in_words(from_time = Time.now)
		ArrivalDeparture.time_to_words_short((Time.at(data.predictedDepartureTime / 1000) - from_time) / 60)
	end
	
	def css_class_for_arrival_time(from_time = Time.now)
		case time_to_departure(from_time) / 60
		when -1000...0
			"gone"
		when 0...7
			"now"
		when 7...15
			"soon"
		when 15...31
			"soonish"
		else
			"later"
		end
	end
	
	def time_to_arrival_short(from_time = Time.now)
		minutes = (Time.at(data.scheduledArrivalTime / 1000) - from_time) / 60
		ArrivalDeparture.time_to_words_short(minutes)
    end
	
	def predicted_departure_difference
		change = (data.predictedDepartureTime - data.scheduledArrivalTime) / (1000 * 60)
		case 
		when change == 0
			"on time"
		when change < 0
			"#{-change}m early"
		else
			"#{change}m late"
		end
	end
	
	def css_class_for_time_difference
		change = (data.predictedDepartureTime - data.scheduledArrivalTime) / (1000 * 60)
		case
		when change == 0
			"gone"
		when change < 0
			"early"
		else
			"late"
		end
	end

	def self.time_to_words_short(minutes, signed=true)
		result = (minutes < 0 and signed) ? "-" : ""
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
