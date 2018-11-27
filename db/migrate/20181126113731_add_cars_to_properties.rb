class AddCarsToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :cars, :integer
    add_column :properties, :bathrooms, :integer
  end
end
