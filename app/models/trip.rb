require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class Trip < OneBusRecord

	def initialize(trip)
		url = "http://api.onebusaway.org/api/where/trip/#{trip}.json?key=TEST"
		super(OneBusRecord.make_cachekey(url), url)
	end

end
