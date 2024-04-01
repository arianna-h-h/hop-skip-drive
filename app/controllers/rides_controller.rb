class RidesController < ApplicationController
  def index
    puts params
    driver = Driver.find(params[:driver_id])
    ride_score_calculator = RideScoreCalculator.new
    rides_with_scores = []
      puts "rides #{driver.rides.inspect}"

    driver.rides.each do |ride|
      ride_score = ride_score_calculator.calculate(ride.start_address, ride.destination_address, driver.home_address)
      ride_data = {
        ride_id: ride.id,
        ride_score: ride_score
      }
      puts "ride data #{ride_data}"
      rides_with_scores << ride_data
    end
    sorted_rides = rides_with_scores.sort_by { |ride_data| ride_data[:ride_score] }.reverse
    puts "rides data #{sorted_rides}"
  
    render json: {rides_data: sorted_rides }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Driver not found' }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
