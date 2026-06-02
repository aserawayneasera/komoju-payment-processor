class Api::V1::RefundsController < ApplicationController
  def create
    charge = @current_merchant.charges.find(params[:charge_id])
    refund = charge.refunds.build(refund_params)

    if refund.save
      refund.update!(status: "succeeded")
      if charge.refunds.where(status: "succeeded").sum(:amount) >= charge.amount
        charge.update!(status: "refunded")
      end
      event = Event.create!(
        merchant: @current_merchant,
        event_type: "refund.succeeded",
        payload: { refund_id: refund.id, charge_id: charge.id, amount: refund.amount }
      )
      WebhookDispatchJob.perform_later(event.id)
      render json: refund, status: :created
    else
      render json: { errors: refund.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def refund_params
    params.permit(:amount, :reason)
  end
end
