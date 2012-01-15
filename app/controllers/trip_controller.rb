class TripController < ApplicationController
	def index
	end
	
	def show
		@trip = Trip.new(params[:id])
		
		respond_to do |format|
			format.html
			format.json { render :json => @trip }
			format.xml  { render :xml => @trip }
		end
	end
end
