class ChangeStocksTableNameToProducts < ActiveRecord::Migration[6.0]
  def up
    remove_index :stocks, [:user_id, :game_id]
    remove_foreign_key :stocks, :games
    remove_foreign_key :stocks, :users
    rename_table :stocks, :products
    add_foreign_key :products, :games
    add_foreign_key :products, :users
  end

  def down
    remove_foreign_key :products, :games
    remove_foreign_key :products, :users
    rename_table :products, :stocks
    add_foreign_key :stocks, :games
    add_foreign_key :stocks, :users
    add_index :stocks, [:user_id, :game_id], unique: true
  end
end
