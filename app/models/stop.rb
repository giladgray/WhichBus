include GeoKit

require 'geokit-rails3'
require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'
require 'route'
require 'haversine'

class Stop < OneBusRecord
					
  def initialize(stop, hash=nil)
	url = "http://api.onebusaway.org/api/where/stop/#{stop}.json?key=TEST"
    hash ? super(hash) : super(url) 
  end
  
  def self.by_location(lat=47.653435, lon=-122.305641)
     url = "http://api.onebusaway.org/api/where/stops-for-location.json?key=TEST&lat=#{lat}&lon=#{lon}"
	 stops = get_json(url)["data"]["stops"]
	 results = []
	 stops.each do |s|
		stop = Stop.new(s[:id], s)
		stop.distance = haversine_distance(lat.to_f, lon.to_f, stop.lat.to_f, stop.lon.to_f)
		results << stop
	 end
	 results.sort_by! {|s| s.distance }
	 results
  end
  
  def arrivals_and_departures
	url = "http://api.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{data.id}.json?key=TEST"
	arrivals_departures = self.class.get_json(url, true)["data"]["arrivalsAndDepartures"]
	arrivals_departures.map{|ad| ArrivalDeparture.new(ad)}
  end
  
  def routes
	data.routes.map{|r| Route.new(r[:id], r)}
  end
  
  def methods
	data.methods
  end
  
  def as_json(options={})
	{ :id => data.id,
	  :code => data.code,
	  :name => data.name,
	  :direction => data.direction,
	  :locationType => data.locationType,	# 0 = stop, 1 = station
	  :latitude => data.lat,
	  :longitude => data.lon,
	  :routes => routes }
  end

end
