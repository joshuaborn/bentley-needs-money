require 'rails_helper'

RSpec.describe TransfersHelper, type: :helper do
  describe ".group_by_date" do
    subject(:grouped_person_transfers) { group_by_date(person.person_transfers) }
    let(:person) { FactoryBot.create(:person) }
    let(:other_person) { FactoryBot.create(:person) }
    let!(:day_one_person_transfers) do
      [
        create_person_transfer_between_people(person, other_person, 10000, Date.new(2025, 3, 1))
      ]
    end
    let!(:day_two_person_transfers) do
      [
        create_person_transfer_between_people(person, other_person, 5000, Date.new(2025, 3, 2)),
        create_person_transfer_between_people(person, other_person, 7500, Date.new(2025, 3, 2))
      ]
    end
    let!(:day_three_person_transfers) do
      [
        create_person_transfer_between_people(person, other_person, 1000, Date.new(2025, 3, 3)),
        create_person_transfer_between_people(person, other_person, 1500, Date.new(2025, 3, 3)),
        create_person_transfer_between_people(person, other_person, 3000, Date.new(2025, 3, 3))
      ]
    end

    it "creates a hash with dates as the keys and person transfers on that date as the values" do
      expect(grouped_person_transfers).to be_kind_of(Hash)
      expect(grouped_person_transfers.keys).to contain_exactly("03/03/2025", "03/02/2025", "03/01/2025")
      expect(grouped_person_transfers["03/01/2025"]).to contain_exactly(*day_one_person_transfers)
      expect(grouped_person_transfers["03/02/2025"]).to contain_exactly(*day_two_person_transfers)
      expect(grouped_person_transfers["03/03/2025"]).to contain_exactly(*day_three_person_transfers)
    end
  end
end
