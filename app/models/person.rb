class Person < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_many :person_transfers
  has_many :transfers, through: :person_transfers, dependent: :destroy
  has_many :expenses, through: :person_transfers, source: :transfer
  has_many :paybacks, through: :person_transfers, source: :transfer
  has_many :signup_requests, inverse_of: "from"
  has_many :connections, inverse_of: "from"
  has_many :connected_people, through: :connections, source: :to

  validates :name, presence: true

  def get_amounts_owed
    PersonTransfer.get_amounts_owed_for(self)
  end

  def request_connection(email)
    other_person = Person.where(email: email).first
    if other_person.present?
      preexisting_connection = self.connections.where(to: other_person).first
      if preexisting_connection.present?
        preexisting_connection
      else
        ConnectionRequest.create!(from: self, to: other_person)
      end
    else
      SignupRequest.create!(from: self, to: email)
    end
  end
end
