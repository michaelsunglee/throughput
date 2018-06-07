class ArtistsController < ApplicationController
  include Rspotify

  before_action :authenticate_rspotify, only: :create

  def index
    @image = session[:artist_image_url]
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

  def show_artists
    artist = find_artist_by_name(params[:artist])
    session[:artist_id] = artist.id
    session[:artist] = artist.name
    get_image_url(artist.images)
  end
end
