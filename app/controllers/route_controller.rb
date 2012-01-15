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
end
