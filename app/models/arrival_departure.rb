require 'rubygems'
require 'json'
require 'net/http'
require 'ostruct'
require 'onebus_record'

class ArrivalDeparture < OneBusRecord
  @@time_format = "%l:%M%P"

  attr_accessor :description

  # returns the predicted arrival time if it exists, otherwise returns scheduled
  def arrival_time
    prediction? ? (data.predictedArrivalTime / 1000) : (data.scheduledArrivalTime / 1000)
  end

  # returns the predicted departure time if it exists, otherwise returns scheduled
  def departure_time
    prediction? ? (data.predictedDepartureTime / 1000) : (data.scheduledDepartureTime / 1000)
  end

  def prediction?
    predictedDepartureTime > 0
  end

  def all_times
    "#{scheduled_arrival_time}/#{predicted_arrival_time} => #{scheduled_departure_time}/#{predicted_departure_time}"
  end

  def self.convert_time(time)
    Time.at(time).strftime(@@time_format)
  end

  def display_arrival_time
    self.class.convert_time(arrival_time)
  end

  def display_departure_time
    self.class.convert_time(departure_time)
  end

  ##
  def predicted_arrival_time
    self.class.convert_time(data.predictedArrivalTime / 1000)
  end

  def predicted_departure_time
    self.class.convert_time(data.predictedDepartureTime / 1000)
  end

  def scheduled_arrival_time
    Time.at(data.scheduledArrivalTime / 1000).strftime(@@time_format)
  end

  def scheduled_departure_time
    Time.at(data.scheduledDepartureTime / 1000).strftime(@@time_format)
  end

  ##

  def time_to_arrival(from_time = Time.now)
    Time.at(arrival_time) - from_time
  end

  def time_to_departure(from_time = Time.now)
    Time.at(departure_time) - from_time
  end

  def time_to_arrival_in_words(from_time = Time.now)
    self.class.time_to_words_short(time_to_arrival(from_time) / 60)
  end

  def time_to_departure_in_words(from_time = Time.now)
    self.class.time_to_words_short(time_to_departure(from_time) / 60)
  end

  def css_class_for_arrival_time(from_time = Time.now)
    case time_to_departure(from_time) / 60
      when -1000...0
        "gone"
      when 0...7
        "now"
      when 7...15
        "soon"
      when 15...31
        "soonish"
      else
        "later"
    end
  end

  def prediction_difference_minutes
    change = (arrival_time - data.scheduledArrivalTime / 1000) / (1000 * 60)
  end

  def prediction_difference
    change = prediction_difference_minutes
    case
      when change == 0
        prediction? ? "on time" : "schedule"
      when change < 0
        "#{-change}m early"
      else
        "#{change}m late"
    end
  end

  def predicted_departure_difference
    change = (data.predictedDepartureTime - data.scheduledArrivalTime) / (1000 * 60)
    case
      when change == 0
        "on time"
      when change < 0
        "#{-change}m early"
      else
        "#{change}m late"
    end
  end

  def css_class_for_time_difference
    change = prediction_difference_minutes
    case
      when change == 0
        "gone"
      when change < 0
        "early"
      else
        "late"
    end
  end

  def self.time_to_words_short(minutes, signed=true)
    result = (minutes < 0 and signed) ? "-" : ""
    minutes = minutes.to_int.abs
    case
      when minutes <= 1
        result = "now!"
      when minutes < 60
        result << "#{minutes}m"
      when minutes < (60*24)
        hours = (minutes / 60).round
        mins = minutes%60
        result << "#{hours}h"
        result << ",#{mins}m" if mins > 0
      else
        # TODO: days, hours, minutes
        result << "#{(minutes / 1440).round}d"
    end
    result
  end

  def as_json(options={})
    result = super(options)
    result[:arrival] = display_arrival_time
    result[:wait_minutes] = time_to_arrival / 60
    result[:wait_time] = time_to_arrival_in_words
    result[:status] = prediction_difference
    result[:description] = description
    result
  end
end
