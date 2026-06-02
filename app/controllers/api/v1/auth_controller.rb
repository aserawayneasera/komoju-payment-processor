class Api::V1::AuthController < ActionController::API
  def register
    merchant = Merchant.new(merchant_params)
    if merchant.save
      api_key, raw_token = ApiKey.generate_for(merchant, name: "default")
      render json: {
        merchant: { id: merchant.id, name: merchant.name, email: merchant.email },
        api_key: raw_token,
        message: "Save this API key — it will not be shown again."
      }, status: :created
    else
      render json: { errors: merchant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    merchant = Merchant.find_by!(email: params[:email])
    if merchant.authenticate(params[:password])
      api_key, raw_token = ApiKey.generate_for(merchant, name: "session-#{Time.current.to_i}")
      render json: {
        merchant: { id: merchant.id, name: merchant.name, email: merchant.email },
        api_key: raw_token
      }
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Invalid credentials" }, status: :unauthorized
  end

  private

  def merchant_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
