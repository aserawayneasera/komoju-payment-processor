class ApplicationController < ActionController::API
  before_action :authenticate!

  private

  def authenticate!
    token = request.headers["Authorization"]&.sub(/\ABearer /, "")
    unless token
      render json: { error: "Missing API key" }, status: :unauthorized and return
    end
    @current_api_key = ApiKey.authenticate!(token)
    @current_merchant = @current_api_key.merchant
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Invalid or revoked API key" }, status: :unauthorized
  end
end
