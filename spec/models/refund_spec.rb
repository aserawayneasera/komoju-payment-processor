require 'rails_helper'

RSpec.describe Refund, type: :model do
  describe "validations" do
    it { should belong_to(:charge) }
    it { should validate_presence_of(:amount) }

    it "rejects over-refunding" do
      merchant = create(:merchant)
      customer = create(:customer, merchant: merchant)
      payment_method = create(:payment_method, customer: customer)
      charge = create(:charge, merchant: merchant, customer: customer, payment_method: payment_method, amount: 5000)
      refund = build(:refund, charge: charge, amount: 6000)
      expect(refund).not_to be_valid
      expect(refund.errors[:amount]).to include("exceeds refundable balance")
    end

    it "allows refund equal to charge amount" do
      merchant = create(:merchant)
      customer = create(:customer, merchant: merchant)
      payment_method = create(:payment_method, customer: customer)
      charge = create(:charge, merchant: merchant, customer: customer, payment_method: payment_method, amount: 5000)
      refund = build(:refund, charge: charge, amount: 5000)
      expect(refund).to be_valid
    end
  end
end
