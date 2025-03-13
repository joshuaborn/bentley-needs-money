require 'rails_helper'

RSpec.describe Debt, type: :model do
  context "instance method" do
    subject(:debt) { FactoryBot.build(:debt) }

    describe "#dollar_amount" do
      it "returns the integer amount in cents as a floating point number in dollars" do
        debt.amount = 17161
        expect(debt.dollar_amount).to eq(171.61)
      end
    end

    describe "#dollar_amount=" do
      it "sets the integer amount in cents from a floating point number in dollars" do
        debt.dollar_amount = 473.21
        expect(debt.amount).to eq(47321)
      end
    end

    describe "#cumulative_sum" do
      it "returns the integer cumulative sum in cents as a floating point number in dollars" do
        debt.cumulative_sum = 39432
        expect(debt.dollar_cumulative_sum).to eq(394.32)
      end
    end
  end

  context "class method" do
    let(:first_person) { FactoryBot.create(:person) }
    let(:second_person) { FactoryBot.create(:person) }
    let(:other_person) { FactoryBot.create(:person) }
    let(:yet_another_person) { FactoryBot.create(:person) }

    before do
      3.times do
        FactoryBot.create(:debt, ower: first_person, owed: second_person)
        FactoryBot.create(:debt, ower: second_person, owed: first_person)
        FactoryBot.create(:debt, ower: first_person, owed: other_person)
        FactoryBot.create(:debt, ower: other_person, owed: first_person)
        FactoryBot.create(:debt, ower: second_person, owed: other_person)
        FactoryBot.create(:debt, ower: other_person, owed: second_person)
        FactoryBot.create(:debt, ower: yet_another_person, owed: other_person)
        FactoryBot.create(:debt, ower: other_person, owed: yet_another_person)
      end
    end

    describe ".for_person" do
      it "returns debts for which the person is the ower" do
        expect(Debt.for_person(first_person)).to include(*Debt.where(ower: first_person))
      end

      it "returns debts for which the person is the owed person" do
        expect(Debt.for_person(first_person)).to include(*Debt.where(owed: first_person))
      end

      it "does not return debts for which the person is neither the ower or the owed person" do
        expect(Debt.for_person(first_person)).not_to include(*Debt.where.not(owed: first_person).and(Debt.where.not(ower: first_person)))
      end
    end

    describe ".between_people" do
      it "returns debts for which the first argument is the ower and the second argument is the owed person" do
        expect(Debt.between_people(first_person, second_person)).to include(*Debt.where(ower: first_person, owed: second_person))
      end

      it "returns debts for which the first argument is the owed person and the second argument is the ower" do
        expect(Debt.between_people(first_person, second_person)).to include(*Debt.where(ower: second_person, owed: first_person))
      end

      it "does not return debts for which the owed person is neither other the arguments" do
        expect(Debt.between_people(first_person, second_person)).not_to include(*Debt.where.not(owed: first_person).and(Debt.where.not(owed: second_person)))
      end
    end
  end
end
