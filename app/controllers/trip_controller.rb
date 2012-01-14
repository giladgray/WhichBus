class TripController < ApplicationController
	def index
	end
	
	def show
		@trip = Trip.new(params[:id])
	end
end
