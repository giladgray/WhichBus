require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class Route < OneBusRecord

	attr_accessor :stops
	attr_accessor :polylines
	attr_accessor :stop_groups

	def initialize(route, hash=nil)
		puts "$$$ creating new route #{route} [url:#{hash.nil?}]"

		url = "http://api.onebusaway.org/api/where/route/#{route}.json?key=TEST"
		hash ? super(OneBusRecord.make_cachekey(url), hash) : super(OneBusRecord.make_cachekey(url), url)
	end

	def self.by_location(lat=47.653435, lon=-122.305641, query=nil)
		puts "getting routes near (#{lat},#{lon})"
		url = "http://api.onebusaway.org/api/where/routes-for-location.json?key=TEST&lat=#{lat}&lon=#{lon}"
		url += "&query=#{query}" unless query.nil?
		routes = get_json(url)["data"]["routes"]
		routes.map { |r| Route.new(r['id'], r) }
	end

	def stops
		puts "Loading stops..."
		url = "http://api.onebusaway.org/api/where/stops-for-route/#{data.id}.json?key=TEST&version=2"
		response = self.class.get_ostruct(url)
		#@stops = response["entry"]["stopIds"].map do |stopId|
		#	# use the list of stops in the references section to create stops (if they're not already cached)
		#	data = response["references"]["stops"].select { |hash| hash["id"] == stopId }.first
		#	Stop.new(stopId, data)
		#end

		@polylines ||= response.entry['polylines']

		# create the list of stop groups by mapping the data from 1BA into a more usable format
		@stop_groups ||= response.entry['stopGroupings'].first()['stopGroups'].map do |group|
			puts group['name']['name']
			stops = group['stopIds'].map do |stopId|
				# use the list of stops in the references section to create stops (if they're not already cached)
				data = response.references['stops'].select { |hash| hash['id'] == stopId }.first
				Stop.new(stopId, data)
			end
			result = { name: group['name'], stops: stops, polylines: group['polylines'] }
			result
		end
	end

	def trips
		puts "Loading trips..."
		url = "http://api.onebusaway.org/api/where/trips-for-route/#{data.id}.json?key=TEST&version=2&includeStatus=true"
		# this one is easy, the data is just the trip list part of the API result
		self.class.get_ostruct(url, false).list
	end

	def as_json(options={})
		result = super(options)
		result[:stopGroups] = stops
		result[:polylines] = polylines
		result
	end

	def to_s
		"Route #{data.shortName} (#{data.id})"
	end
end
