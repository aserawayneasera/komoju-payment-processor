class CreateCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :charges do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
      t.integer :amount, null: false
      t.string :currency, null: false, default: "JPY"
      t.string :status, null: false, default: "pending"
      t.string :description
      t.jsonb :metadata, default: {}
      t.string :idempotency_key
      t.timestamps
    end
    add_index :charges, [:merchant_id, :idempotency_key], unique: true, where: "idempotency_key IS NOT NULL"
  end
end
