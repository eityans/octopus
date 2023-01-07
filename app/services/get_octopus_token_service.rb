require "graphql/client"
require "graphql/client/http"

class GetOctopusTokenService
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new("https://api.oejp-kraken.energy/v1/graphql/")
  # Fetch latest schema on init, this will make a network request
  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  LOGIN_QUERY = Client.parse <<~'GRAPHQL'
    mutation Login($input: ObtainJSONWebTokenInput!) {
      obtainKrakenToken(input: $input) {
        token
        refreshToken
      }
    }
  GRAPHQL

  def perform
    res = Client.query(LOGIN_QUERY::Login, variables: {
      "input": {
        "email": ENV['OCTOPUS_EMAIL'],
        "password": ENV['OCTOPUS_PASSWORD']
      }
    })
    res.original_hash.dig("data", "obtainKrakenToken", "token")
  end

end
