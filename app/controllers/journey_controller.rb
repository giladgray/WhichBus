require 'stop'

class JourneyController < ApplicationController
	include GeoKit::Geocoders

	def new
	end
	
	def options
		#expects two locations -- geocode them straight up!
		@from = GoogleGeocoder.geocode(params[:from])
		@to = GoogleGeocoder.geocode(params[:to])
		
		#if(@from.success and @to.success)
			#error handling!
		
		#find stops around those locations
		@from_stops = Stop.by_location(@from.lat, @from.lng).first(10)
		@to_stops = Stop.by_location(@to.lat, @to.lng).first(10)
		#call routing helper to find the routes
		
		#display them
		
	end
	
	def show
	end
end
