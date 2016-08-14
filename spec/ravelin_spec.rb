require 'spec_helper'

describe Ravelin do
  it 'has a version number' do
    expect(Ravelin::VERSION).not_to be nil
  end

  describe '.convert_to_epoch' do
    subject { described_class.convert_to_epoch(value) }

    context 'with a Time value' do
      let(:value) { Time.new(2016, 1, 1, 0, 1, 0, '+00:00') }

      it { is_expected.to eq 1451606460 }
    end

    context 'with a Date value' do
      let(:value) { Date.new(2016, 1, 1) }

      it { is_expected.to eq 1451606400 }
    end

    context 'with a DateTime value' do
      let(:value) { DateTime.new(2016, 1, 2, 0, 1, 0, '+00:00') }

      it { is_expected.to eq 1451692860 }
    end

    context 'with a Integer value' do
      let(:value) { 1234 }

      it { is_expected.to eq 1234 }
    end

    context 'with an unknown value' do
      let(:value) { "not valid" }

      it { expect { subject }.to raise_error(TypeError) }
    end
  end
end
