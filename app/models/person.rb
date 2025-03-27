class Person < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_many :signup_requests, inverse_of: "from"
  has_many :outbound_connection_requests, class_name: "ConnectionRequest", inverse_of: "from"
  has_many :inbound_connection_requests, class_name: "ConnectionRequest", inverse_of: "to"
  has_many :connections, inverse_of: "from"
  has_many :connected_people, through: :connections, source: :to

  validates :name, presence: true

  after_create :convert_signup_requests

  def request_connection(email)
    other_person = Person.where(email: email).first
    if other_person.present?
      self.connections.where(to: other_person).first ||
        self.outbound_connection_requests.where(to: other_person).first ||
        self.outbound_connection_requests.create(to: other_person)
    else
      self.signup_requests.where(to: email).first ||
        self.signup_requests.create(to: email)
    end
  end

  def is_connected_with?(other_person)
    self == other_person or self.connected_people.where(id: other_person.id).present?
  end

  private
    def convert_signup_requests
      SignupRequest.where(to: self.email).all.each do |request|
        ConnectionRequest.create(from: request.from, to: self)
        request.destroy
      end
    end
end
