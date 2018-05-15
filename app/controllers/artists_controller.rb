class ArtistsController < ApplicationController
  def index
  end

  def find_artist
    artist = params[:artist]
    puts "artist is #{artist}"
  end
end
