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
	
	def self.calc_routes(from_stops, to_stops, within_minutes=9999)
		result = []
		# go thru each from stop and get routes
		from_stops.each do |fs|
			from_route_ids = fs.routes.map{|r| r.id}
			# caution n squared algorithm need to improve later
			# go thru each to_stop and intersect routes
			to_stops.each do |ts|
				to_route_ids = ts.routes.map{|r| r.id}
				# get intersection of from_routes and to_routes
				routes = from_route_ids & to_route_ids
				routes.each do |r|
					# route = fs.routes.find{|rte| rte.id == r && rte.arrivals.length > 0 && rte.arrivals.first.time_to_arrival < within_minutes}
					route = fs.routes.find{|rte| rte.id == r && rte.arrivals.length > 0 }
					result << [fs, route, ts] if route
				end
			end
		end
		result
	end
end
