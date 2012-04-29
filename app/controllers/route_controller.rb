class RouteController < ApplicationController

	def index
        if params.has_key?("lat") and params.has_key?("lon")
            @routes = Route.by_location(params[:lat], params[:lon], params[:query])
        end
			
		respond_to do |format|
			format.html { 
				if params.has_key?("api")
					render :partial => "stop_list"
				else
					render
				end
			}  
			format.json { render :json => @routes }
			format.xml  { render :xml => @routes }
		end
	end
	
	def show
		@route = Route.new(params[:id])
		
		respond_to do |format|
			format.html
			format.json { render :json => @route }
			format.xml  { render :xml => @route }
		end
	end

	def trips
		@route = Route.new(params[:id])
		@trips = @route.trips

		respond_to do |format|
			format.html { redirect_to route_path(params[:id]) }
			format.json { render :json => { :route => @route, :trips => @route.trips } }
			format.xml  { render :xml => { :route => @route, :trips => @trips } }
		end
	end

  def favorite
    if user_signed_in?
      # TODO: Only save one favorite for the user.
      @favorite = Favorite.new({
        favorable_id: params[:id],
        favorable_type: 'Route',
        user: current_user
      })
      @favorite.save()
    end
    respond_to do |format|
      format.json { render json: {} }
      format.xml  { render xml: {} }
    end
  end
end
