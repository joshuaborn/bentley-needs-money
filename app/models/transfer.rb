class Transfer < ApplicationRecord
  has_many :person_transfers, dependent: :destroy
  accepts_nested_attributes_for :person_transfers
  has_many :people, through: :person_transfers, source: "person"

  validates :payee, :date, presence: true
  validates :person_transfers, length: { minimum: 2 }
  validates_associated :person_transfers
  validate :amounts_sum_to_near_zero

  def dollar_amount_paid
    self.amount_paid.to_f / 100
  end

  def dollar_amount_paid=(dollars)
    self.amount_paid = (100 * dollars.to_f).to_i
  end

  class << self
    def find_between_two_people(first_person, second_person)
      Transfer.joins("JOIN person_transfers AS pe1 ON transfers.id = pe1.transfer_id").
        joins("JOIN person_transfers AS pe2 ON transfers.id = pe2.transfer_id").
        where("pe1.person_id = ? AND pe2.person_id = ?", first_person, second_person)
    end
  end

  private
    def amounts_sum_to_near_zero
      amount_sum = self.person_transfers.inject(0) do |cumulative_sum, person_transfer|
        cumulative_sum + person_transfer.try(&:amount).to_i
      end
      if amount_sum < -1 or amount_sum > 1
        self.errors.add(:person_transfers, "amounts should sum to zero")
      end
    end
end
