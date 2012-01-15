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
  
<<<<<<< HEAD
  def stops
	url = "http://api.onebusaway.org/api/where/stops-for-route/#{data.id}.json?key=TEST&version=2"
	puts url
	self.class.get_json(url)["data"]["entry"]["stopIds"]
=======
  def as_json(options={})
	{ :id => data.id,
	  :description => data.description,
	  :name => data.shortName,
	  :type => data.type,
	  :url => data.url }
>>>>>>> f16a462cd5841e36daf0ba297598b6e114cb4010
  end

end
