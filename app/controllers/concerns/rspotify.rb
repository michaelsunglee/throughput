module Rspotify
  extend ActiveSupport::Concern

  private

  def authenticate_rspotify
    rspotify_client = Rails.application.config.spotify_credentials[:rspotify_client]
    rspotify_secret = Rails.application.config.spotify_credentials[:rspotify_secret]
    RSpotify::authenticate(rspotify_client, rspotify_secret)
  end

  def find_artist_by_id(artist_id)
    RSpotify::Artist.find(artist_id)
  end

  def find_artist_by_name(query)
    RSpotify::Artist.search(query).first
  end

  def find_album_by_id(album_id)
    RSpotify::Album.find(album_id)
  end

  def get_image_url(images)
    # The Spotify images array is of various sizes but starts with widest. We
    # are selecting the image closest yet smaller than a width of 320
    ideal_images = images.select { |image| image['width'] <= 320 }
    ideal_image = ideal_images.first || images.second
    ideal_image['url']
  end
end
