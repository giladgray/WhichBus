require 'rubygems'
require 'json'
require 'net/http'

class StatController < ApplicationController

	def find_crime_by_lat_long
		request = "http://data.seattle.gov/resource/7ais-f98f.json?$where=within_circle(location,"+
			       params[:latitude ].to_s+","+
			       params[:longitude].to_s+","+
			       params[:distance ].to_s+")"
		data = Net::HTTP.get_response(URI.parse(request))
		stats = JSON.parse(data.response.body)

		respond_to do |format| 
			format.json { render :json => stats }
			format.xml  { render :xml  => stats }
		end

	end

end