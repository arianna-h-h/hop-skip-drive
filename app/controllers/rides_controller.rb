# app/controllers/rides_controller.rb

class RidesController < ApplicationController
  def index
    puts params
    origin_address = params[:origin]
    destination_address = params[:destination]
    maps_service = GoogleMapsApi.new(origin_address, destination_address)
    rides = maps_service.fetch_distance_matrix
    render json: {cats: "yes"}
  end
end
