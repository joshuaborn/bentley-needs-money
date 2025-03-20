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
    if person == @debt.owed
      attributes = @debt.as_json(only: [ :amount, :cumulative_sum, :id ])
      attributes["reconciled"] = @debt.owed_reconciled
      person_attributes = @debt.ower.as_json(root: true, only: PERSON_ATTRIBUTES)
      person_attributes["person"]["role"] = "Ower"
    elsif person == @debt.ower
      attributes = @debt.as_json(only: [ :amount, :id ])
      attributes["reconciled"] = @debt.ower_reconciled
      attributes["cumulative_sum"] = @debt.cumulative_sum * (-1)
      person_attributes = @debt.owed.as_json(root: true, only: PERSON_ATTRIBUTES)
      person_attributes["person"]["role"] = "Owed"
    end
    attributes.merge!(person_attributes)
    attributes.merge!(@debt.reason.as_json(root: "reason", only: [ :amount, :date, :id, :payee, :memo, :type ]))
    attributes.transform_keys { |key| key.camelize(:lower) }
  end
end
