class PersonTransfer < ApplicationRecord
  belongs_to :person
  belongs_to :transfer
  has_many :person_transfers, through: :transfer
  has_many :people, through: :person_transfers, source: :person

  validates :person, presence: true
  validates :transfer, presence: true
  validates :amount, presence: true

  before_save :set_cumulative_sums

  def dollar_amount
    self.amount.to_f / 100
  end

  def dollar_amount=(dollars)
    self.amount = (100 * dollars.to_f).to_i
  end

  def other_person_transfer
    self.person_transfers.detect { |person_transfer| person_transfer.person_id != self.person_id }
  end

  def other_person
    self.people.detect { |person| person.id != self.person_id }
  end

  def dollar_cumulative_sum
    self.cumulative_sum.to_f / 100
  end

  class << self
    def find_for_person_with_other_person(first_person, second_person)
      PersonTransfer.joins("LEFT OUTER JOIN transfers ON transfers.id = person_transfers.transfer_id").
        joins("JOIN person_transfers AS pt2 ON transfers.id = pt2.transfer_id").
        where("person_transfers.person_id = ? AND pt2.person_id = ?", first_person, second_person).
        order("transfers.date", "transfers.updated_at")
    end

    def get_amounts_owed_for(person)
      person.person_transfers.joins("LEFT OUTER JOIN transfers ON transfers.id = person_transfers.transfer_id").
        joins("JOIN person_transfers AS pt2 ON transfers.id = pt2.transfer_id", "LEFT JOIN people ON people.id = pt2.person_id").
        where("pt2.person_id != ?", person).
        select("DISTINCT ON (pt2.person_id) pt2.person_id, pt2.*, people.name, transfers.date, transfers.updated_at").
        order("pt2.person_id", "transfers.date DESC", "transfers.updated_at DESC")
    end
  end

  private
    def set_cumulative_sums
      other_person = self.transfer.person_transfers.detect { |person_transfer| person_transfer.person_id != self.person_id }.person
      existing_person_transfers = PersonTransfer.find_for_person_with_other_person(self.person, other_person)
      if existing_person_transfers.where(
          "transfers.date < ? OR (transfers.date = ? AND transfers.updated_at < ?)",
          self.transfer.date,
          self.transfer.date,
          self.transfer.updated_at
        ).empty?
        self.cumulative_sum = self.amount
      else
        previous_person_transfer = existing_person_transfers.where(
          "transfers.date < ? OR (transfers.date = ? AND transfers.updated_at < ?)",
          self.transfer.date,
          self.transfer.date,
          self.transfer.updated_at
        ).last
        self.cumulative_sum = self.amount + previous_person_transfer.cumulative_sum
      end
      existing_person_transfers.where(
        "transfers.date > ? OR (transfers.date = ? AND transfers.updated_at > ?)",
        self.transfer.date,
        self.transfer.date,
        self.transfer.updated_at
      ).inject(self.cumulative_sum) do |sum, person_transfer|
        person_transfer.update_columns(cumulative_sum: sum + person_transfer.amount)
        person_transfer.cumulative_sum
      end
    end
end
