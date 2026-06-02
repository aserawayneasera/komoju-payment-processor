class CreatePaymentMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_methods do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :payment_type, null: false
      t.string :last_four, null: false
      t.string :brand
      t.integer :exp_month
      t.integer :exp_year
      t.boolean :is_default, default: false
      t.timestamps
    end
  end
end
