require 'stop'

class JourneyController < ApplicationController

	def self.geocode(query, limit=1)
		lat_lon_regex = /(?<lat>-?\d+(\.\d+)?),(?<lon>-?\d+(\.\d+)?)/
		if (coord = lat_lon_regex.match(query))
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

		if params[:Body]
			puts request.format
			puts request.headers['Accept']
		else
			@from = self.class.geocode(params[:from])
			@from_stops = @from.nil? ? [] : Stop.by_location(@from.latitude, @from.longitude).first(20)

			@to = self.class.geocode(params[:to])
			@to_stops = @to.nil? ? [] : Stop.by_location(@to.latitude, @to.longitude).first(20)

			@time = Time.now
			#TODO validation: null parameters, geocode fail
			#call routing helper to discover journeys
			@journeys = self.class.find_journeys(@from_stops, @to_stops)

			runtime = Time.now - @time # number of seconds find_routes consumed
			puts "FINISHED! with a time of #{runtime * 1000}ms"
			# @journeys = self.class.calc_journeys(@from_stops, @to_stops)
			#display them
		end

		respond_to do |format|
			format.html
			format.json { render :json => {from: {name: address_helper(@from), latitude: @from.latitude, longitude: @from.longitude, geocode: @from.address_components},
										   to: {name: address_helper(@to), latitude: @to.latitude, longitude: @to.longitude, geocode: @to.address_components},
										   trips: @journeys} }
			format.xml { render :text => "<Response><Sms>Hi!</Sms></Response>", :content_type => 'text/xml' }
		end
	end

	def options_sms
		OneBusRecord.reset_json_count

		# parse the SMS message to extract the FROM and TO values

		chunks = params[:Body].split("-")
        from = chunks[0]
        to = chunks[1]

		from = self.class.geocode(from)
		from_stops = from.nil? ? [] : Stop.by_location(from.latitude, from.longitude).first(20)

		to = self.class.geocode(to)
		to_stops = to.nil? ? [] : Stop.by_location(to.latitude, to.longitude).first(20)

		journeys = self.class.find_journeys(from_stops, to_stops)

		puts journeys.size

        journey = journeys.select{|j| j[:when].time_to_arrival / 60 > 5}.first

        @start = journey[:from].name
        @stop = journey[:to].name
        @bus = journey[:when].routeShortName
        @min = journey[:when].time_to_arrival_in_words

		#render :text => "<Response><Sms>Go to #{start}, take the #{bus} bus to #{stop}. Arrives in #{min}</Sms></Response>", :content_type => 'text/xml'
		
		render "sms.xml.builder"
	end

	# returns a set of route IDs that serve this list of stops
	def self.routes_from_stops(stop_list)
		routes = []
		stop_list.each do |stop|
			stop.routeIds.each do |route|
				unless routes.include? route
					routes << route
				end
			end
		end
		routes
	end

	# selects all the stops from a list that lie on any of the given routes
	def self.stops_on_routes(stop_list, route_list)
		stop_list.select do |stop|
			# this stop is served by a valid route if its route list contains a valid route
			intersect = route_list & stop.routes.map { |rt| rt.id }
			not intersect.empty? # set intersection is not empty
		end
	end

	# Journey Algorithm Version 2.0
	# load prediction data as late as possible, prune irrelevant stops first
	def self.find_journeys(from_stops, to_stops)
		# find the routes that serve FROM stops
		from_routes = self.routes_from_stops(from_stops)
		puts "From Routes: #{from_routes}"
		# find the routes that serve TO stops
		to_routes = self.routes_from_stops(to_stops)
		puts "To Routes: #{to_routes}"

		# find VALID routes that serve BOTH stops!
		valid_routes = from_routes & to_routes
		puts "Valid Routes: #{valid_routes}"

		# find FROM stops that are served by VALID routes
		valid_from = self.stops_on_routes(from_stops, valid_routes)
		# find TO stops that are served by VALID routes
		valid_to = self.stops_on_routes(to_stops, valid_routes)
		puts "Valid From (#{valid_from.length}): #{valid_from.map { |s| s.name }.join(" | ")}"
		puts "Valid To (#{valid_to.length}): #{valid_to.map { |s| s.name }.join(", ")}"

		puts ""
		current_time = Time.now
		result = []
		# now that we've processed the data and found the valid stops and routes, let's work on the predictions.
		# load the predictions for valid departure stops (subset of all nearby stops) and add those on valid routes.

		# for all the valid departure stops...
		valid_from.each do |stop|
			puts "Processing stop #{stop.name}: [#{stop.routeIds.join(", ")}]"
			# go through its arrivals from valid routes...
			stop.arrivals_and_departures.select { |arr| valid_routes.include? arr.routeId }.each do |arr|
				journey = result.find { |r| r[:when].tripId == arr.tripId }
				# and add them to the list if this trip hasn't already been added
				if journey.nil?
					#puts "  Searching for destination: "
					dest = stop
					dest = valid_to.find { |to| to.routeIds.include? arr.routeId }
					unless dest.nil?
						result << {:from => stop, :to => dest, :when => arr}# [stop, nil, arr, dest] # TODO: find destination stop
																						 # if the trip has been added then update it if this stop is closer
						puts "	#{arr.routeId} in #{arr.time_to_arrival_in_words(current_time)} to #{dest.name}"
					end
				elsif stop.distance < journey[:from].distance
					puts "	#{arr.routeId} to #{stop.name} in #{arr.time_to_arrival_in_words(current_time)} **"
					journey[:when] = arr
					journey[:from] = stop
				end
			end
		end

		# sort the results by arrival time
		result.sort_by! { |r| r[:when].arrival_time }
		result
	end

# Journey Algorithm - Version 1.0
# loads routes and arrivals right away
	def self.calc_journeys(from_stops, to_stops, within_minutes=90)
		result = []
		# go thru each from stop and get routes
		from_stops.each do |fs|
			from_route_ids = fs.routes_and_arrivals.map { |r| r.id }
			# caution n squared algorithm need to improve later
			# go thru each to_stop and intersect routes
			to_stops.each do |ts|
				to_route_ids = ts.routes_and_arrivals.map { |r| r.id }
				# get intersection of from_routes and to_routes
				routes = from_route_ids & to_route_ids
				routes.each do |routeId|
					# route = fs.routes.find{|rte| rte.id == r && rte.arrivals.length > 0 && rte.arrivals.first.time_to_arrival < within_minutes * 60}
					route = fs.routes_and_arrivals.find { |rte| rte.id == routeId }
					if route
						puts "adding arrivals for #{routeId}"
						route.arrivals.each do |arr|
							# [from_stop, route, arrival, to_stop]

							# if something from this stop already exists ON THIS ROUTE
							journey = result.find { |r| r[0].id == fs.id and r[1].id == route.id }
							if journey.nil?
								puts "new journey #{route.id} | #{fs.name}->#{ts.name}"
								result << [fs, route, arr, ts] #{ "from" => fs, "route" => route, "trip" => arr, "to" => ts}
							else
								puts "duplicate. #{journey[3].distance} ~ #{ts.distance}"
								# and this to stop is CLOSER than that to stop, REPLACE
								if ts.distance < journey[3].distance
									puts "  optimization found! #{route.id} | #{journey[3].name}->#{ts.name}"
									journey[3] = ts
								end
							end
							# otherwise ignore

							# if something to this stop already exists ON THIS ROUTE
							# and this from stop is CLOSER than that from stop, REPLACE
							#result << [fs, route, arr, ts]
						end
					end
				end
			end
		end

		result.sort_by! { |r| r[2].arrival_time }
		result
	end


	def address_helper(location)
		address = "#{address_component(location, :street_number)} #{address_component(location, :route)}"
		establishment = address_component(location, :establishment)
		neighborhood = address_component(location, :neighborhood)
		city = address_component(location, :locality)
		puts "address = #{address}, hood = #{neighborhood}, city = #{city}"
		# address > establishment > neighborhood
		if address.length > 1
			"#{address}, #{city}"
		elsif establishment.length > 0
			"#{establishment}, #{city}"
		else
			"#{neighborhood}, #{city}"
		end
	end

	def address_component(location, type)
		components = location.address_components_of_type(type)
		puts "#{type} => #{components}"
		if components.empty?
			""
		else
			components[0]["short_name"]
		end
	end

end
