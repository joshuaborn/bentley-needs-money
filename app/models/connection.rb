class Connection < ApplicationRecord
  belongs_to :from, class_name: "Person"
  belongs_to :to, class_name: "Person"
end
