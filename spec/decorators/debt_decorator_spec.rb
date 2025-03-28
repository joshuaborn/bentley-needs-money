require 'rails_helper'

RSpec.describe DebtDecorator, type: :model do
  subject(:debt_decorator) { DebtDecorator.new }
  let(:ower) { FactoryBot.create(:person) }
  let(:owed) { FactoryBot.create(:person) }
  let(:debt) { create_debt_on_day(date: Date.today, ower: ower, owed: owed) }

  before do
    debt.save!
  end

  describe "#decorate" do
    it "sets the Debt record the will be serialized" do
      debt_decorator.decorate(debt)
      expect(debt_decorator.debt).to eq(debt)
    end
  end

  describe "#for" do
    it 'sets the person the serialization of Debt will be customized for' do
      debt_decorator.for(ower)
      expect(debt_decorator.person).to eq(ower)
    end
  end

  describe "#as_json" do
    context "when no current person is set" do
      it "raises an exception" do
        debt_decorator.decorate(debt)
        expect { debt_decorator.as_json }.to raise_error(
          DebtDecorator::NoPersonSetError,
          "A person must be set in a DebtDecorator before serialization to JSON."
        )
      end
    end
    context "when no debt is" do
      it "raises an exception" do
        debt_decorator.for(ower)
        expect { debt_decorator.as_json }.to raise_error(
          DebtDecorator::NoDebtSetError,
          "A debt must be set in a DebtDecorator with the #decorate method before serialization to JSON."
        )
      end
    end

    context "when person is set to ower" do
      before do
        debt_decorator.for(ower).decorate(debt)
      end

      it "returns JSON representation of Debt record's id and amount" do
        expect(debt_decorator.as_json).to include({
          "amount" => debt.amount,
          "id" => debt.id
        })
      end

      it "returns JSON representation of Debt with cumulative_sum negated" do
        expect(debt_decorator.as_json).to include({
          "cumulativeSum" => debt.cumulative_sum * (-1)
        })
      end

      it "returns a JSON representation of the owed person" do
        attributes = owed.as_json(root: true, only: [ :id, :name ])
        attributes["person"]["role"] = 'Owed'
        expect(debt_decorator.as_json).to include(attributes)
      end

      it "returns a JSON representation of the associated Reason record" do
        attributes = [ :amount, :id, :payee, :memo, :type ].inject(Hash.new) do |hash, attribute|
          hash[attribute.to_s.camelize(:lower)] = debt.reason.send(attribute)
          hash
        end
        attributes["date"] = debt.reason.date.to_s
        expect(debt_decorator.as_json).to include({ "reason" => attributes })
      end

      context "and transaction is not reconciled for ower" do
        it "returns JSON representation with reconciled set to false" do
          debt.ower_reconciled = false
          expect(debt_decorator.as_json).to include({ "reconciled" => false })
        end
      end

      context "and transaction is reconciled for ower" do
        it "returns JSON representation with reconciled set to true" do
          debt.ower_reconciled = true
          expect(debt_decorator.as_json).to include({ "reconciled" => true })
        end
      end
    end

    context "when person is set to owed" do
      before do
        debt_decorator.for(owed).decorate(debt)
      end

      it "returns JSON representation of Debt record's id and amount" do
        expect(debt_decorator.as_json).to include({
          "amount" => debt.amount,
          "id" => debt.id
        })
      end

      it "returns JSON representation of Debt with cumulative_sum as is" do
        expect(debt_decorator.as_json).to include({
          "cumulativeSum" => debt.cumulative_sum
        })
      end

      it "returns a JSON representation of the ower person" do
        attributes = ower.as_json(root: true, only: [ :id, :name ])
        attributes["person"]["role"] = 'Ower'
        expect(debt_decorator.as_json).to include(attributes)
      end

      it "returns a JSON representation of the associated Reason record" do
        attributes = [ :amount, :id, :payee, :memo, :type ].inject(Hash.new) do |hash, attribute|
          hash[attribute.to_s.camelize(:lower)] = debt.reason.send(attribute)
          hash
        end
        attributes["date"] = debt.reason.date.to_s
        expect(debt_decorator.as_json).to include({ "reason" => attributes })
      end

      context "and transaction is not reconciled for owed person" do
        it "returns JSON representation with reconciled set to false" do
          debt.owed_reconciled = false
          expect(debt_decorator.as_json).to include({ "reconciled" => false })
        end
      end

      context "and transaction is reconciled for owed person" do
        it "returns JSON representation with reconciled set to true" do
          debt.owed_reconciled = true
          expect(debt_decorator.as_json).to include({ "reconciled" => true })
        end
      end
    end
  end
end
