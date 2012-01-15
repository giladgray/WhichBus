require 'rubygems'
require 'route'
require 'stop'

class JourneyHelper

  def calc_routes(from_stops, to_stops)
	result = []
	# go thru each from stop and get routes
	from_stops.each do |fs|
		from_route_ids = fs.routes.map{|r| r.id}
		# caution n squared algorithm need to improve later
		# go thru each to_stop and intersect routes
		to_stops.each do |ts|
			to_route_ids = ts.routes.map{|r| r.id}
			routes = from_route_ids & to_route_ids
			result << routes.map{|r| [fs.id, r.id, ts.id]} if routes.length > 0
		end
	end
	results
  end

end

