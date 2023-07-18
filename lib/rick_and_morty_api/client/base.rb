module RickAndMortyApi
  module Client
    class Base
      BASE_URL           = 'rickandmortyapi.com'.freeze
      CACHE_EXPIRY       = 24.hours
      CHARACTER_ENDPOINT = 'api/character'.freeze

      def initialize
        @api = Faraday.new("https://#{BASE_URL}") do |f|
          f.response :json
        end
      end

      def make_request(endpoint)
        api.get(endpoint).body
      end

      private

      attr_reader :api

      def construct_endpoint(endpoint, params = {})
        "#{endpoint}/?#{ params.to_a.map{ |k, v| "#{k}=#{v}" }.join('&') }"
      end
    end
  end
end