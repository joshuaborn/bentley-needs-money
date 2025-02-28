module Helpers
  def build_expenses_for_tests(person_one, person_two, administrator)
    Expense.split_between_two_people(
      person_one,
      person_two,
      payee: "Acme, Inc.",
      date: "2024-09-20",
      dollar_amount_paid: 6.52
    ).save!
    Expense.split_between_two_people(
      person_one,
      person_two,
      payee: "Acme, Inc.",
      date: "2024-09-21",
      dollar_amount_paid: 8.88
    ).save!
    Expense.split_between_two_people(
      person_two,
      person_one,
      payee: "Acme, Inc.",
      date: "2024-09-21",
      dollar_amount_paid: 105.22
    ).save!
    Expense.split_between_two_people(
      person_two,
      person_one,
      payee: "Acme, Inc.",
      date: "2024-09-22",
      dollar_amount_paid: 1032.41
    ).save!
    Expense.split_between_two_people(
      administrator,
      person_one,
      payee: "Acme, Inc.",
      date: "2024-09-23",
      dollar_amount_paid: 923.23
    ).save!
    Expense.split_between_two_people(
      person_one,
      administrator,
      payee: "Acme, Inc.",
      date: "2024-09-24",
      dollar_amount_paid: 28.01
    ).save!
    Expense.split_between_two_people(
      administrator,
      person_two,
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 237.31
    ).save!
    Expense.split_between_two_people(
      person_two,
      administrator,
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 38.45
    ).save!
  end
end
