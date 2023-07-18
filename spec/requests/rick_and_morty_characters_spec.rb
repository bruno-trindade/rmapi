require 'rails_helper'

RSpec.describe "RickAndMortyCharacters", type: :request do

  before :each do
    stub_request(:get, "https://rickandmortyapi.com/api/character/")
    .with(query: { "page" => 2, "name" => 'rick', "status" => 'alive' })
    .to_return(status: 200, body: {
      info: {
        count: 29,
        pages: 2,
        next:  nil,
        prev:  "https://rickandmortyapi.com/api/character/?page=1&name=rick"
      },
      results: [
        {
          id:      103,
          name:    "Doofus Rick",
          status:  "alive",
          species: "Human",
          type:    "",
          gender:  "Male",
          origin: {
            name: "Earth",
            url:  "https://rickandmortyapi.com/api/location/1"
          },
          location: {
            name: "Earth",
            url:  "https://rickandmortyapi.com/api/location/20"
          },
          image: "https://rickandmortyapi.com/api/character/avatar/103.jpeg",
          episode: [
            "https://rickandmortyapi.com/api/episode/10",
            "https://rickandmortyapi.com/api/episode/22"
          ],
          url:     "https://rickandmortyapi.com/api/character/103",
          created: "2017-11-04T18:48:46.250Z"
        }
      ]
    }.to_json, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "https://rickandmortyapi.com/api/character/")
    .with(query: { "name" => 'rick' })
    .to_return(status: 200, body: {
      info: {
        count: 29,
        pages: 2,
        next:  "https://rickandmortyapi.com/api/character/?page=2&name=rick&status=alive",
        prev:  nil
      },
      results: [
        {
          id:      1,
          name:    "Rick Sanchez",
          status:  "Alive",
          species: "Human",
          type:    "",
          gender:  "Male",
          origin: {
            name: "Earth",
            url:  "https://rickandmortyapi.com/api/location/1"
          },
          location: {
            name: "Earth",
            url:  "https://rickandmortyapi.com/api/location/20"
          },
          image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
          episode: [
            "https://rickandmortyapi.com/api/episode/1",
            "https://rickandmortyapi.com/api/episode/2",
            "https://rickandmortyapi.com/api/episode/3"
          ],
          url:     "https://rickandmortyapi.com/api/character/1",
          created: "2017-11-04T18:48:46.250Z"
        }
      ]
    }.to_json, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /rickandmortyapi.com\/api\/episode\/1/)
    .to_return(status: 200, body: {
      episode: 'S01E03'
    }.to_json, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /rickandmortyapi.com\/api\/episode\/2/)
    .to_return(status: 200, body: {
      episode: 'S04E06'
    }.to_json, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /rickandmortyapi.com\/api\/episode\/3/)
    .to_return(status: 200, body: {
      episode: 'S04E09'
    }.to_json, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /rickandmortyapi.com\/api\/episode\/10/)
    .to_return(status: 200, body: {
      episode: 'S02E01'
    }.to_json, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /rickandmortyapi.com\/api\/episode\/22/)
    .to_return(status: 200, body: {
      episode: 'S02E02'
    }.to_json, headers: {'Content-Type' => 'application/json'})
  end

  describe "GET /index" do
    context "When a first name is not supplied" do
      it 'returns an empty set' do
        get api_rick_and_morty_characters_path
        expect(response.body).to eq('[]')
      end
    end

    context "When a first name is supplied" do
      before do
        get api_rick_and_morty_characters_path(name: 'rick')
      end

      it 'returns the characters from all result pages' do
        characters = JSON.parse(response.body)
        expect(characters.length).to eq(2)
      end

      it 'returns the correct data for the character' do
        characters = JSON.parse(response.body)
        characters.each do |character|
          expect(character.keys).to include(*RickAndMortyApi::Client::Character::ATTRIBUTES)
        end
      end

      it 'returns the correctly calculated season appearances for the character' do
        characters = JSON.parse(response.body)

        # Rick Sanchez
        expect(characters[0]['appearances']).to eq({ '01' => 1, '04' => 2 })

        # Doofus Rick
        expect(characters[1]['appearances']).to eq({ '02' => 2 })
      end
    end
  end
end
