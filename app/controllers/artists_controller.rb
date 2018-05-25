class ArtistsController < ApplicationController
  def index
    @image = session[:artist_image_url]
  end

  def new
  end

  def create
    @image = show_artists
    # render template: "/artists/index.html.erb"
    respond_to do |format|
      if @image
        session[:artist_image_url] = @image
        format.html { redirect_to action: :index }
        # format.json { render :index }
      end
    end
  end

  def show_artists
    authenticate_rspotify_client
    artist = params[:artist]
    main = RSpotify::Artist.search(artist).first
    get_image_url(main.images)
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
