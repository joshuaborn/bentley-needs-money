class Person < ApplicationRecord
  has_many :person_transfers, dependent: :destroy
  has_many :transfers, through: :person_transfers, dependent: :destroy
  has_many :expenses, through: :person_transfers, source: :transfer
  before_destroy :check_administrator_count

  validates :name, presence: true

  private
    def check_administrator_count
      if is_administrator? && Person.where(is_administrator: true).count == 1
        raise StandardError.new("Cannot delete the last administrator")
      end
      Rails.logger.info("Checked the administrator count")
    end
end
