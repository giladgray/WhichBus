include GeoKit::Geocoders

class StopController < ApplicationController
	geocode_ip_address
	
	def index
	end
	
	def show
		@stop = Stop.new(params[:id])
	end
end
