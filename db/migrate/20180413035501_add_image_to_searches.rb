class AddImageToSearches < ActiveRecord::Migration[5.2]
  def change
    add_column :searches, :image, :string
  end
end
