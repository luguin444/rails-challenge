class CreateCurrenciesRatesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :currency_rates do |t|
      t.references :upload_file, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.decimal :rate, null: false

      t.timestamps
    end

    add_index :currency_rates, [:upload_file_id, :currency_id], unique: true
  end
end
