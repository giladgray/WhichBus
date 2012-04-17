require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'

class OneBusRecord
	include ActionView::Helpers::DateHelper
	@@json_count = 0
	# a little regex to extract a part of the url to use as the cachekey:
	@@cachekey_regex = /where\/(?<cachekey>[a-z0-9_\-\/]*).[a-z]*\?.*key=(?<apikey>TEST)/
	# example: http://api.onebusaway.org/api/where/[route/1_44].json?key=TEST || [stop/1_75403] || ...

	attr_reader :data
	attr_accessor :distance

	def initialize(cachekey, url_or_hash)
		# here is where we search the cache for this url
		# the cachekey is the unique part of the url that contains the API method and ID parameter (see regex above)
		#matches = @@cachekey_regex.match(url_or_hash)
		#cachekey = matches["cachekey"]
		puts "cache fetch \"#{cachekey}\" [#{Rails.cache.exist? cachekey}]"
		@data = Rails.cache.fetch(cachekey) do
			if url_or_hash.is_a? Hash
				puts "  * new cache entry created from hash *"
				item = OpenStruct.new(url_or_hash)
			else
				puts "  * new cache entry created from url *"
				result = self.class.get_json(url_or_hash)
				# NOTE: Arrival/Departures are created using get_json directly in Stop.rb so they'll never cache
				item = OpenStruct.new(result["data"])
			end
			# store the OpenStruct object in the cache. Ruby will serialize it thanks. BOOM!
			item
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

	# the cachekey is the unique part of the url that contains the API method and ID parameter (see regex above)
	def construct_cachekey(url)
		matches = @@cachekey_regex.match(url)
		matches["cachekey"]
	end

	def method_missing(method_sym, *arguments, &block)
		data.send(method_sym)
	end

	def save
		fail
	end

	def save!
		fail
	end

end