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
        format.html { redirect_to action: :index }
      end
    end
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

  private

  def authenticate_rspotify_client
    RSpotify::authenticate(Rails.application.secrets.rspotify_client,
                          Rails.application.secrets.rspotify_secret)
  end

  def get_image_url(images)
    # The Spotify images array will have 3 pre-determined image sizes or none
    images.second['url'] || ''
  end
end
