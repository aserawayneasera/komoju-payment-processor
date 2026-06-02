require 'rails_helper'

RSpec.describe Charge, type: :model do
  describe "validations" do
    it { should belong_to(:merchant) }
    it { should belong_to(:customer) }
    it { should belong_to(:payment_method) }
    it { should have_many(:refunds) }
    it { should validate_presence_of(:amount) }

    it "rejects amount of zero" do
      charge = build(:charge, amount: 0)
      expect(charge).not_to be_valid
    end

    it "rejects unsupported currency" do
      charge = build(:charge, currency: "XYZ")
      expect(charge).not_to be_valid
    end
  end

  describe "cross-tenant validation" do
    it "rejects a customer from a different merchant" do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      customer = create(:customer, merchant: merchant2)
      payment_method = create(:payment_method, customer: customer)
      charge = build(:charge, merchant: merchant1, customer: customer, payment_method: payment_method)
      expect(charge).not_to be_valid
      expect(charge.errors[:customer]).to include("does not belong to this merchant")
    end
  end

  describe "#refundable_amount" do
    it "returns amount minus pending and succeeded refunds" do
      merchant = create(:merchant)
      customer = create(:customer, merchant: merchant)
      payment_method = create(:payment_method, customer: customer)
      charge = create(:charge, merchant: merchant, customer: customer, payment_method: payment_method, amount: 5000)
      create(:refund, charge: charge, amount: 2000, status: "succeeded")
      expect(charge.refundable_amount).to eq(3000)
    end
  end
end
