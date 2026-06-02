require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should have_secure_password }

    it "rejects duplicate emails" do
      existing = create(:merchant)
      duplicate = build(:merchant, email: existing.email)
      expect(duplicate).not_to be_valid
    end

    it "rejects invalid email format" do
      merchant = build(:merchant, email: "not-an-email")
      expect(merchant).not_to be_valid
    end

    it "rejects invalid status" do
      merchant = build(:merchant, status: "unknown")
      expect(merchant).not_to be_valid
    end
  end

  describe "associations" do
    it { should have_many(:api_keys).dependent(:destroy) }
    it { should have_many(:customers).dependent(:destroy) }
    it { should have_many(:charges).dependent(:destroy) }
    it { should have_many(:webhook_endpoints).dependent(:destroy) }
  end
end
