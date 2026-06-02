class CreateWebhookDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_deliveries do |t|
      t.references :webhook_endpoint, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :response_code
      t.integer :attempt_count, default: 0
      t.datetime :next_retry_at
      t.timestamps
    end
  end
end
