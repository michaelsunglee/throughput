class AddAlbumToSearches < ActiveRecord::Migration[5.1]
  def change
    add_column :searches, :album, :string
  end
end
