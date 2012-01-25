class StopController < ApplicationController
	
	def index
    @user_location = request.location
    
		@stops = Stop.by_location(@user_location.latitude, @user_location.longitude)
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
  
  def schedule
    @stop = Stop.new(params[:id])
    
    @arrivals = []
    @stop.routes.each do |r|
      if r.arrivals.length > 0
        @arrivals += r.arrivals
      end
    end
    
    respond_to do |format|
      format.html { redirect_to stop_path }
      format.json { render :json => @arrivals }
      format.xml  { render :xml => @arrivals }
    end
  end
end
