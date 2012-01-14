require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class Route < OneBusRecord

  def initialize(route)
   url = "http://api.onebusaway.org/api/where/route/#{route}.json?key=TEST"
   super(url)
  end

end

# stop = Stop.new("1_75403")
# puts stop.name
# stop.routes.each {|r| puts r["name"] }