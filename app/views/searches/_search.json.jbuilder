json.extract! search, :id, :artist_id, :album_id, :score, :datetime, :created_at, :updated_at
json.url search_url(search, format: :json)
