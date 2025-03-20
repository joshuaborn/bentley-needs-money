require 'rails_helper'

RSpec.describe Reason, type: :model do
  subject(:reason) { Reason.new(FactoryBot.attributes_for(:split)) }

  describe "#people" do
    let(:person_one) { FactoryBot.create(:person) }
    let(:person_two) { FactoryBot.create(:person) }
    let(:person_three) { FactoryBot.create(:person) }
    let(:person_four) { FactoryBot.create(:person) }

    it "returns the union of the oweds and owers associations" do
      reason.debts.new(FactoryBot.attributes_for(:debt).merge({ ower: person_one, owed: person_two }))
      reason.debts.new(FactoryBot.attributes_for(:debt).merge({ ower: person_two, owed: person_three }))
      reason.save!
      expect(reason.people).to contain_exactly(person_one, person_two, person_three)
    end
  end

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
