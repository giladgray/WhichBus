require 'stop'

class JourneyController < ApplicationController
  @@lat_lon_regex = /(?<lat>-?\d+(\.\d+)?),(?<lon>-?\d+(\.\d+)?)/
  
  def self.geocode(query, limit=10)
    if coord = @@lat_lon_regex.match(query)
      limit = 1
      query = [coord[:lat], coord[:lon]]
    end
    
    location = Geocoder.search(query).first
    location
  end
  
  caches_page :new
  
	def new
		render :layout => "splash"
	end
	
	def options
		OneBusRecord.reset_json_count
    
		@from = self.class.geocode(params[:from])
		@from_stops = Stop.by_location(@from.latitude, @from.longitude).first(10)
    
		@to = self.class.geocode(params[:to])
		@to_stops = Stop.by_location(@to.latitude, @to.longitude).first(10)
		
		#TODO validation: null parameters, geocode fail
		
		#call routing helper to find the routes
		@journeys = self.class.calc_journeys(@from_stops, @to_stops)
		#display them
		
		@time = Time.now
	end
	
	def which
	end
	
	def self.calc_journeys(from_stops, to_stops, within_minutes=90)
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
					# route = fs.routes.find{|rte| rte.id == r && rte.arrivals.length > 0 && rte.arrivals.first.time_to_arrival < within_minutes * 60}
					route = fs.routes.find{|rte| rte.id == r && rte.arrivals.length > 0 }
					if route
						route.arrivals.each do |arr|
							result << [fs, route, arr, ts]
						end
					end
				end
			end
		end
		result.sort_by! {|r| r[2].predictedDepartureTime }
		result
	end
end
