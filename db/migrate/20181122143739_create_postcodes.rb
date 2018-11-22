class CreatePostcodes < ActiveRecord::Migration[5.2]
  def change
    create_table :postcodes do |t|
      t.string :outcode
      t.string :incode
      t.string :crime_rating
      t.string :property_type
      t.string :avg_current_first
      t.string :avg_price_foot
      t.string :avg_paid
      t.string :avg_area
      t.string :table_facts

      t.timestamps
    end
  end
end
