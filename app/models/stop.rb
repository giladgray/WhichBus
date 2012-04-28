include Geocoder

require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'
require 'route'
require 'geocoder'

class Stop < OneBusRecord

	def initialize(stop, hash=nil)
		url = "http://api.onebusaway.org/api/where/stop/#{stop}.json?key=TEST"
		hash ? super(OneBusRecord.make_cachekey(url), hash) : super(OneBusRecord.make_cachekey(url), url)
	end

	def self.by_location(lat=47.653435, lon=-122.305641, predictions=false)
		puts "getting stops near (#{lat},#{lon})"
		url = "http://api.onebusaway.org/api/where/stops-for-location.json?key=TEST&lat=#{lat}&lon=#{lon}"
		stops = get_json(url)["data"]["stops"]
		results = []
		stops.each do |s|
			stop = Stop.new(s['id'], s)
			stop.distance = Geocoder::Calculations.distance_between([stop.lat, stop.lon], [lat.to_f, lon.to_f])
			if predictions
				stop.routes_and_arrivals
				results << stop if stop.routes.any? { |r| not r.arrivals.empty? }
			else
				results << stop
			end
		end
		results.sort_by! { |s| s.distance }
		results
	end

	# just the arrivals
	def arrivals_and_departures
		url = "http://api.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{data.id}.json?key=TEST"
		@arrivals_departures = self.class.get_json(url)["data"]["arrivalsAndDepartures"].map do |ad|
			ArrivalDeparture.new(nil, ad)
		end
	end

	# just the routes
	def routes
		@routes ||= data.routes.map { |r| Route.new(r['id'], r) }
	end

	def routeIds
		@routeIds ||= data.routes.map { |r| r['id'] }
	end

	# list of routes with arrivals folded in to the routes
	def routes_and_arrivals
		arrivals = arrivals_and_departures
		data.routes.map do |r|
			r['arrivals'] = arrivals.find_all { |arr| arr.routeId == r['id'] }
			Route.new(r['id'], r)
		end
	end

	def methods
		data.methods
	end

	def to_s
		"Stop #{data.name} (#{data.id})"
	end
end
