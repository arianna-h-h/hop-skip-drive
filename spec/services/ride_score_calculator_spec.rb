require 'rails_helper'

RSpec.describe RideScoreCalculator do
  describe '#calculate' do
    let(:ride_score_calculator) { described_class.new }

    context 'when valid addresses are provided' do
      let(:start_address) { '123 Main St, City, State' }
      let(:destination_address) { '456 Elm St, City, State' }
      let(:driver_home_address) { '789 Oak St, City, State' }
      let(:ride_stats) { OpenStruct.new(distance: 10, duration: 1800) }
      let(:commute_stats) { OpenStruct.new(distance: 20, duration: 2200 ) }

      before do
        allow_any_instance_of(GoogleMapsApi).to receive(:fetch_ride_stats).with(start_address, destination_address).and_return(ride_stats)
        allow_any_instance_of(GoogleMapsApi).to receive(:fetch_ride_stats).with(driver_home_address, start_address).and_return(commute_stats)
      end

      it 'calculates the ride score correctly' do
        # Manually calculate the expected score
        earnings = 12
        earnings += (ride_stats.distance - 5) * 1.50 if ride_stats.distance > 5
        earnings += (ride_stats.duration - 15) * 0.70 if ride_stats.duration > 15
        total_duration = commute_stats.duration.to_f + ride_stats.duration.to_f
        expected_score = earnings / total_duration

        expect(ride_score_calculator.calculate(start_address, destination_address, driver_home_address)).to eq(expected_score)
      end
    end

    context 'when an error occurs during calculation' do
      let(:start_address) { '123 Main St, City, State' }
      let(:destination_address) { '456 Elm St, City, State' }
      let(:driver_home_address) { '789 Oak St, City, State' }

      before do
        allow_any_instance_of(GoogleMapsApi).to receive(:fetch_ride_stats).and_raise(StandardError, 'new error')
      end

      it 'returns nil' do
        expect { ride_score_calculator.calculate(start_address, destination_address, driver_home_address) }.to output("Error calculating score new error\n").to_stdout
      end
    end
  end
end
