require "graphql/client"
require "graphql/client/http"

module OctopusGraphql
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new("https://api.oejp-kraken.energy/v1/graphql/") do
    def headers(context)
      { "Authorization": GetOctopusTokenService.new.perform }
    end
  end
  # Fetch latest schema on init, this will make a network request
  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end
