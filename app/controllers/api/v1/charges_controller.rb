class Api::V1::ChargesController < ApplicationController
  def index
    charges = @current_merchant.charges.order(created_at: :desc)
    render json: charges
  end

  def show
    charge = @current_merchant.charges.find(params[:id])
    render json: charge.as_json(include: :refunds)
  end

  def create
    idempotency_key = request.headers["Idempotency-Key"]

    if idempotency_key
      idem = IdempotencyKey.find_or_lock!(
        merchant: @current_merchant,
        key: idempotency_key,
        request_path: request.path
      )
      if idem.completed?
        render json: idem.response_body, status: idem.response_code and return
      end
    end

    charge = @current_merchant.charges.build(charge_params)
    charge.idempotency_key = idempotency_key

    if charge.save
      charge.update!(status: "succeeded")
      event = Event.create!(
        merchant: @current_merchant,
        event_type: "charge.succeeded",
        payload: { charge_id: charge.id, amount: charge.amount, currency: charge.currency }
      )
      WebhookDispatchJob.perform_later(event.id)

      response_body = charge.as_json
      idem&.complete!(response_body: response_body, response_code: 201)
      render json: response_body, status: :created
    else
      render json: { errors: charge.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def charge_params
    params.permit(:customer_id, :payment_method_id, :amount, :currency, :description, metadata: {})
  end
end
