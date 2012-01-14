require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class Stop < OneBusRecord

  def initialize(stop)
   url = "http://api.onebusaway.org/api/where/stop/#{stop}.json?key=TEST"
   super(url)
  end

end

# stop = Stop.new("1_75403")
# puts stop.name
# stop.routes.each {|r| puts r["name"] }