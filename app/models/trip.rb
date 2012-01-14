require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class Trip < OneBusRecord

  def initialize(trip)
   url = "http://api.onebusaway.org/api/where/stop/#{trip}.json?key=TEST"
   super(url)
  end

end
