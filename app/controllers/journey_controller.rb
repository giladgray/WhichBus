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
    @routes = self.class.find_routes(@from_stops, @to_stops)

    #call routing helper to find the routes
    # @journeys = self.class.calc_journeys(@from_stops, @to_stops)
    #display them

    @time = Time.now

    respond_to do |format|
      format.html
      format.json { render :json => {"from" => {"name" => @from.address, "latitude" => @from.latitude, "longitude" => @from.longitude},
                                     "to" => {"name" => @to.address, "latitude" => @to.latitude, "longitude" => @to.longitude},
                                     "trips" => @journeys} }
      format.xml { render :xml => @journeys }
    end
  end

  def which
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
    routes = from_routes & to_routes
    puts "All Routes: #{routes}"
    routes

    # find FROM stops that are served by VALID routes
    valid_from = from_stops.select do |stop|
      intersect = stop.routes.map { |rt| rt.id } & routes
      not intersect.empty?
    end
    # find TO stops that are served by VALID routes
    valid_to = to_stops.select do |stop|
      intersect = stop.routes.map { |rt| rt.id } & routes
      not intersect.empty?
    end
    puts "Valid From: #{valid_from}"
    puts "Valid To: #{valid_to}"
  end

  def self.calc_journeys(from_stops, to_stops, within_minutes=90)
    result = []
    # go thru each from stop and get routes
    from_stops.each do |fs|
      from_route_ids = fs.routes.map { |r| r.id }
      # caution n squared algorithm need to improve later
      # go thru each to_stop and intersect routes
      to_stops.each do |ts|
        to_route_ids = ts.routes.map { |r| r.id }
        # get intersection of from_routes and to_routes
        routes = from_route_ids & to_route_ids
        routes.each do |routeId|
          # route = fs.routes.find{|rte| rte.id == r && rte.arrivals.length > 0 && rte.arrivals.first.time_to_arrival < within_minutes * 60}
          route = fs.routes.find { |rte| rte.id == routeId }
          if route
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
