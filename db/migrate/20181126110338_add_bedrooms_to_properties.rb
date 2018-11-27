class AddBedroomsToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :bedrooms, :integer
  end
end
