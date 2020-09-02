class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :uuid, null: false, index: true
      t.references :buyer, null: false ,foreign_key: { to_table: :users }
      t.integer :price, null: false
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
