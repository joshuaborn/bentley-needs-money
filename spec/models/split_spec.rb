require 'rails_helper'

RSpec.describe Split, type: :model do
  describe ".between_two_people" do
    let(:payer) { FactoryBot.create(:person) }
    let(:ower) { FactoryBot.create(:person) }

    context "when amount paid is evenly divisible" do
      subject(:split) do
        attrs = FactoryBot.attributes_for(:split)
        attrs[:amount] = 100
        Split.between_two_people(payer, ower, attrs)
      end

      it "marks the debt as reconciled for the payer, but not the ower, by default" do
        expect(split.debts[0].ower).to eq(ower)
        expect(split.debts[0].owed).to eq(payer)
        expect(split.debts[0].ower_reconciled).to be false
        expect(split.debts[0].owed_reconciled).to be true
      end

      it "gives the ower half the split's amount as debt" do
        expect(split.amount).to eq(100)
        expect(split.debts.length).to eq(1)
        expect(split.debts[0].amount).to eq(50)
      end
    end

    context "when there is an odd cent out and rand() <= 0.5" do
      subject(:split) do
        attrs = FactoryBot.attributes_for(:split)
        attrs[:amount] = 99
        allow(Split).to receive(:rand).and_return(0.25)
        Split.between_two_people(payer, ower, attrs)
      end

      it "gives the one cent discount to the ower" do
        expect(split.amount).to eq(99)
        expect(split.debts.length).to eq(1)
        expect(split.debts[0].amount).to eq(49)
        expect(split.debts[0].ower).to eq(ower)
        expect(split.debts[0].owed).to eq(payer)
      end
    end

    context "when there is an odd cent out and rand() > 0.5" do
      subject(:split) do
        attrs = FactoryBot.attributes_for(:split)
        attrs[:amount] = 99
        allow(Split).to receive(:rand).and_return(0.75)
        Split.between_two_people(payer, ower, attrs)
      end

      it "gives the extra cent to the ower's debt" do
        expect(split.amount).to eq(99)
        expect(split.debts.length).to eq(1)
        expect(split.debts[0].amount).to eq(50)
        expect(split.debts[0].ower).to eq(ower)
        expect(split.debts[0].owed).to eq(payer)
      end
    end
  end
end
