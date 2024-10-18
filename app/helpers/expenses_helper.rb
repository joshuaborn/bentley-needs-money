module ExpensesHelper
  def group_by_date(person_transfers)
    person_transfers.inject({}) do |this_hash, this_person_transfer|
      this_date = localize this_person_transfer.transfer.date, format: :ynab
      unless this_hash.include?(this_date)
        this_hash[this_date] = []
      end
      this_hash[this_date].unshift(this_person_transfer)
      this_hash
    end
  end
end
