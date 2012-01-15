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
	arrivals_departures = self.class.get_json(url)["data"]["arrivalsAndDepartures"]
	arrivals_departures.map{|ad| ArrivalDeparture.new(ad)}
  end
  
  def routes
	arrivals = arrivals_and_departures
	data.routes.map do |r| 
		r["arrivals"] = arrivals.find_all{|arr| arr.routeId == r["id"] }
		Route.new(r[:id], r)
	end
  end
  
  def methods
	data.methods
  end

end
