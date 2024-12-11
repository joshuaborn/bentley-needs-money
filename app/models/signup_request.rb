class SignupRequest < ApplicationRecord
  belongs_to :from, class_name: "Person"
end
