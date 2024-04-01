class RideScoreCalculator
  def initialize
    @google_maps_api = GoogleMapsApi.new
  end

  def calculate(start_address, destination_address, driver_home_address)
    ride_stats = @google_maps_api.fetch_ride_stats(start_address, destination_address)
    commute_stats = @google_maps_api.fetch_ride_stats(driver_home_address, start_address)
    ride_duration = ride_stats[:duration]
    ride_distance = ride_stats[:distance]
    commute_duration = commute_stats[:duration]
    # Calculate ride earnings
    earnings = 12 + (ride_distance > 5 ? (ride_distance - 5) * 1.50 : 0) + (ride_duration > 15 ? (ride_duration - 15) * 0.70 : 0)

    # Calculate total duration (commute duration + ride duration)
    total_duration = commute_duration + ride_duration

    # Calculate score
    score = earnings / total_duration.to_f
    score
  rescue => e
    puts "Error calculating score #{e.message}"
  end
end
