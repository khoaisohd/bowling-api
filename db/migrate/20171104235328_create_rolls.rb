class CreateRolls < ActiveRecord::Migration[5.1]
  def change
    create_table :rolls do |t|
      t.string :username
      t.index :username
      t.integer :score
      t.references :game, foreign_key: true

      t.timestamps
    end
  end
end
