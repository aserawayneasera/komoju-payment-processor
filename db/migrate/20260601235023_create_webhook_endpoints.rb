class CreateWebhookEndpoints < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_endpoints do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :url, null: false
      t.string :secret_digest, null: false
      t.boolean :active, default: true
      t.string :events, array: true, default: []
      t.timestamps
    end
  end
end
