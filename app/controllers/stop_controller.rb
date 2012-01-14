class StopController < ApplicationController
	def index
	end
	
	def show
		@stop = Stop.new(params[:id])
		title = "Stop " + @stop.name
	end
end
