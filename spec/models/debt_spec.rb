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

    describe "#dollar_cumulative_sum" do
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

  context "callback" do
    let(:first_person) { FactoryBot.create(:person) }
    let(:second_person) { FactoryBot.create(:person) }
    let(:debts) { Debt.between_people(first_person, second_person).joins(:reason).order(reason: { date: :asc }) }

    before do
      previous_amounts.each_with_index do |amount, i|
        date = ((previous_amounts.length - i) * 2).days.ago
        if amount < 0
          create_debt_on_day(ower: second_person, owed: first_person, amount: -1 * amount, date: date)
        else
          create_debt_on_day(ower: first_person, owed: second_person, amount: amount, date: date)
        end
      end
    end

    describe "before_save :set_cumulative_sums_before_save" do
      context "when a debt is first created between two people" do
        subject(:debt) do
          create_debt_on_day(ower: first_person, owed: second_person, amount: 1000, date: Date.today)
        end
        let(:previous_amounts) { [] }

        it "has a cumulative sum set to its own amount" do
          expect(debt.cumulative_sum).to eq(1000)
        end
      end

      context "when a debt is created on a date after all existing ones" do
        subject(:debt) do
          create_debt_on_day(ower: first_person, owed: second_person, amount: 1000, date: Date.today)
        end
        let(:previous_amounts) { [ 5000, -7500, 10000, 12500, -15000 ] }

        it "has a cumulative sum equal to the sum of all debts thus far plus its own amount" do
          expect(debts.first(previous_amounts.length).map(&:cumulative_sum)).to eq([ 5000, 2500, 7500, 20000, -5000 ])
          expect(debt.cumulative_sum).to eq(6000)
        end
      end

      context "when a debt is created on a date before all existing ones" do
        subject(:debt) do
          create_debt_on_day(ower: first_person, owed: second_person, amount: 1000, date: (previous_amounts.length * 2 + 1).days.ago)
        end
        let(:previous_amounts) { [ 5000, -10000, 15000 ] }

        it "changes the cumulative sum of each debt by its amount" do
          expect(debt.cumulative_sum).to eq(debt.amount)
          expect(debts.last(previous_amounts.length).map(&:cumulative_sum)).to eq([ 6000, 4000, 11000 ])
        end
      end

      context "when a debt is created on a date in between existing debts' dates" do
        subject(:debt) do
          create_debt_on_day(ower: first_person, owed: second_person, amount: 1000, date: (previous_amounts.length * 2 - 1).days.ago)
        end
        let(:previous_amounts) { [ 5000, -10000, 15000 ] }

        it "increases the cumulative sum of the debts that come after, but not that come before " do
          expect(debt.cumulative_sum).to eq(6000)
          expect(debts.map(&:cumulative_sum)).to eq([ 5000, 6000, 4000, 11000 ])
        end
      end

      context "when a debt is updated" do
        let(:previous_amounts) { [ 5000, -10000, 15000, 20000, -25000 ] }

        it "changes cumulative sum of the debts that come after, but not before " do
          expect(debts.map(&:cumulative_sum)).to eq([ 5000, 5000, 10000, 30000, -5000 ])
          debts[2].update(amount: 5000)
          expect(debts.map { |debt| debt.reload.cumulative_sum }).to eq([ 5000, 5000, 0, 20000, 5000 ])
        end
      end
    end

    describe "after_destroy :set_cumulative_sums_after_destroy" do
      let(:previous_amounts) { [ 5000, -10000, 15000 ] }

      context "when the earliest debt is deleted" do
        it "decreases the cumulative sum of the remaining debts" do
          debts[0].destroy
          expect(debts[1].reload.cumulative_sum).to eq(10000)
          expect(debts[2].reload.cumulative_sum).to eq(5000)
        end
      end

      context "when a debt whose date is in between others is deleted" do
        it "decreases the cumulative sum of debts that come after, but not before" do
          debts[1].destroy
          expect(debts[0].reload.cumulative_sum).to eq(5000)
          expect(debts[2].reload.cumulative_sum).to eq(20000)
        end
      end

      context "when the latest debt is deleted" do
        it "does not change cumulative sum of any debts" do
          debts[2].destroy
          expect(debts[0].reload.cumulative_sum).to eq(5000)
          expect(debts[1].reload.cumulative_sum).to eq(5000)
        end
      end
    end
  end
end
