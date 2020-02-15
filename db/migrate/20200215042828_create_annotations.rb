class CreateAnnotations < ActiveRecord::Migration[5.2]
  def change
    create_table :annotations do |t|
      t.integer :user_id
      t.integer :annotation_id
      t.string :path
      t.string :folder_name
      t.string :information
      t.timestamps
    end
  end
end
