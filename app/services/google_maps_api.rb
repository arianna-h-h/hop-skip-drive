require 'net/http'
require 'json'

class GoogleMapsApi
  def initialize(origin, destination)
    @origin = origin
    @destination = destination
    puts "in init #{@origin} #{@destination}"
  end

  def fetch_distance_matrix
    origin_params = URI.encode_www_form({origins: @origin})
    destination_params = URI.encode_www_form({destinations: @destination})
    api_key = ENV.fetch('MAPS_API_KEY')
    base_url = ENV.fetch('MAPS_BASE_URL')
    url = "#{base_url}#{origin_params}&#{destination_params}&units=imperial&key=#{api_key}"
    puts url
    response = Net::HTTP.get_response(URI(url))
    puts "response #{response.body}"
    if response.is_a?(Net::HTTPSuccess)
        puts "successful"
    #   parse_geocode_response(response.body)
    else
      puts "API request failed with status code: #{response.code}"
      nil
    end
  rescue => e
    puts "Error fetching geocoded data: #{e.message}"
  end

  private 
  def parse_geocode_response

  end 
end 
