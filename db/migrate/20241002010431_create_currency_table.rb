class CreateCurrencyTable < ActiveRecord::Migration[7.1]
  def change
    create_table :currencies do |t|
      t.string :symbol, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_index :currencies, :symbol, unique: true
  end
end
