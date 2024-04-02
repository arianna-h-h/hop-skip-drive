require 'rails_helper'

RSpec.describe RidesController, type: :controller do
  describe 'GET #index' do
    context 'when driver exists' do
      let!(:driver) { create(:driver) }
      let!(:ride1) { create(:ride, driver: driver) }
      let!(:ride2) { create(:ride, driver: driver) }
      let!(:ride_scores) {[ 
        { ride_id: 2, ride_score: 5 }, 
        { ride_id: 1, ride_score: 4 }
        ]}

      before do
        allow(Driver).to receive(:find).with(driver.id.to_s).and_return(driver)
        allow_any_instance_of(RideScoreCalculator).to receive(:calculate_ordered_scores).and_return(ride_scores)
        get :index, params: { driver_id: driver.id }
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns rides sorted by score in descending order' do
        ride_scores = JSON.parse(response.body)['ride_scores']
        expect(ride_scores.length).to eq(2)
        expect(ride_scores[0]['ride_id']).to eq(ride2.id)
        expect(ride_scores[1]['ride_id']).to eq(ride1.id)
        expect(ride_scores[0]['ride_score']).to be > ride_scores[1]['ride_score']
      end
    end

    context 'when driver does not exist' do
      before { get :index, params: { driver_id: -1 } }

      it 'returns a not found response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)['error']).to eq('Driver not found')
      end
    end
  end
end
