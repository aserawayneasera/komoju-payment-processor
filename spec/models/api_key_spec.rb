require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  describe "validations" do
    it { should belong_to(:merchant) }
    it { should validate_presence_of(:name) }
  end

  describe ".generate_for" do
    it "returns a key and a raw token" do
      merchant = create(:merchant)
      key, raw_token = ApiKey.generate_for(merchant, name: "test")
      expect(key).to be_persisted
      expect(raw_token).to be_a(String)
      expect(raw_token.length).to eq(64)
    end

    it "stores a digest, not the raw token" do
      merchant = create(:merchant)
      key, raw_token = ApiKey.generate_for(merchant, name: "test")
      expect(key.token_digest).not_to eq(raw_token)
      expect(key.token_digest).to eq(Digest::SHA256.hexdigest(raw_token))
    end
  end

  describe ".authenticate!" do
    it "returns the key for a valid token" do
      merchant = create(:merchant)
      key, raw_token = ApiKey.generate_for(merchant, name: "test")
      expect(ApiKey.authenticate!(raw_token)).to eq(key)
    end

    it "raises for an invalid token" do
      expect { ApiKey.authenticate!("bad-token") }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises for a revoked token" do
      merchant = create(:merchant)
      key, raw_token = ApiKey.generate_for(merchant, name: "test")
      key.revoke!
      expect { ApiKey.authenticate!(raw_token) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
