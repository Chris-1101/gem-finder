class AddYearToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :year, :string
  end
end
