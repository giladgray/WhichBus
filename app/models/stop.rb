require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'
require 'route'



class Stop < OneBusRecord
 # acts_as_mappable :lat_column_name => :lat,
#				   :lng_column_name => :lon

  def initialize(stop, hash=nil)
   url = "http://api.onebusaway.org/api/where/stop/#{stop}.json?key=TEST"
   hash ? super(hash) : super(url) 
  end
  
  def self.by_location(lat="47.653435", lon="-122.305641")
     url = "http://api.onebusaway.org/api/where/stops-for-location.json?key=TEST&lat=#{lat}&lon=#{lon}"
	 stops = get_json(url)["data"]["stops"]
	 results = []
	 stops.each do |s|
		results << Stop.new(s[:id], s)
	 end
	 results
  end
  
  def routes
	data.routes.map{|r| Route.new(r[:id], r)}
  end

end

# stop = Stop.new("1_75403")
# puts stop.name
# stop.routes.each {|r| puts r["name"] }
