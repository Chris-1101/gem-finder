class CreateProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :properties do |t|
      t.string :price
      t.string :integer
      t.string :location
      t.string :name
      t.string :area_value_url
      t.string :integer
      t.string :average_sold_price_1year
      t.string :integer
      t.string :crime_rating
      t.string :integer

      t.timestamps
    end
  end
end
