class RideScoreCalculator
  def initialize(driver)
    @google_maps_api = GoogleMapsApi.new
    @driver = driver
  end

  def calculate_ordered_scores
    unordered_scores = @driver.rides.map do |ride|
      ride_score = calculate_ride_score(ride)
      { ride_id: ride.id, ride_score: ride_score }
    end
    ordered_scores = sort_ride_scores(unordered_scores)
    ordered_scores
  rescue StandardError => e
    puts "Error calculating score: #{e.message}"
  end

  private

  def calculate_ride_score(ride)
    start_address = ride.start_address
    destination_address = ride.destination_address
    driver_home_address = @driver.home_address
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
  end

  def sort_ride_scores(unordered_scores)
    unordered_scores.sort_by { |ride_data| ride_data[:ride_score] }.reverse
  end
end
