class WebhookDispatchJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(event_id)
    event = Event.find(event_id)
    endpoints = event.merchant.webhook_endpoints.where(active: true)

    endpoints.each do |endpoint|
      next unless endpoint.listening_for?(event.event_type)

      delivery = WebhookDelivery.create!(
        webhook_endpoint: endpoint,
        event: event,
        status: "pending"
      )

      payload = event.payload.merge(event_type: event.event_type, event_id: event.id).to_json
      signature = OpenSSL::HMAC.hexdigest("SHA256", endpoint.secret_digest, payload)

      begin
        response = Net::HTTP.post(
          URI(endpoint.url),
          payload,
          "Content-Type" => "application/json",
          "X-Webhook-Signature" => "sha256=#{signature}"
        )
        delivery.update!(
          status: response.code.to_i < 300 ? "succeeded" : "failed",
          response_code: response.code.to_i,
          attempt_count: delivery.attempt_count + 1
        )
      rescue => e
        delivery.update!(
          status: "failed",
          attempt_count: delivery.attempt_count + 1,
          next_retry_at: 5.minutes.from_now
        )
        raise e
      end
    end
  end
end
