include GeoKit::Geocoders

class StopController < ApplicationController
	geocode_ip_address
	
	def index
		@stops = []
		if params.has_key?("lat") and params.has_key?("lon")
			@stops = Stop.by_location(params[:lat], params[:lon])
		end
		
		respond_to do |format|
			format.html
			format.json { render :json => @stops }
			format.xml  { render :xml => @stops }
		end
	end
	
	def show
		@stop = Stop.new(params[:id])
		@time = Time.now
		
		respond_to do |format|
			format.html
			format.json { render :json => @stop }
			format.xml  { render :xml => @stop }
		end
	end
end
