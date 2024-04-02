require 'net/http'
require 'json'

class GoogleMapsApi
  def fetch_ride_stats(origin, destination)
    url = build_url(origin, destination)
    response = Net::HTTP.get_response(URI(url))
    handle_response(response)
  rescue => e
    puts "Error fetching maps data: #{e.message}"
  end

  private

  def build_url(origin, destination)
    api_key = ENV.fetch('MAPS_API_KEY')
    base_url = ENV.fetch('MAPS_BASE_URL')
    origin_params = URI.encode_www_form({ origins: origin })
    destination_params = URI.encode_www_form({ destinations: destination })
    "#{base_url}#{origin_params}&#{destination_params}&units=imperial&key=#{api_key}"
  end

  def handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      extract_distance_and_duration(parsed_response)
    else
      puts "API request failed with status code: #{response.code}"
      nil
    end
  end

  def extract_distance_and_duration(response)
    first_element = response["rows"][0]["elements"][0]
    raise AddressNotFoundError if first_element["status"] == "NOT_FOUND"
    begin
      distance = first_element["distance"]["value"]
      duration = first_element["duration"]["value"]
      { distance: distance, duration: duration }
    rescue => e
      puts "Error parsing response: #{e.message}"
    end
  end
end 
