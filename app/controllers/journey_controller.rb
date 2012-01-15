class JourneyController < ApplicationController
	include GeoKit::Geocoders

	def new
	end
	
	def options
		@from = GoogleGeocoder.geocode(params[:from])
		@to = GoogleGeocoder.geocode(params[:to])
		
		#if(@from.success and @to.success)
		#expects two locations
		#geocode both to lat/lng
		#find stops around those locations
		#call routing helper to find the routes
		#display them
	end
	
	def show
	end
end
