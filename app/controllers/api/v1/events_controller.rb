class Api::V1::EventsController < ApplicationController
  def index
    events = @current_merchant.events.order(created_at: :desc)
    render json: events
  end

  def show
    event = @current_merchant.events.find(params[:id])
    render json: event.as_json(include: :webhook_deliveries)
  end
end
