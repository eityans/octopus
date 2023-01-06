class OctopusController < ApplicationController

  QUERY = OctopusGraphql::Client.parse <<~'GRAPHQL'
    query HalfHourlyReadings($accountNumber: String!, $fromDatetime: DateTime, $toDatetime: DateTime) {
      account(accountNumber: $accountNumber) {
        properties {
          electricitySupplyPoints {
            halfHourlyReadings(fromDatetime: $fromDatetime, toDatetime: $toDatetime) {
              startAt
              endAt
              version
              value
            }
          }
        }
      }
    }
  GRAPHQL

  def index
    p OctopusGraphql::Client.query(QUERY::HalfHourlyReadings, variables: {
      accountNumber: ENV['OCTOPUS_ACCOUNT_NUMBER'],
      fromDatetime: "2022-08-14T15:00:00.000Z",
      toDatetime: "2022-12-14T17:00:00.000Z"
    })
  end
end

