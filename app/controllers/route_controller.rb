class RouteController < ApplicationController
	def index
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
end
