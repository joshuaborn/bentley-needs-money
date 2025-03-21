require 'rails_helper'

RSpec.describe Reason, type: :model do
  subject(:reason) { Reason.new(FactoryBot.attributes_for(:split)) }

  describe "#dollar_amount" do
    it "returns the integer amount in cents as a floating point number in dollars" do
      reason.amount = 17161
      expect(reason.dollar_amount).to eq(171.61)
    end
  end

  describe "#dollar_amount=" do
    it "sets the integer amount in cents from a floating point number in dollars" do
      reason.dollar_amount = 473.21
      expect(reason.amount).to eq(47321)
    end
  end
end
