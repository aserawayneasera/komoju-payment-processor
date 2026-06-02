class Api::V1::PaymentMethodsController < ApplicationController
  def index
    customer = @current_merchant.customers.find(params[:customer_id])
    render json: customer.payment_methods
  end

  def create
    customer = @current_merchant.customers.find(params[:customer_id])
    payment_method = customer.payment_methods.build(payment_method_params)
    if payment_method.save
      Event.create!(
        merchant: @current_merchant,
        event_type: "payment_method.created",
        payload: { payment_method_id: payment_method.id, customer_id: customer.id }
      )
      render json: payment_method, status: :created
    else
      render json: { errors: payment_method.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def payment_method_params
    params.permit(:payment_type, :last_four, :brand, :exp_month, :exp_year, :is_default)
  end
end
