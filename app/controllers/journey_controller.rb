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
		@routes = self.class.calc_routes(@from_stops, @to_stops)
		#display them
	end
	
	def show
	end
	
	

	def self.calc_routes(from_stops, to_stops)
		result = []
		# go thru each from stop and get routes
		from_stops.each do |fs|
			from_route_ids = fs.routes.map{|r| r.id}
			# caution n squared algorithm need to improve later
			# go thru each to_stop and intersect routes
			to_stops.each do |ts|
				to_route_ids = ts.routes.map{|r| r.id}
				routes = from_route_ids & to_route_ids
				#routes = fs.routes.map{|r| r.id
				#result << routes.map{|r| [fs.id, r, ts.id]} if routes.length > 0
				routes.each do |r|
					result << [fs, fs.routes.find{|rte| rte.id == r}, ts]
				end
			end
		end
		result
	end
end
