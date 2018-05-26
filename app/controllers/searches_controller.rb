class SearchesController < ApplicationController
  before_action :set_search, only: %i[show edit update destroy]

  def index
    @searches = Search.all
  end

  def show
    @artist = @search.artist
    @album = @search.album
    @score = @search.score
    @image = @search.image
  end

  def new
    @search = Search.new
  end

  def create
    search_params = create_search
    puts "params are #{search_params}"
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

  def update
    respond_to do |format|
      if @search.update(search_params)
        format.html { redirect_to @search, notice: 'Search was successfully updated.' }
        format.json { render :show, status: :ok, location: @search }
      else
        format.html { render :edit }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @search.destroy
    respond_to do |format|
      format.html { redirect_to searches_url, notice: 'Search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

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
    authenticate_rspotify_client
    search = {}
    album = params['album']
    album_object = find_album(album)

    session[:artist_id] = session[:artist_id]
    search[:artist] = session[:artist]
    search[:album_id] = album_object.id
    search[:album] = album
    search[:image] = get_image_url(album_object.images)
    search[:score] = calculate_score(album)
    search
  end

  # def find_artist(artist)
  #   RSpotify::Artist.search(artist).first
  # end

  def find_album(album_query)
    artist = RSpotify::Artist.search(session[:artist]).first
    matching = artist.albums.select { |album| album.name == album_query }
    # TODO: fuzzy matching
    matching.first
    # RSpotify::Album.search(album).first
  end

  def get_image_url(images)
    # The Spotify images array will have 3 pre-determined image sizes or none
    images.second['url'] || ''
  end

  def calculate_score(album_name)
    tracks = find_album(album_name).tracks
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
