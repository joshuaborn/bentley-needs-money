require 'rails_helper'

RSpec.describe Repayment, type: :model do
  describe ".new" do
    let(:repayer) { FactoryBot.create(:person) }
    let(:repayee) { FactoryBot.create(:person) }
    let(:date) { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    let(:amount) { Faker::Number.between(from: 1, to: 100000) }
    subject(:repayment) do
      Repayment.new({ repayer: repayer, repayee: repayee, date: date, amount: amount })
    end

    it 'instantiates an associated debt record' do
      expect(repayment.date).to eq(date)
      expect(repayment.debts.first.amount).to eq(amount)
      expect(repayment.debts.first.owed).to eq(repayer)
      expect(repayment.debts.first.ower).to eq(repayee)
    end
  end
end
