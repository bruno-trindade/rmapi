# The main interface for the library that interacts with Rick and Morty API.
#
# When adding entry points for new queries, prefix it with `query_` for consistency.
# Query methods should have very little logic; prefer to delegate logic to the
# Client::Base subclasses.

require 'rick_and_morty_api/client/base'
require 'rick_and_morty_api/client/character'

module RickAndMortyApi
  def self.query_character_by_name(name_query)
    return [] unless name_query
    Client::Character.query_character_by_name(name_query)
  end

  # Other query entry points go in this module.
end