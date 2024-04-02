require 'rails_helper'

RSpec.describe RidesController, type: :request do
  describe 'GET /rides' do
    let!(:driver) { create(:driver) }
    let!(:ride1) { create(:ride, driver: driver) }
    let!(:ride2) { create(:ride, start_address: "799 Oak St", driver: driver) }
    let!(:ride_scores) {[
        { ride_id: 2, ride_score: 10 },
        { ride_id: 1, ride_score: 4 }
    ]}

    context 'when the driver exists' do
      it 'returns a JSON response with ride data' do
        allow_any_instance_of(RideScoreCalculator).to receive(:calculate_ordered_scores).and_return(ride_scores)
        get "/rides", params: { driver_id: driver.id }

        expect(response).to have_http_status(:success)

        ride_scores = JSON.parse(response.body)['ride_scores']
        expect(ride_scores.size).to eq(2)

        ride_score = ride_scores.first
        # Ride 2 has the greater score
        expect(ride_score['ride_id']).to eq(ride2.id)
        expect(ride_score).to have_key('ride_score')
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
        allow_any_instance_of(RideScoreCalculator).to receive(:calculate_ordered_scores).and_raise(StandardError, 'Calculation error')
        get "/rides", params: { driver_id: driver.id }

        expect(response).to have_http_status(:unprocessable_entity)
        error_message = JSON.parse(response.body)['error']
        expect(error_message).to eq('Calculation error')
      end
    end
  end
end
