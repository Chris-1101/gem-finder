class CreateProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :properties do |t|
      t.string :name
      t.string :price
      t.string :address
      t.string :location
      t.text :description
      t.string :photo
      t.string :average_sold_price_1year
      t.string :area_value_url
      t.string :crime_rating
      t.string :year

      t.timestamps
    end
  end
end
