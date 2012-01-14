require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'

class OneBusRecord

  attr_reader :data

  def initialize(url)
   # url = "http://api.onebusaway.org/api/where/route/#{route}.json?key=TEST"
   data = Net::HTTP.get_response(URI.parse(url)).body
   result = JSON.parse(data)
   if result.has_key? 'error'
      raise result.error + ": " + result.text
   end
   @data = OpenStruct.new(result["data"])
  end
  
  def method_missing(method_sym, *arguments, &block)
    return data.send(method_sym)
  end

end