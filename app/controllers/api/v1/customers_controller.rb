class Api::V1::CustomersController < ApplicationController
  def index
    customers = @current_merchant.customers
    render json: customers
  end

  def show
    customer = @current_merchant.customers.find(params[:id])
    render json: customer
  end

  def create
    customer = @current_merchant.customers.build(customer_params)
    if customer.save
      Event.create!(merchant: @current_merchant, event_type: "customer.created", payload: { customer_id: customer.id, email: customer.email })
      render json: customer, status: :created
    else
      render json: { errors: customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def customer_params
    params.permit(:email, :name, :phone, metadata: {})
  end
end
