class Debt < ApplicationRecord
  belongs_to :ower, class_name: "Person"
  belongs_to :owed, class_name: "Person"
  belongs_to :reason

  validates :amount, comparison: { greater_than: 0 }
  validates_presence_of :reason

  scope :between_people, ->(first_person, second_person) {
    where(ower: first_person, owed: second_person).or(
      where(ower: second_person, owed: first_person)
    )
  }
  scope :before, ->(debt) {
    joins(:reason).where(
      "reasons.date < ? OR (reasons.date = ? AND reasons.created_at < ?)",
      debt.reason.date,
      debt.reason.date,
      debt.reason.created_at
    )
  }
  scope :after, ->(debt) {
    joins(:reason).where(
      "reasons.date > ? OR (reasons.date = ? AND reasons.created_at >= ?)",
      debt.reason.date,
      debt.reason.date,
      debt.reason.created_at
    )
  }
  scope :ascending_by_date, -> {
    order({ reasons: { date: :asc } }, { reasons: { created_at: :asc } })
  }
  scope :descending_by_date, -> {
    order({ reasons: { date: :desc } }, { reasons: { created_at: :desc } })
  }
  scope :for_person, ->(person) {
    includes(:reason, :ower, :owed).where(ower: person).or(where(owed: person)).descending_by_date
  }

  before_save :set_cumulative_sums_before_save
  after_destroy :set_cumulative_sums_after_destroy

  def dollar_amount
    self.amount.to_f / 100
  end

  def dollar_amount=(dollars)
    self.amount = (100 * dollars.to_f).round(0)
  end

  def dollar_cumulative_sum
    self.cumulative_sum.to_f / 100
  end

  private

    # The cumulative_sum is relative to the direction of how much the ower owes
    # the owed person. Therefore, it is negative if the owed person actually
    # owes the ower money. The add_or_sub_factor is what switches the sign of
    # the cumulative_sum when calculating it for each debt record.
    def set_cumulative_sums_before_save
      debts = Debt.includes(:reason).between_people(self.ower, self.owed).ascending_by_date

      # On updates, this debt shouldn't be in the list of debts.
      debts = debts.where("debts.id != ?", self.id) if self.persisted?

      # When there are no other debts before this one, this debt's
      # cumulative_sum is just its amount.
      if debts.before(self).empty?
        self.cumulative_sum = self.amount

      # Otherwise, the cumulative_sum is the sum of this debt's amount and the
      # previous debt's cumulative_sum. If the previous debt is in the other
      # direction, then the sign of the cumulative_sum must be reversed.
      else
        most_recent_debt = debts.before(self).last
        add_or_sub_factor = (self.ower == most_recent_debt.ower) ? 1 : -1
        self.cumulative_sum = (add_or_sub_factor * most_recent_debt.cumulative_sum) + self.amount
      end

      # The cumulative sum of each debt that comes after this one must be
      # similarly updated.
      debts.after(self).inject(self.cumulative_sum) do |previous_cumulative_sum, current_debt|
        add_or_sub_factor = (self.ower == current_debt.ower) ? 1 : -1
        current_debt.update_columns(cumulative_sum: (add_or_sub_factor * previous_cumulative_sum) + current_debt.amount)
        add_or_sub_factor * current_debt.cumulative_sum
      end
    end

    # This triggers the set_cumulative_sums_before_save callback as needed.
    def set_cumulative_sums_after_destroy
      next_debt = Debt.includes(:reason).between_people(self.ower, self.owed).after(self).ascending_by_date.first
      next_debt.save! if next_debt.present?
    end
end
