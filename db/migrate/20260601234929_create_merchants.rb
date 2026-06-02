class CreateMerchants < ActiveRecord::Migration[8.1]
  def change
    create_table :merchants do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :status, null: false, default: "active"
      t.timestamps
    end
    add_index :merchants, :email, unique: true
  end
end
