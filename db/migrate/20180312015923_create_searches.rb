class CreateSearches < ActiveRecord::Migration[5.1]
  def change
    create_table :searches do |t|
      t.string :artist_id
      t.string :album_id
      t.float :score
      t.datetime :datetime

      t.timestamps
    end
  end
end
