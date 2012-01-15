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
  
  def as_json(options={})
	{ :id => data.id,
	  :description => data.description,
	  :name => data.shortName,
	  :type => data.type,
	  :url => data.url }
  end

end

# stop = Stop.new("1_75403")
# puts stop.name
# stop.routes.each {|r| puts r["name"] }