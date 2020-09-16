# frozen_string_literal: true

class CreateStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :stocks do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :price, null: false
      t.integer :quantity, default: 0
      t.integer :state, default: 0

      t.timestamps
    end
    add_index :stocks, %i[user_id game_id], unique: true
  end
end
