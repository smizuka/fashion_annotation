class CreateEditeds < ActiveRecord::Migration[5.2]
  def change
    create_table :editeds do |t|
      t.integer :user_id
      t.integer :annotation_id
      t.string :folder
      t.integer :state
      t.timestamps
    end
  end
end
