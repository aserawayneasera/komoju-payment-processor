class Api::V1::ApiKeysController < ApplicationController
  def index
    keys = @current_merchant.api_keys.where(revoked_at: nil)
    render json: keys.map { |k| { id: k.id, name: k.name, last_used_at: k.last_used_at, created_at: k.created_at } }
  end

  def create
    key, raw_token = ApiKey.generate_for(@current_merchant, name: params[:name] || "key-#{Time.current.to_i}")
    render json: { id: key.id, name: key.name, token: raw_token, message: "Save this token — it will not be shown again." }, status: :created
  end

  def destroy
    key = @current_merchant.api_keys.find(params[:id])
    key.revoke!
    render json: { message: "API key revoked" }
  end
end
