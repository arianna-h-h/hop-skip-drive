require 'rails_helper'

RSpec.describe RidesController, type: :request do
  describe 'GET /rides' do
    let!(:driver) { create(:driver) }
    let!(:ride1) { create(:ride, driver: driver) }
    let!(:ride2) { create(:ride, start_address: "799 Oak St", driver: driver) }

    context 'when the driver exists' do
      it 'returns a JSON response with ride data' do
        allow_any_instance_of(RideScoreCalculator).to receive(:calculate).with(ride1.start_address, ride1.destination_address, driver.home_address).and_return(75)
        allow_any_instance_of(RideScoreCalculator).to receive(:calculate).with(ride2.start_address, ride2.destination_address, driver.home_address).and_return(100)
        get "/rides", params: { driver_id: driver.id }

        expect(response).to have_http_status(:success)

        rides_data = JSON.parse(response.body)['rides_data']
        expect(rides_data.size).to eq(2)

        ride_data = rides_data.first
        # Ride 2 has the greater score
        expect(ride_data['ride_id']).to eq(ride2.id)
        expect(ride_data).to have_key('ride_score')
      end
    end

    context 'when the driver does not exist' do
      it 'returns a 404 error' do
        get "/rides", params: { driver_id: "100" }

        expect(response).to have_http_status(:not_found)
        error_message = JSON.parse(response.body)['error']
        expect(error_message).to eq('Driver not found')
      end
    end

    context 'when a downstream error occurs' do
      it 'returns a 422 error' do
        allow_any_instance_of(RideScoreCalculator).to receive(:calculate).and_raise(StandardError, 'Calculation error')
        get "/rides", params: { driver_id: driver.id }

        expect(response).to have_http_status(:unprocessable_entity)
        error_message = JSON.parse(response.body)['error']
        expect(error_message).to eq('Calculation error')
      end
    end
  end
end
