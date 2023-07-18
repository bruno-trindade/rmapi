Apipie.configure do |config|
  config.app_name                = "RMAPI"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  config.app_info['1.0']         = """
  A single-purpose, single-endpoint API for accessing character information from the Rick and Morty API (https://rickandmortyapi.com).
  """
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
