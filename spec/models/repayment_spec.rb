require 'rails_helper'

RSpec.describe Repayment, type: :model do
  describe ".new" do
    let(:repayer) { FactoryBot.create(:person) }
    let(:repayee) { FactoryBot.create(:person) }
    let(:date) { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    let(:amount) { Faker::Number.number(digits: 4) }
    subject(:repayment) do
      Repayment.new(repayer, repayee, { date: date, amount: amount })
    end

    it 'instantiates an associated debt record with the provided attributes' do
      expect(repayment.date).to eq(date)
      expect(repayment.debts.first.amount).to eq(amount)
      expect(repayment.debts.first.owed).to eq(repayer)
      expect(repayment.debts.first.ower).to eq(repayee)
    end

    it "marks the debt as reconciled for the repayer, but not the repayee, by default" do
      expect(repayment.debts.first.ower_reconciled).to be false
      expect(repayment.debts.first.owed_reconciled).to be true
    end
  end
end
