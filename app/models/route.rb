require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class Route < OneBusRecord

  def initialize(route, hash=nil)
   url = "http://api.onebusaway.org/api/where/route/#{route}.json?key=TEST"
   hash ? super(hash) : super(url)
  end
  
  def stops
	url = "http://api.onebusaway.org/api/where/stops-for-route/#{data.id}.json?key=TEST&version=2"
	puts url
	self.class.get_json(url)["data"]["entry"]["stopIds"]
  end

end
