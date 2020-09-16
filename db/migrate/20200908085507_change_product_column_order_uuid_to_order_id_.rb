# frozen_string_literal: true

class ChangeProductColumnOrderUuidToOrderId < ActiveRecord::Migration[6.0]
  def change
    rename_column :products, :order_uuid, :order_id
    reversible do |dir|
      dir.up { change_column :products, :order_id, :integer, using: 'order_id::integer' }
      dir.down { change_column :products, :order_id, :string, using: 'order_id::varchar' }
    end
    add_foreign_key :products, :orders
    add_index :products, :order_id
  end
end
