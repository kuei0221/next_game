# frozen_string_literal: true

class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :name
      t.references :platform, null: false, foreign_key: true
      t.integer :price

      t.timestamps
    end
    add_index :games, :name
  end
end
