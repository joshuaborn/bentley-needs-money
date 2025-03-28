class DebtDecorator
  include ActiveModel::Serializers::JSON

  PERSON_ATTRIBUTES = [ :id, :name ]

  attr_accessor :debt, :person

  def decorate(debt)
    @debt = debt
    self
  end

  def for(person)
    @person = person
    self
  end

  class NoPersonSetError < StandardError; end
  class NoDebtSetError < StandardError; end

  def as_json
    raise NoPersonSetError.new("A person must be set in a DebtDecorator before serialization to JSON.") if @person.nil?
    raise NoDebtSetError.new("A debt must be set in a DebtDecorator with the #decorate method before serialization to JSON.") if @debt.nil?
    attributes = @debt.as_json(only: [ :id, :amount ])
    if person == @debt.owed
      attributes["reconciled"] = @debt.owed_reconciled
      attributes["cumulativeSum"] = @debt.cumulative_sum
      person_attributes = @debt.ower.as_json(root: true, only: PERSON_ATTRIBUTES)
      person_attributes["person"]["role"] = "Ower"
    elsif person == @debt.ower
      attributes["reconciled"] = @debt.ower_reconciled
      attributes["cumulativeSum"] = @debt.cumulative_sum * (-1)
      person_attributes = @debt.owed.as_json(root: true, only: PERSON_ATTRIBUTES)
      person_attributes["person"]["role"] = "Owed"
    end
    attributes.merge!(person_attributes)
    attributes.merge!(@debt.reason.as_json(root: "reason", only: [ :date, :id, :payee, :memo, :type, :amount ]))
    attributes.transform_keys { |key| key.camelize(:lower) }
  end
end
