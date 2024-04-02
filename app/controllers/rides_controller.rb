class RidesController < ApplicationController
  def index
    driver = Driver.find(params[:driver_id])
    ride_scores = RideScoreCalculator.new(driver).calculate_ordered_scores
    render json: { ride_scores: ride_scores }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Driver not found' }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
