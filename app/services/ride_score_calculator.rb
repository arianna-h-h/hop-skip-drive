class RideScoreCalculator
  def initialize(driver)
    @google_maps_api = GoogleMapsApi.new
    @driver = driver
  end

  def calculate_ordered_scores
    unordered_scores = @driver.rides.map do |ride|
      ride_score = calculate_ride_score(ride)
    end
    ordered_scores = sort_ride_scores(unordered_scores)
    ordered_scores
  rescue StandardError => e
    puts "Error calculating score: #{e.message}"
  end

  private

  def calculate_ride_score(ride)
    ride_stats = @google_maps_api.fetch_ride_stats(ride.start_address, ride.destination_address)
    commute_stats = @google_maps_api.fetch_ride_stats(@driver.home_address, ride.start_address)
    
    ride_duration = ride_stats[:duration]
    ride_distance = ride_stats[:distance]
    commute_duration = commute_stats[:duration]
    
    earnings = calculate_earnings(ride_distance, ride_duration)
    total_duration = ride_duration + commute_duration
    score = calculate_score(earnings, total_duration)
    score
    { ride_id: ride.id, ride_score: score }
  end

  def calculate_earnings(distance, duration)
    base_earnings = 12
    distance_earnings = [0, (distance - 5) * 1.50].max
    duration_earnings = [0, (duration - 15) * 0.70].max
    base_earnings + distance_earnings + duration_earnings
  end

  def calculate_score(earnings, total_duration)
    earnings / total_duration.to_f
  end

  def sort_ride_scores(unordered_scores)
    unordered_scores.sort_by { |ride_data| ride_data[:ride_score] }.reverse
  end
end
