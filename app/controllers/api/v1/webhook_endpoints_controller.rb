class Api::V1::WebhookEndpointsController < ApplicationController
  def index
    render json: @current_merchant.webhook_endpoints
  end

  def create
    endpoint, raw_secret = WebhookEndpoint.generate_for(
      @current_merchant,
      url: params[:url],
      events: params[:events] || ["*"]
    )
    render json: {
      id: endpoint.id,
      url: endpoint.url,
      events: endpoint.events,
      secret: raw_secret,
      message: "Save this secret — it will not be shown again."
    }, status: :created
  end

  def destroy
    endpoint = @current_merchant.webhook_endpoints.find(params[:id])
    endpoint.destroy!
    render json: { message: "Webhook endpoint deleted" }
  end
end
