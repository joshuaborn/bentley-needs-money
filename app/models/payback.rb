class Payback < Transfer
  class << self
    def amount_owed(current_person, other_person)
      PersonTransfer.find_for_person_with_other_person(current_person, other_person).first.amount
    end
  end
end
