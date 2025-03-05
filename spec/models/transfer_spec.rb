require 'rails_helper'

RSpec.describe Transfer, type: :model do
  describe "#dollar_amount_paid" do
    subject(:transfer) { Transfer.new(amount_paid: 731) }

    it "returns amount paid in dollars" do
      expect(transfer.dollar_amount_paid).to eq(7.31)
    end
  end

  describe "#dollar_amount_paid=" do
    subject(:transfer) { Transfer.new(dollar_amount_paid: 7.31) }

    it "sets amount paid in dollars" do
      expect(transfer.amount_paid).to eq(731)
    end
  end

  describe ".find_between_two_people" do
    let(:current_user) { FactoryBot.create(:person) }
    let(:other_user) { FactoryBot.create(:person) }
    let(:yet_another_user) { FactoryBot.create(:person) }

    it "returns just the transfers between two people" do
      3.times do
        create_transfer_between_people(current_user, other_user)
        create_transfer_between_people(other_user, current_user)
        create_transfer_between_people(other_user, yet_another_user)
        create_transfer_between_people(yet_another_user, other_user)
        create_transfer_between_people(yet_another_user, current_user)
        create_transfer_between_people(current_user, yet_another_user)
      end
      expect(
        Transfer.find_between_two_people(current_user, other_user)
      ).to contain_exactly(*(current_user.transfers & other_user.transfers))
    end
  end

  describe "amounts_sum_to_near_zero validation" do
    context "when person_transfer amounts equal the negative of each other" do
      subject(:transfer) do
        FactoryBot.build(:transfer).tap do |transfer|
          transfer.person_transfers[0].amount = 100
          transfer.person_transfers[1].amount = -100
        end
      end

      it "is valid" do
        expect(transfer).to be_valid
        expect(transfer.errors[:person_transfers].size).to eq(0)
      end
    end

    context "when person_transfer amounts are off by one cent" do
      subject(:transfer) do
        FactoryBot.build(:transfer).tap do |transfer|
          transfer.person_transfers[0].amount = 100
          transfer.person_transfers[1].amount = -101
        end
      end

      it "is valid" do
        expect(transfer).to be_valid
        expect(transfer.errors[:person_transfers].size).to eq(0)
      end
    end

    context "when person_transfer amounts do not not sum to zero" do
      subject(:transfer) do
        FactoryBot.build(:transfer).tap do |transfer|
          transfer.person_transfers[0].amount = 100
          transfer.person_transfers[1].amount = -50
        end
      end

      it "is invalid" do
        expect(transfer).not_to be_valid
        expect(transfer.errors[:person_transfers].size).to eq(1)
      end
    end
  end
end
