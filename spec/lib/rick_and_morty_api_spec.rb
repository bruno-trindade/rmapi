# Most of the functionality of this library should be confirmed through integration/request spec.
# See requests/rick_and_morty_characters_spec.rb

require 'rails_helper'

RSpec.describe RickAndMortyApi do
  describe '::query_character_by_name' do
    let(:name_query) { 'rick sanchez' }
    let(:normalized_name) { 'rick' }
    let!(:character_client) { RickAndMortyApi::Client::Character.new }

    subject { RickAndMortyApi.query_character_by_name(name_query) }

    before do
      allow(RickAndMortyApi::Client::Character).to receive(:new).and_return(character_client)
      allow_any_instance_of(RickAndMortyApi::Client::Base).to receive(:make_request)
      .and_return({ 'results' => [], 'episode' => [] })
    end

    it 'queries with a normalized name' do
      expect(character_client).to receive(:normalize_character_name).and_return(normalized_name)
      subject
    end

    it 'caches the data' do
      expect(Rails.cache).to receive(:fetch).with("season_appearances_#{normalized_name}", expires_in: RickAndMortyApi::Client::Base::CACHE_EXPIRY)
      subject
    end
  end
end