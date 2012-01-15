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

end
