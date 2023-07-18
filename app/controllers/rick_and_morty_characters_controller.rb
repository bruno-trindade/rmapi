class RickAndMortyCharactersController < ApplicationController
  def index
    render json: RickAndMortyApi.query_character_by_name(params[:name])
  end
end
