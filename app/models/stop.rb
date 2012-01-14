require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'

class Stop

  attr_reader :data

  def initialize(stop)
   puts "test"
   url = "http://api.onebusaway.org/api/where/stop/#{stop}.json?key=TEST"
   data = Net::HTTP.get_response(URI.parse(url)).body
   result = JSON.parse(data)
   if result.has_key? 'error'
      raise result.error + ": " + result.text
   end
   @data = OpenStruct.new(result["data"])
  end
  
  def method_missing(method_sym, *arguments, &block)
    puts "getting: " + method_sym.to_s
    return data.send(method_sym)
  end

end

# stop = Stop.new("1_75403")
# puts stop.name
# stop.routes.each {|r| puts r["name"] }