class RemoveDatetimeFromSearches < ActiveRecord::Migration[5.2]
  def change
    remove_column :searches, :datetime, :datetime
  end
end
