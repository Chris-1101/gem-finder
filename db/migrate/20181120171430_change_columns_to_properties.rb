class ChangeColumnsToProperties < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :integer
    remove_column :properties, :area_value_url
    remove_column :properties, :average_sold_price_1year
    remove_column :properties, :crime_rating
    add_column :properties, :area_value_url, :float
    add_column :properties, :average_sold_price_1year, :float
    add_column :properties, :crime_rating, :integer
  end
end
