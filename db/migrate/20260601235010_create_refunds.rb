class CreateRefunds < ActiveRecord::Migration[8.1]
  def change
    create_table :refunds do |t|
      t.references :charge, null: false, foreign_key: true
      t.integer :amount, null: false
      t.string :status, null: false, default: "pending"
      t.string :reason
      t.timestamps
    end
  end
end
