class CreateIdempotencyKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :idempotency_keys do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :key, null: false
      t.string :request_path, null: false
      t.jsonb :response_body
      t.integer :response_code
      t.datetime :locked_at
      t.timestamps
    end
    add_index :idempotency_keys, [:merchant_id, :key], unique: true
  end
end
