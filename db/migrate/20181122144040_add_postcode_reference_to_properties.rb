class AddPostcodeReferenceToProperties < ActiveRecord::Migration[5.2]
  def change
    add_reference :properties, :postcode, foreign_key: true
  end
end
