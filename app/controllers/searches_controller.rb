class SearchesController < ApplicationController
  include Rspotify

  before_action :authenticate_rspotify, only: :new
  before_action :set_search, only: :show

  def new
    @search = Search.new
    @image = session[:artist_image_url]
    @albums = all_albums
  end

  def create
    @search = create_search

    respond_to do |format|
      if @search.save
        save_search_to_sessions(@search.id)
        format.html { redirect_to @search }
        format.json { render :show, status: :created, location: @search }
      else
        format.html { render :new }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @search = Search.find(params[:id])
  end

  private

  def all_albums
    artist = find_artist_by_id(session[:artist_id])
    format_albums(artist.albums(limit: 15, market: 'US'))
  end

  def format_albums(albums)
    formatted_albums = []
    albums.each do |album|
      formatted_album = {
        :album_id => album.id,
        :album_name => album.name
      }
      formatted_albums << formatted_album
    end
    formatted_albums.uniq { |formatted_album| formatted_album[:album_name] }
  end

  def set_search
    @search = Search.find(params[:id])
  end

  def create_search
    search = Search.new(search_params)
    search.artist_id = session[:artist_id]
    search.artist = session[:artist]

    album = find_album_by_id(search.album_id)
    search.album = album.name
    search.image = get_image_url(album.images)
    search.score = calculate_score(album)
    search
  end

  def search_params
    params.require(:search).permit(:album_id)
  end

  def save_search_to_sessions(search_id)
    searched = session.fetch(:searched, [])
    searched.unshift(search_id)
    session[:searched] = searched
  end

  def calculate_score(album)
    tracks = album.tracks
    mean = album_mean_popularity(tracks)
    standard_deviation = calculate_standard_deviation(tracks, mean)
    score = normalize_score(standard_deviation)
    format_score(score)
  end

  def album_mean_popularity(tracks)
    total_popularity = 0
    tracks.each do |track|
      total_popularity += track.popularity
    end
    total_popularity / tracks.length
  end

  def calculate_standard_deviation(tracks, mean)
    total = 0
    tracks.each do |track|
      difference = track.popularity - mean
      total += difference**2
    end
    Math.sqrt(total / tracks.length)
  end

  def normalize_score(standard_deviation)
    standard_deviation * 2
  end

  def format_score(score)
    score = 100 - score
    score.round(2)
  end
end
