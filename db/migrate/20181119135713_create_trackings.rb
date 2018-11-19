class CreateTrackings < ActiveRecord::Migration[5.2]
  def change
    create_table :trackings do |t|
      t.integer :user_id
      t.string :property_id
      t.string :integer
      t.references :property, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
