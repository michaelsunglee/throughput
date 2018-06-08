class ArtistsController < ApplicationController
  include Rspotify

  before_action :authenticate_rspotify, only: :create

  def new
    @searched = format_searched(session.fetch(:searched, []))
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

  def format_searched(searched)
    formatted_searched = []
    searched.each do |id|
      search = Search.find(id)
      formatted_searched << search
    end
    formatted_searched
  end

  def show_artists
    artist = find_artist_by_name(params[:artist])
    session[:artist_id] = artist.id
    session[:artist] = artist.name
    get_image_url(artist.images)
  end
end
