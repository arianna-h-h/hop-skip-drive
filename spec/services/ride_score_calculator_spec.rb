require 'rails_helper'

RSpec.describe RideScoreCalculator do
  describe '#calculate_ordered_scores' do
    let(:driver) { create(:driver) }
    let!(:ride1) { create(:ride, destination_address: "123 Main St, City, State", driver: driver) }
    let!(:ride2) { create(:ride, driver: driver) }
    let!(:ride_score_calculator) { described_class.new(driver) }

    context 'when valid addresses are provided' do
      let(:ride1_stats) { { "distance": 10, "duration": 1800 } }
      let(:ride2_stats) { { "distance": 20, "duration": 3000 } }
      let(:commute1_stats) { { "distance": 10, "duration": 1000 } }
      let(:commute2_stats) { { "distance": 24, "duration": 2400 } }

      before do
        allow_any_instance_of(GoogleMapsApi).to receive(:fetch_ride_stats).with(ride1.start_address, ride1.destination_address).and_return(ride1_stats)
        allow_any_instance_of(GoogleMapsApi).to receive(:fetch_ride_stats).with(driver.home_address, ride1.start_address).and_return(commute1_stats)
        allow_any_instance_of(GoogleMapsApi).to receive(:fetch_ride_stats).with(ride2.start_address, ride2.destination_address).and_return(ride2_stats)
        allow_any_instance_of(GoogleMapsApi).to receive(:fetch_ride_stats).with(driver.home_address, ride2.start_address).and_return(commute2_stats)
      end

      it 'calculates the ride scores correctly in descending order' do
        ride_scores = ride_score_calculator.calculate_ordered_scores
        expect(ride_scores[0][:ride_id]).to eq(ride2.id)
        expect(ride_scores[1][:ride_id]).to eq(ride1.id)
      end
    end

    context 'when an error occurs during calculation' do

      before do
        allow_any_instance_of(GoogleMapsApi).to receive(:fetch_ride_stats).and_raise(StandardError, 'new error')
      end

      it 'returns nil' do
        expect { ride_score_calculator.calculate_ordered_scores }.to output("Error calculating score: new error\n").to_stdout
      end
    end
  end
end
