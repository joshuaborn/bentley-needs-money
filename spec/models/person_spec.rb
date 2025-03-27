require 'rails_helper'

RSpec.describe Person, type: :model do
  subject(:person) { FactoryBot.create(:person) }

  describe "#request_connection" do
    shared_examples "don't create" do
      it "doesn't create a connection request" do
        expect { person.request_connection(other_person.email) }.not_to change(ConnectionRequest, :count)
      end
    end

    context "to an email address that matches another person" do
      let(:other_person) { FactoryBot.create(:person) }

      context "who is already connected to this person"  do
        let!(:existing_connection) { Connection.create(from: person, to: other_person) }

        include_examples "don't create"

        it "returns the existing connection" do
          expect(person.request_connection(other_person.email)).to eq(existing_connection)
        end
      end

      context "when there is already a connection request"  do
        let!(:existing_connection_request) { ConnectionRequest.create(from: person, to: other_person) }

        include_examples "don't create"

        it "returns the existing connection request" do
          expect(person.request_connection(other_person.email)).to eq(existing_connection_request)
        end
      end

      context "when there isn't a connection request yet"  do
        it "creates a connection request" do
          expect { person.request_connection(other_person.email) }.to change(ConnectionRequest, :count).by(1)
        end

        it "returns the new connection request" do
          new_connection_request = person.request_connection(other_person.email)
          expect(new_connection_request).to be_instance_of(ConnectionRequest)
          expect(new_connection_request.from).to eq(person)
          expect(new_connection_request.to).to eq(other_person)
        end
      end
    end

    context "to an email address not in the application" do
      let(:other_email) { Faker::Internet.email }

      context "when there is already a signup request"  do
        let!(:existing_signup_request) { SignupRequest.create(from: person, to: other_email) }

        it "doesn't create a signup request" do
          expect { person.request_connection(other_email) }.not_to change(SignupRequest, :count)
        end

        it "returns the existing signup request" do
          expect(person.request_connection(other_email)).to eq(existing_signup_request)
        end
      end

      context "when there isn't a signup request yet"  do
        it "creates a signup request" do
          expect { person.request_connection(other_email) }.to change(SignupRequest, :count).by(1)
        end

        it "returns the new connection request" do
          new_signup_request = person.request_connection(other_email)
          expect(new_signup_request).to be_instance_of(SignupRequest)
          expect(new_signup_request.from).to eq(person)
          expect(new_signup_request.to).to eq(other_email)
        end
      end
    end
  end

  describe "#is_connected_with?" do
    let(:other_person) { FactoryBot.create(:person) }

    context "with the same person" do
      it "returns true" do
        expect(person.is_connected_with?(person)).to be_truthy
      end
    end

    context "with a not connected person" do
      it "returns false" do
        expect(person.is_connected_with?(other_person)).not_to be_truthy
      end
    end

    context "with a connected person" do
      it "returns true" do
        Connection.create(from: person, to: other_person)
        Connection.create(from: other_person, to: person)
        expect(person.is_connected_with?(other_person)).to be_truthy
      end
    end
  end

  describe "after_create :convert_signup_requests" do
    let(:other_person) { FactoryBot.create(:person) }
    let(:new_person) { FactoryBot.build(:person) }
    let(:another_new_person) { FactoryBot.build(:person) }

    before do
      SignupRequest.create(from: person, to: new_person.email)
      SignupRequest.create(from: other_person, to: new_person.email)
      SignupRequest.create(from: person, to: another_new_person.email)
    end

    it "creates connection requests" do
      expect { new_person.save! }.to change(ConnectionRequest, :count).by(2)
      expect(ConnectionRequest.where(from: person, to: new_person)).to exist
      expect(ConnectionRequest.where(from: other_person, to: new_person)).to exist
    end

    it "deletes signup requests" do
      expect { new_person.save! }.to change(SignupRequest, :count).by(-2)
      expect(SignupRequest.where(from: person, to: new_person)).not_to exist
      expect(SignupRequest.where(from: other_person, to: new_person)).not_to exist
    end
  end
end
