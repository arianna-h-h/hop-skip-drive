require 'rails_helper'
require 'webmock/rspec'

RSpec.describe GoogleMapsApi do
  describe '#fetch_ride_stats' do
    let(:api_key) { 'fake_api_key' }
    let(:base_url) { 'https://maps.googleapis.com/maps/api/distancematrix/json?' }
    let(:google_maps_api) { described_class.new }

    before do
      allow(ENV).to receive(:fetch).with('MAPS_API_KEY').and_return(api_key)
      allow(ENV).to receive(:fetch).with('MAPS_BASE_URL').and_return(base_url)
    end

    context 'when the API request is successful' do
      let(:origin) { '123 Main St, City, State' }
      let(:destination) { '456 Elm St, City, State' }
      let(:response_body) do
        {
          "destination_addresses": ["456 Elm St, City, State"],
          "origin_addresses": ["123 Main St, City, State"],
          "rows": [
            {
              "elements": [
                {
				  "distance": {
				  "text": "6 mi",
				  "value": 9656
				  },
				  "duration": {
				  "text": "3 mins",
				  "value": 200
				  },
                  "status": element_status
                },
              ],
            }
          ],
          "status": "OK"
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}origins=#{URI.encode_www_form_component(origin)}&destinations=#{URI.encode_www_form_component(destination)}&units=imperial&key=#{api_key}").
         to_return(status: 200, body: response_body, headers: {})
      end

      context 'when the element status is "OK"' do
        let(:element_status) { "OK" }

        it 'fetches and parses the ride stats' do
          expect(google_maps_api.fetch_ride_stats(origin, destination)).to eq({ distance: 9656, duration: 200 })
        end
      end

      context 'when the element status is "NOT_FOUND"' do
        let(:element_status) { "NOT_FOUND" }

        it 'handles the case where the destination was not found' do
          expect { google_maps_api.fetch_ride_stats(origin, destination) }.to output("Error fetching maps data: Address not found\n").to_stdout
        end
      end
    end

    context 'when the API request fails' do
      before do
        stub_request(:get, "#{base_url}origins=#{URI.encode_www_form_component("")}&destinations=#{URI.encode_www_form_component("")}&units=imperial&key=#{api_key}")
          .to_return(status: 500, body: 'Internal Server Error', headers: {})
      end

      it 'handles the failure gracefully' do
        expect { google_maps_api.fetch_ride_stats('', '') }.to output("API request failed with status code: 500\n").to_stdout
      end
    end

    context 'when an error occurs during parsing' do
      let(:response_body) { 'invalid_json' }

      before do
        stub_request(:get, "#{base_url}origins=&destinations=&units=imperial&key=#{api_key}")
          .to_return(status: 200, body: response_body)
      end

      it 'handles the parsing error' do
        expect { google_maps_api.fetch_ride_stats('', '') }.to output(/Error fetching maps data: unexpected token at 'invalid_json'\n/).to_stdout
      end
    end
  end
end
