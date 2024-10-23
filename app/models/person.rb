class Person < ApplicationRecord
  has_many :person_transfers, dependent: :destroy
  has_many :transfers, through: :person_transfers, dependent: :destroy
  has_many :expenses, through: :person_transfers, source: :transfer
  before_destroy :check_administrator_count

  validates :name, presence: true

  def get_amounts_owed
    self.person_transfers.joins("LEFT OUTER JOIN transfers ON transfers.id = person_transfers.transfer_id").
      joins("JOIN person_transfers AS pt2 ON transfers.id = pt2.transfer_id", "LEFT JOIN people ON people.id = pt2.person_id").
      where("pt2.person_id != ?", self).
      select("DISTINCT ON (pt2.person_id) pt2.person_id, pt2.*, people.name, transfers.date, transfers.updated_at").
      order("pt2.person_id", "transfers.date DESC", "transfers.updated_at DESC")
    # inject(Hash.new) do |hash, row|
    #  hash[row.person_id] = Hash.new({
    #    dollar_cumulative_sum: row.dollar_cumulative_sum,
    #    id: row.person_id,
    #    name: row.name
    #  })
    #  hash
    # end
  end

  private
    def check_administrator_count
      if is_administrator? && Person.where(is_administrator: true).count == 1
        raise StandardError.new("Cannot delete the last administrator")
      end
      Rails.logger.info("Checked the administrator count")
    end
end
