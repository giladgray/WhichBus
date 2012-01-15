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
		
		@arrivals = []
		routes = []
		@stop.routes.each do |r|
			if r.arrivals.length > 0
				r.arrivals.each do |arr|
					@arrivals << [r, arr]
				end
			else
				routes << [r, nil]
			end
		end
		
		routes.sort_by! {|arr| arr[0].shortName.to_i }
		@arrivals.sort_by! {|arr| arr[1].scheduledArrivalTime }
		@arrivals += routes
		
		respond_to do |format|
			format.html
			format.json { render :json => @stop }
			format.xml  { render :xml => @stop }
		end
	end
end
