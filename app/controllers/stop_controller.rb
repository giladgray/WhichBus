class StopController < ApplicationController
	
  #TODO map markers are broken by the HTML-only API
  
	def index
		@user_location = request.location

        if params.has_key?("lat") and params.has_key?("lon")
            @stops = Stop.by_location(params[:lat], params[:lon])
        else
            @stops = Stop.by_location(@user_location.latitude, @user_location.longitude)
        end
			
		respond_to do |format|
			format.html { 
				if params.has_key?("api")
					render :partial => "stop_list"
				else
					render
				end
			}  
			format.json { render :json => @stops }
			format.xml  { render :xml => @stops }
		end
	end
	
	def show
		@stop = Stop.new(params[:id])
		@time = Time.now
		
		# @arrivals = []
		# @routes = []
		# @stop.routes.each do |r|
		# 	if r.arrivals.length > 0
		# 		r.arrivals.each do |arr|
		# 			r.arrivals.each{|arr| arr.description = r.description.empty? ? r.agency.name : r.description }
		# 			@arrivals << arr
		# 		end
		# 		r.arrivals.sort_by! {|arr| arr.arrival_time }
		# 	else
		# 		@routes << r
		# 	end
		# end
		
		# @arrivals.sort_by! {|arr| arr.arrival_time }
		# @stop.routes.sort_by! {|rt| rt.shortName.to_i }
		
		respond_to do |format|
			format.html
			format.json { render :json => @stop }
			format.xml  { render :xml => @stop }
		end
	end
  
	def schedule
		filter = params[:r].split(',') 
		@stop = Stop.new(params[:id])
    
		@arrivals = []
		@stop.routes.each do |r|
			# allow the user to filter certain routes!
			if filter.empty? or filter.include? r.id or filter.include? r.shortName
				r.arrivals.each{|arr| arr.description = r.description.empty? ? r.agency.name : r.description }
				@arrivals += r.arrivals
			end
		end
		
		@time = Time.now
        @arrivals.sort_by! {|arr| arr.arrival_time }
		
		respond_to do |format|
			format.html { render :partial => "arrival_list" }
			format.json { render :json => @arrivals }
			format.xml  { render :xml => @arrivals }
		end
	end
end
