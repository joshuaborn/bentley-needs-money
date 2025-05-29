require "rails_helper"

RSpec.describe ServiceResult do
  describe ".success" do
    let(:message) { "Operation completed successfully" }
    let(:result) { ServiceResult.success(message) }

    it "creates a successful result" do
      expect(result).to be_success
      expect(result).not_to be_failure
    end

    it "stores the success message" do
      expect(result.message).to eq(message)
    end

    it "sets success to true" do
      expect(result.success).to be true
    end
  end

  describe ".failure" do
    let(:message) { "Operation failed" }
    let(:result) { ServiceResult.failure(message) }

    it "creates a failed result" do
      expect(result).to be_failure
      expect(result).not_to be_success
    end

    it "stores the failure message" do
      expect(result.message).to eq(message)
    end

    it "sets success to false" do
      expect(result.success).to be false
    end
  end

  describe "#initialize" do
    context "with success true" do
      let(:result) { ServiceResult.new(true, "Success message") }

      it "creates a successful result" do
        expect(result).to be_success
        expect(result.message).to eq("Success message")
      end
    end

    context "with success false" do
      let(:result) { ServiceResult.new(false, "Error message") }

      it "creates a failed result" do
        expect(result).to be_failure
        expect(result.message).to eq("Error message")
      end
    end
  end

  describe "#success?" do
    it "returns true for successful results" do
      result = ServiceResult.success("test")
      expect(result.success?).to be true
    end

    it "returns false for failed results" do
      result = ServiceResult.failure("test")
      expect(result.success?).to be false
    end
  end

  describe "#failure?" do
    it "returns false for successful results" do
      result = ServiceResult.success("test")
      expect(result.failure?).to be false
    end

    it "returns true for failed results" do
      result = ServiceResult.failure("test")
      expect(result.failure?).to be true
    end
  end

  describe "attribute readers" do
    let(:message) { "Test message" }
    let(:success_result) { ServiceResult.success(message) }
    let(:failure_result) { ServiceResult.failure(message) }

    it "provides read access to message" do
      expect(success_result.message).to eq(message)
      expect(failure_result.message).to eq(message)
    end

    it "provides read access to success" do
      expect(success_result.success).to be true
      expect(failure_result.success).to be false
    end
  end
end
