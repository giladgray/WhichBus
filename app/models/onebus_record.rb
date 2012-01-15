require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'

class OneBusRecord
  include ActionView::Helpers::DateHelper
  @@json_count = 0;

  attr_reader :data
  attr_accessor :distance
  
  def initialize(url_or_hash)
   if url_or_hash.is_a? Hash
       @data = OpenStruct.new(url_or_hash)
	else
	   result = self.class.get_json(url_or_hash)
	   @data = OpenStruct.new(result["data"])
	end
  end
  
  def as_xml(options={})
	as_json(options)
  end
  
  def as_json(options={})
	result={}
	(data.methods - Object.methods - [:data, :method_missing, :delete_field, :marshal_dump, :marshal_load, :table, :modifiable, :new_ostruct_member]).each do |m|
		result[m] = data.send(m) unless m.to_s.end_with?("=")
	end
	result[:name] = data.name
	result[:distance] = distance
	result
  end
   
  def self.get_json(url, verbose=false)
	@@json_count += 1
	puts "JSON REQUEST #{@@json_count}: #{url}"
	data = Net::HTTP.get_response(URI.parse(url)).body
	result = JSON.parse(data)
	unless result["code"] == 200 
		raise result["code"].to_s + ": " + result["text"]
	end
	result
  end
  
  def self.reset_json_count
	@@json_count = 0
  end
  
  def method_missing(method_sym, *arguments, &block)
    return data.send(method_sym)
  end

end