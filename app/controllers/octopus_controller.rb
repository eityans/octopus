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
              costEstimate
            }
          }
        }
      }
    }
  GRAPHQL

  def index
    @text = gen_text
    send_line_message
  end

  private

  def send_line_message
    message = {
      type: 'text',
      text: @text
    }

    client = Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    end

    client.broadcast(message)
  end

  def gen_text
    res = OctopusGraphql::Client.query(QUERY::HalfHourlyReadings, variables: {
      accountNumber: ENV['OCTOPUS_ACCOUNT_NUMBER'],
      fromDatetime: Date.yesterday.beginning_of_day.iso8601,
      toDatetime: Date.yesterday.end_of_day.iso8601
    })
    properties = res.original_hash.dig("data", "account", "properties")
    electricitySupplyPoints = properties.first["electricitySupplyPoints"]
    halfHourlyReadings = electricitySupplyPoints.first["halfHourlyReadings"]
    start_at = Time.zone.parse(halfHourlyReadings.pluck("startAt").min).strftime("%Y/%m/%d %H:%M")
    end_at = Time.zone.parse(halfHourlyReadings.pluck("endAt").max).strftime("%Y/%m/%d %H:%M")
    kwh = halfHourlyReadings.pluck("value").map(&:to_f).sum
    cost = halfHourlyReadings.pluck("costEstimate").map(&:to_i).sum

    "#{start_at}から#{end_at}までの電力消費量は#{kwh}kWhで#{cost}円です。"
  end
end

