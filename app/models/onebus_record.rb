require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'

class OneBusRecord

  attr_reader :data

  def initialize(url_or_hash)
   puts url_or_hash.class
   if url_or_hash.is_a? Hash
       @data = OpenStruct.new(url_or_hash)
	else
	   result = self.class.get_json(url_or_hash)
	   @data = OpenStruct.new(result["data"])
	end
  end
   
  def self.get_json(url)
	data = Net::HTTP.get_response(URI.parse(url)).body
	result = JSON.parse(data)
	if result.has_key? 'error'
		raise result.error + ": " + result.text
	end
	result
  end
  
  def method_missing(method_sym, *arguments, &block)
    return data.send(method_sym)
  end

end