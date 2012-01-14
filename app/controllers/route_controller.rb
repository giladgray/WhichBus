class RouteController < ApplicationController
	def index
	end
	
	def show
		@route = Route.new(params[:id])
	end
end
