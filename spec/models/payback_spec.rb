require 'rails_helper'

RSpec.describe Payback, type: :model do
  let(:person) { FactoryBot.create(:person) }
  let(:other_person) { FactoryBot.create(:person) }

  describe ".new_from_parameters" do
    subject(:payback) { Payback.new_from_parameters(person, other_person, payback_attributes) }
    let(:payback_attributes) { FactoryBot.attributes_for(:payback) }

    it "sets payer's dollar amount to dollar amount paid attribute and payee's dollar amount to negative of dollar amount paid" do
      expect(payback).to have_attributes(payback_attributes)
      expect(payback.person_transfers[0].dollar_amount).to eq(payback_attributes[:dollar_amount_paid])
      expect(payback.person_transfers[1].dollar_amount).to eq(payback_attributes[:dollar_amount_paid] * (-1))
    end

    it "sets payee to other person's name" do
      expect(payback.payee).to eq(other_person.name)
    end
  end

  describe "#update" do
    context "with a payback of other person to this person" do
      subject(:payback) do
        Payback.new_from_parameters(
          other_person,
          person,
          FactoryBot.attributes_for(:payback)
        ).tap(&:save!)
      end

      it "sets this person's dollar amount to negative of new dollar amount paid and other person's dollar amount to new dollar amount paid" do
        payback.update(dollar_amount_paid: 123.50)
        expect(payback.person_transfers.find { |pt| pt.person == person }.dollar_amount).to eq(-123.50)
        expect(payback.person_transfers.find { |pt| pt.person == other_person }.dollar_amount).to eq(123.50)
      end
    end

    context "with a payback of this person to other person" do
      subject(:payback) do
        Payback.new_from_parameters(
          person,
          other_person,
          FactoryBot.attributes_for(:payback)
        ).tap(&:save!)
      end

      it "sets this person's dollar amount to new dollar amount paid and other person's dollar amount to negative of new dollar amount paid" do
        payback.update(dollar_amount_paid: 123.50)
        expect(payback.person_transfers.find { |pt| pt.person == person }.dollar_amount).to eq(123.50)
        expect(payback.person_transfers.find { |pt| pt.person == other_person }.dollar_amount).to eq(-123.50)
      end
    end
  end
end
