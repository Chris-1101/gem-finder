class AddPhotoToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :photo, :string
    add_column :properties, :address, :string
  end
end
