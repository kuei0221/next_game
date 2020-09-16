# frozen_string_literal: true

class AddTypeAndOrderUuidToStock < ActiveRecord::Migration[6.0]
  def up
    add_column :stocks, :type, :string
    add_column :stocks, :order_uuid, :string, index: true
    execute "UPDATE stocks SET type = 'Stock'"
    change_column :stocks, :type, :string, null: false
  end

  def down
    remove_column :stocks, :type, :string
    remove_column :stocks, :order_uuid, :string
  end
end
