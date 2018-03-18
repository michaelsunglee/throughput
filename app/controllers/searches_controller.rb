class SearchesController < ApplicationController
  before_action :set_search, only: [:show, :edit, :update, :destroy]

  # GET /searches
  # GET /searches.json
  def index
    @searches = Search.all
  end

  # GET /searches/1
  # GET /searches/1.json
  def show
    @artist = @search.artist
    @album = @search.album
  end

  # GET /searches/new
  def new
    @search = Search.new
  end

  # GET /searches/1/edit
  def edit
  end

  # POST /searches
  # POST /searches.json
  def create
    search_params = create_search(params)

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

  # PATCH/PUT /searches/1
  # PATCH/PUT /searches/1.json
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

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search.destroy
    respond_to do |format|
      format.html { redirect_to searches_url, notice: 'Search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = Search.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:search).permit(:artist_id, :album_id, :score, :datetime)
    end

    def authenticate_rspotify_client
      RSpotify::authenticate(Rails.application.secrets.rspotify_client,
                            Rails.application.secrets.rspotify_secret)
    end

    def create_search(params)
      authenticate_rspotify_client
      artist = params['search']['artist']
      album = params['search']['album']

      params = {}

      params[:artist_id] = find_artist(artist).id
      params[:album_id] = find_album(album).id
      params[:artist] = artist
      params[:album] = album
      params[:score] = calculate_score(album)
      params[:datetime] = Time.now
      params
    end

    def find_artist(artist)
      RSpotify::Artist.search(artist).first
    end

    def find_album(album)
      RSpotify::Album.search(album).first
    end

    def calculate_score(album_name)
      album = find_album(album_name)
      total_popularity = 0
      album.tracks.each do |track|
        total_popularity += track.popularity
      end
      total_popularity/album.tracks.length
    end
end
