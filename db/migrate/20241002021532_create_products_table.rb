class CreateProductsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.string :expiration, null: false
      t.string :code, null: false
      t.references :upload_file, null: false, foreign_key: true

      t.timestamps
    end

    add_index :products, :expiration
    add_index :products, :name
    add_index :products, :price
  end
end
