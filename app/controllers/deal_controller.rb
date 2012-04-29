require 'rubygems'
require 'json'
require 'net/http'

class DealController < ApplicationController

	def find_by_city
		request = "http://api.sandbox.yellowapi.com/FindBusiness/?what=taxi&where="+params[:city]+"&fmt=JSON&pgLen=5&apikey=jnnfxbdaedm9nbnrxkzbe5mx&UID=2"
		data = Net::HTTP.get_response(URI.parse(request))
		deals = JSON.parse(data.response.body)
		deals =deals["listings"]

		respond_to do |format| 
			format.json { render :json => deals }
			format.xml  { render :xml  => deals }
		end

	end

end
