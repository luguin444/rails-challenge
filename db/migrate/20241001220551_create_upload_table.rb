class CreateUploadTable < ActiveRecord::Migration[7.1]
  def change
    create_table :upload_files do |t|
      t.string :file_url, null: false
      t.timestamps
    end

    add_index :upload_files, :file_url, unique: true
  end
end
