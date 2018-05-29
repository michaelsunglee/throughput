class SearchesController < ApplicationController
  before_action :set_search, only: %i[show edit update destroy]

  def show
    # change?
    puts "searches show"
    @artist = @search.artist
    @album = @search.album
    @score = @search.score
    @image = @search.image
  end

  def new
    # @search = Search.new
    @image = session[:artist_image_url]
    @albums = all_albums
  end

  def create
    session[:album_id] = params['album_id']
    session[:album_name] = params['album_name']
    search_params = create_search
    @search = Search.new(search_params)

    respond_to do |format|
      if @search.save
        format.html { redirect_to @search }
        format.json { render :show, status: :created, location: @search }
      else
        format.html { render :new }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def all_albums
    authenticate_rspotify_client
    artist = RSpotify::Artist.find(session[:artist_id])
    format_albums(artist.albums(limit: 12, market: 'US'))
  end

  def format_albums(albums)
    formatted_albums = []
    albums.each do |album|
      formatted_album = {
        :id => album.id,
        :name => album.name
      }
      formatted_albums << formatted_album
    end
    puts "CALLED MULTIPLE TIMES?"
    formatted_albums.uniq! { |formatted_album| formatted_album[:name] }
  end

  def set_search
    @search = Search.find(params[:id])
  end

  def search_params
    params.require(:search).permit(:artist_id, :album_id, :score, :datetime)
  end

  def authenticate_rspotify_client
    RSpotify::authenticate(Rails.application.secrets.rspotify_client,
                          Rails.application.secrets.rspotify_secret)
  end

  def create_search
    search = {}
    album_id = session[:album_id]
    album_object = find_album(album_id)

    search[:artist_id] = session[:artist_id]
    search[:artist] = session[:artist]
    search[:album_id] = album_id
    search[:album] = session[:album_name]
    search[:image] = get_image_url(album_object.images)
    search[:score] = calculate_score(album_object)
    search
  end

  def find_album(album_id)
    RSpotify::Album.find(album_id)
  end

  # TODO: fix this like artist
  def get_image_url(images)
    # The Spotify images array will have 3 pre-determined image sizes or none
    images.second['url'] || ''
  end

  def calculate_score(album_object)
    tracks = album_object.tracks
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
    Math.sqrt(total / (tracks.length - 1))
  end

  def normalize_score(standard_deviation)
    (standard_deviation / 50) * 100
  end

  def format_score(score)
    score = 100 - score
    score.round(2)
  end
end
