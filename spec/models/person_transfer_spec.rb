require 'rails_helper'
require 'support/build_expenses_for_tests.rb'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe PersonTransfer, type: :model do
  describe "#dollar_amount" do
    subject(:person_transfer) { PersonTransfer.new(amount: 731) }

    it "returns amount paid in dollars" do
      expect(person_transfer.dollar_amount).to eq(7.31)
    end
  end

  describe "#dollar_amount=" do
    subject(:person_transfer) { PersonTransfer.new(dollar_amount: 7.31) }

    it "sets amount paid in dollars" do
      expect(person_transfer.amount).to eq(731)
    end
  end

  context "with a transfer connecting two person transfers in the data store" do
    subject(:transfer) { create_valid_transfer }
    let(:this_person_transfer) { transfer.person_transfers[0] }
    let(:other_person_transfer) { transfer.person_transfers[1] }

    describe "#other_person_transfer" do
      it "gets the other person transfer" do
        expect(this_person_transfer.other_person_transfer).to eq(other_person_transfer)
      end
    end

    describe "#other_person" do
      it "gets the other person" do
        expect(this_person_transfer.other_person).to eq(other_person_transfer.person)
      end
    end
  end

  describe "#dollar_cumulative_sum" do
    subject(:person_transfer) { PersonTransfer.new(cumulative_sum: 731) }

    it "returns cumulative sum in dollars" do
      expect(person_transfer.dollar_cumulative_sum).to eq(7.31)
    end
  end

  context "with transfers connecting 3 people in the data store" do
    let(:current_user) { FactoryBot.create(:person) }
    let(:other_user) { FactoryBot.create(:person) }
    let(:yet_another_user) { FactoryBot.create(:person) }

    before { build_expenses_for_tests(current_user, other_user, yet_another_user) }

    describe ".find_for_person_with_other_person" do
      it "returns just the person transfers between two people" do
        expect(
          PersonTransfer.find_for_person_with_other_person(current_user, other_user)
        ).to contain_exactly(*(
          current_user.person_transfers.select do |person_transfer|
            person_transfer.other_person == other_user
          end
        ))
      end
    end

    describe ".get_amounts_owed_for" do
      it "returns the most recent person transfer for each other person" do
        expect(PersonTransfer.get_amounts_owed_for(current_user)).to eq([
          PersonTransfer.find_for_person_with_other_person(other_user, current_user).last,
          PersonTransfer.find_for_person_with_other_person(yet_another_user, current_user).last
        ])
      end
    end
  end

  context "with previously created person transfers" do
    let(:current_user) { FactoryBot.create(:person) }
    let(:other_user) { FactoryBot.create(:person) }

    before do
      previous_amounts.each_with_index do |amount, i|
        create_person_transfer_between_people(current_user, other_user, amount, i.days.ago)
      end
    end

    describe "before_save :set_cumulative_sums_before_save" do
      context "when a person transfer is first created between two people" do
        subject(:person_transfer) do
          create_person_transfer_between_people(current_user, other_user, 1000)
        end
        let(:previous_amounts) { [] }

        it "has a cumulative sum set to its own amount" do
          expect(person_transfer.cumulative_sum).to eq(1000)
        end
      end

      context "when a person transfer is created on a date after all previous ones" do
        subject(:person_transfer) do
          create_person_transfer_between_people(current_user, other_user, 1000)
        end
        let(:previous_amounts) { [ 5000, 10000, 15000 ] }

        it "has a cumulative sum equal to the sum of all person transfers thus far plus its own amount" do
          expect(person_transfer.cumulative_sum).to eq(previous_amounts.sum + person_transfer.amount)
        end
      end

      context "when a person transfer is created on a date before all previous ones" do
        subject(:person_transfer) do
          create_person_transfer_between_people(current_user, other_user, 1000, 4.days.ago)
        end
        let(:previous_amounts) { [ 5000, 10000, 15000 ] }

        it "increases the cumulative sum of the each person transfers by its amount" do
          expect(person_transfer.cumulative_sum).to eq(1000)
          person_transfers = PersonTransfer.find_for_person_with_other_person(current_user, other_user)
          expect(person_transfers[1].cumulative_sum).to eq(16000)
          expect(person_transfers[2].cumulative_sum).to eq(26000)
          expect(person_transfers[3].cumulative_sum).to eq(31000)
        end
      end

      context "when a person transfer is created on a date in between previous ones" do
        subject(:person_transfer) do
          create_person_transfer_between_people(current_user, other_user, 1000, 4.days.ago)
        end
        let(:previous_amounts) { [ 5000, 10000, 15000 ] }

        it "increases the cumulative sum of the person transfers that come after, but not that come before " do
          create_person_transfer_between_people(current_user, other_user, 2000, 5.days.ago)
          create_person_transfer_between_people(current_user, other_user, 3000, 6.days.ago)
          create_person_transfer_between_people(current_user, other_user, 4000, 7.days.ago)
          expect(person_transfer.cumulative_sum).to eq(10000)
          person_transfers = PersonTransfer.find_for_person_with_other_person(current_user, other_user)
          expect(person_transfers[0].cumulative_sum).to eq(4000)
          expect(person_transfers[1].cumulative_sum).to eq(7000)
          expect(person_transfers[2].cumulative_sum).to eq(9000)
          expect(person_transfers[3].cumulative_sum).to eq(10000)
          expect(person_transfers[4].cumulative_sum).to eq(25000)
          expect(person_transfers[5].cumulative_sum).to eq(35000)
          expect(person_transfers[6].cumulative_sum).to eq(40000)
        end
      end

      context "when a person transfer is updated" do
        let(:previous_amounts) { [ 5000, 10000, 15000 ] }

        it "changes cumulative sum of the person transfers that come after, but not before " do
          person_transfers = PersonTransfer.find_for_person_with_other_person(current_user, other_user)
          person_transfers[1].update(amount: 13000)
          expect(person_transfers[0].reload.cumulative_sum).to eq(15000)
          expect(person_transfers[1].reload.cumulative_sum).to eq(28000)
          expect(person_transfers[2].reload.cumulative_sum).to eq(33000)
        end
      end
    end

    describe "after_destroy :set_cumulative_sums_after_destroy" do
      let(:previous_amounts) { [ 5000, 10000, 15000 ] }

      context "when the earliest person transfer is deleted" do
        it "decreases the cumulative sum of the remaining person transfers" do
          person_transfers = PersonTransfer.find_for_person_with_other_person(current_user, other_user)
          person_transfers[0].destroy
          expect(person_transfers[1].reload.cumulative_sum).to eq(10000)
          expect(person_transfers[2].reload.cumulative_sum).to eq(15000)
        end
      end

      context "when a person transfer whose date is in between others is deleted" do
        it "decreases the cumulative sum of person transfers that come after, but not before" do
          person_transfers = PersonTransfer.find_for_person_with_other_person(current_user, other_user)
          person_transfers[1].destroy
          expect(person_transfers[0].reload.cumulative_sum).to eq(15000)
          expect(person_transfers[2].reload.cumulative_sum).to eq(20000)
        end
      end

      context "when the latest person transfer is deleted" do
        it "does not change cumulative sum of any person transfers" do
          person_transfers = PersonTransfer.find_for_person_with_other_person(current_user, other_user)
          person_transfers[2].destroy
          expect(person_transfers[0].reload.cumulative_sum).to eq(15000)
          expect(person_transfers[1].reload.cumulative_sum).to eq(25000)
        end
      end
    end
  end
end
