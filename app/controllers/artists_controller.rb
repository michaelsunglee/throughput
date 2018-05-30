class ArtistsController < ApplicationController
  def index
    @image = session[:artist_image_url]
  end

  def new
  end

  def create
    @image = show_artists
    respond_to do |format|
      if @image
        session[:artist_image_url] = @image
        format.html { redirect_to controller: :searches, action: :new }
      end
    end
  end

  private

  def authenticate_rspotify_client
    rspotify_client = Rails.application.config.spotify_credentials[:rspotify_client]
    rspotify_secret = Rails.application.config.spotify_credentials[:rspotify_secret]
    RSpotify::authenticate(rspotify_client, rspotify_secret)
  end

  def show_artists
    authenticate_rspotify_client
    artist_query = params[:artist]
    # TODO: find artist abstraction
    artist = RSpotify::Artist.search(artist_query).first
    session[:artist] = artist_query
    session[:artist_id] = artist.id
    get_image_url(artist.images)
  end

  def get_image_url(images)
    # The Spotify images array is of various sizes but starts with widest. We
    # are selecting the image closest yet smaller than a width of 320
    ideal_images = images.select { |image| image['width'] <= 320 }
    ideal_image = ideal_images.first || images.second
    ideal_image['url']
  end
end
