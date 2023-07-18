class RickAndMortyCharactersController < ApplicationController
  resource_description do
    api_base_url '/'
    short 'Character information for characters from Rick and Morty.'
  end

  api :GET, '/'
  param :name, String, required: true, desc: 'The given name of the character to search for. Any letters occurring after a space are ignored.'
  def index
    render json: RickAndMortyApi.query_character_by_name(params[:name])
  end
end
