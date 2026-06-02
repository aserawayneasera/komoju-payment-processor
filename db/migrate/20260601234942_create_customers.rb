class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :email, null: false
      t.string :name, null: false
      t.string :phone
      t.jsonb :metadata, default: {}
      t.timestamps
    end
    add_index :customers, [:merchant_id, :email], unique: true
  end
end
