require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe ".split_between_two_people" do
    let(:current_user) { FactoryBot.create(:person) }
    let(:other_user) { FactoryBot.create(:person) }

    context "when amount paid is evenly divisible" do
      subject(:expense) do
        attrs = FactoryBot.attributes_for(:expense)
        attrs[:amount_paid] = 100
        Expense.split_between_two_people(current_user, other_user, attrs)
      end

      it "splits the amount paid into two equal amounts" do
        expect(expense.amount_paid).to eq(100)
        expect(expense.person_transfers[0].amount).to eq(50)
        expect(expense.person_transfers[1].amount).to eq(-50)
      end
    end

    context "when there is an odd cent out and rand() <= 0.5" do
      subject(:expense) do
        attrs = FactoryBot.attributes_for(:expense)
        attrs[:amount_paid] = 99
        allow(Expense).to receive(:rand).and_return(0.25)
        Expense.split_between_two_people(current_user, other_user, attrs)
      end

      it "assigns the extra cent to the payer" do
        expect(expense.amount_paid).to eq(99)
        expect(expense.person_transfers[0].amount).to eq(49)
        expect(expense.person_transfers[1].amount).to eq(-50)
      end
    end

    context "when there is an odd cent out and rand() > 0.5" do
      subject(:expense) do
        attrs = FactoryBot.attributes_for(:expense)
        attrs[:amount_paid] = 99
        allow(Expense).to receive(:rand).and_return(0.75)
        Expense.split_between_two_people(current_user, other_user, attrs)
      end

      it "assigns the extra cent to the payee" do
        expect(expense.amount_paid).to eq(99)
        expect(expense.person_transfers[0].amount).to eq(50)
        expect(expense.person_transfers[1].amount).to eq(-49)
      end
    end
  end

  describe ".find_between_two_people" do
    let(:current_user) { FactoryBot.create(:person) }
    let(:other_user) { FactoryBot.create(:person) }
    let(:yet_another_user) { FactoryBot.create(:person) }

    it "returns just the transfers between two people" do
      3.times do
        Expense.split_between_two_people(
          current_user,
          other_user,
          FactoryBot.attributes_for(:expense)
        ).save!
        Expense.split_between_two_people(
          other_user,
          current_user,
          FactoryBot.attributes_for(:expense)
        ).save!
        Expense.split_between_two_people(
          other_user,
          yet_another_user,
          FactoryBot.attributes_for(:expense)
        ).save!
        Expense.split_between_two_people(
          yet_another_user,
          other_user,
          FactoryBot.attributes_for(:expense)
        ).save!
        Expense.split_between_two_people(
          yet_another_user,
          current_user,
          FactoryBot.attributes_for(:expense)
        ).save!
        Expense.split_between_two_people(
          current_user,
          yet_another_user,
          FactoryBot.attributes_for(:expense)
        ).save!
      end

      expect(
        Expense.find_between_two_people(current_user, other_user)
      ).to contain_exactly(*(current_user.transfers & other_user.transfers))
    end
  end
end
