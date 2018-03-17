class AddArtistToSearches < ActiveRecord::Migration[5.1]
  def change
    add_column :searches, :artist, :string
  end
end
