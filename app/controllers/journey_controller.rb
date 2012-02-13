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

    @time = Time.now
    #TODO validation: null parameters, geocode fail
    @journeys = self.class.find_routes(@from_stops, @to_stops)

    runtime = Time.now - @time # number of seconds find_routes consumed
    puts "FINISHED! with a time of #{runtime * 1000}ms"
    #call routing helper to find the routes
    # @journeys = self.class.calc_journeys(@from_stops, @to_stops)
    #display them


    respond_to do |format|
      format.html
      format.json { render :json => {"from" => {"name" => @from.address, "latitude" => @from.latitude, "longitude" => @from.longitude},
                                     "to" => {"name" => @to.address, "latitude" => @to.latitude, "longitude" => @to.longitude},
                                     "trips" => @journeys} }
      format.xml { render :xml => @journeys }
    end
  end

  def self.find_routes(from_stops, to_stops)
    # find the routes that serve FROM stops
    from_routes = []
    from_stops.each do |from|
      from.routes.each do |route|
        unless from_routes.include? route.id
          from_routes << route.id
        end
      end
    end
    puts "From Routes: #{from_routes}"
    # find the routes that serve TO stops
    to_routes = []
    to_stops.each do |to|
      to.routes.each do |route|
        unless to_routes.include? route.id
          to_routes << route.id
        end
      end
    end
    puts "To Routes: #{to_routes}"

    # find VALID routes that serve BOTH stops!
    valid_routes = from_routes & to_routes
    puts "Valid Routes: #{valid_routes}"

    # find FROM stops that are served by VALID routes
    valid_from = from_stops.select do |stop|
      # this stop is served by a valid route if its route list contains a valid route
      intersect = valid_routes & stop.routes.map { |rt| rt.id }
      not intersect.empty? # set intersection is not empty
    end
    # find TO stops that are served by VALID routes
    valid_to = to_stops.select do |stop|
      intersect = valid_routes & stop.routes.map { |rt| rt.id }
      not intersect.empty?
    end
    puts "Valid From (#{valid_from.length}): #{valid_from.map { |s| s.name }.join(" | ")}"
    puts "Valid To (#{valid_to.length}): #{valid_to.map { |s| s.name }.join(", ")}"

    current_time = Time.now
    puts ""
    result = []
    ## for all the valid departure stops...
    #valid_from.each do |stop|
    #  # go through its routes...
    #  stop.routes_and_arrivals.select{ |r| valid_routes.include? r.id }.each do |route|
    #    # and add a journey for each arrival
    #    route.arrivals.each do |arr|
    #      puts "#{route.id} from #{stop.name} in #{arr.time_to_arrival_in_words(current_time)}"
    #      result << [stop, route, arr, stop] #TODO: destination stop
    #    end
    #  end
    #end

    valid_from.each do |stop|
      puts "Processing stop #{stop.name}:"
      stop.arrivals_and_departures.each do |arr|
        journey = result.find { |r| r[2].tripId == arr.tripId }
        if journey.nil?
          puts "  #{arr.routeId} in #{arr.time_to_arrival_in_words(current_time)}"
          result << [stop, nil, arr, stop]
        elsif stop.distance < journey[0].distance
          puts "  #{arr.routeId} to #{stop.name} in #{arr.time_to_arrival_in_words(current_time)} **"
          journey[2] = arr
          journey[0] = stop
        end
      end
    end

    # sort the results by arrival time
    result.sort_by! { |r| r[2].arrival_time }
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
    filtered_results = []

    result.sort_by! { |r| r[2].arrival_time }
    result

    ###
    # find routes that hit both stops
    # find stops served by those routes
    # load predictions for those stops
    ###
  end

end
