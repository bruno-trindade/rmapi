require 'rick_and_morty_api/client/base'
require 'rick_and_morty_api/client/character'

module RickAndMortyApi
  def self.query_character_by_name(name_query)
    return [] unless name_query
    Client::Character.query_character_by_name(name_query)
  end

  # Other query entry points go in this module.
end