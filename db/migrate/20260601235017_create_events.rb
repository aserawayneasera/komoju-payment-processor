class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :event_type, null: false
      t.jsonb :payload, default: {}
      t.timestamps
    end
    add_index :events, :event_type
  end
end
