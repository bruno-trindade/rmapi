module RickAndMortyApi
  module Client
    class Character < Base
      ATTRIBUTES = %w|name status species gender image|

      def self.query_character_by_name(name_query)
        new.query_character_by_name(name_query)
      end

      def query_character_by_name(name_query)
        normalized_character_name = normalize_character_name(name_query)
        endpoint                  = character_endpoint(name: normalized_character_name)
        Rails.cache.fetch("season_appearances_#{normalized_character_name}", expires_in: CACHE_EXPIRY) do
          [].tap do |characters|
            while endpoint.present?
              begin
                response = make_request(endpoint)
                results  = response['results']
                characters.concat( results.map { |character_data| extract_character(character_data) } )
              rescue StandardError => e
                raise
              ensure
                endpoint = response.dig('info', 'next') rescue nil
              end
            end
          end
        end
      end

      private

      def character_endpoint(params = {})
        construct_endpoint(CHARACTER_ENDPOINT, params)
      end

      # This method makes additional calls to episode endpoints in the API to obtain the episode string.
      # This string is of the format "SxxEyy" where xx is the season number and yy is the episode number.
      # We parse the string to get the season, and keep count for that season in a Hash which is the
      # return value of this method.
      def extract_appearances(episode_data)
        return {} unless episode_data&.any?

        # I like this idiom of using scope when we're doing something a little complicated.  It helps protect
        # against developers forgetting to paste the variable name at the end of all the operations.
        {}.tap do |seasons|
          episode_data.each do |episode_url|
            begin
              episode_response = make_request(episode_url)
              episode_code     = episode_response['episode']
              season           = /S(\d+)E.+/.match(episode_code)[1]
              seasons[season]  = (seasons[season] || 0) + 1
            rescue StandardError => e
              Rails.logger.error("Error retrieving episode season information.")
              Rails.logger.error(e)
            end
          end
        end
      end

      def extract_character(character_data)
        character = character_data.slice(*ATTRIBUTES)
        character['appearances'] = extract_appearances(character_data['episode'])
        character
      end

      def normalize_character_name(name_query)
        name_query.downcase.split(/\s/).first
      end
    end
  end
end