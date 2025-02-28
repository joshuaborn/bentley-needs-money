module Helpers
  def person_transfer_mapping(person_transfer)
    {
      "date" => person_transfer.transfer.date.to_s,
      "dollarAmountPaid" => person_transfer.transfer.dollar_amount_paid,
      "memo" => person_transfer.transfer.memo,
      "myPersonTransfer" => {
        "dollarAmount" => person_transfer.dollar_amount,
        "id" => person_transfer.id,
        "inYnab" => person_transfer.in_ynab?,
        "personId" => person_transfer.person.id
      },
      "otherPersonTransfers" => [
        {
          "cumulativeSum" => person_transfer.dollar_cumulative_sum,
          "date" => person_transfer.transfer.date.to_s,
          "dollarAmount" => person_transfer.other_person_transfer.dollar_amount,
          "id" => person_transfer.other_person_transfer.id,
          "name" => person_transfer.other_person.name,
          "personId" => person_transfer.other_person.id
        }
      ],
      "payee" => person_transfer.transfer.payee,
      "transferId" => person_transfer.transfer_id,
      "type" => person_transfer.transfer.type
    }
  end
end
