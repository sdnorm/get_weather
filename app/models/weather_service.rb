require "httparty"

class WeatherService
  include HTTParty
  base_uri "https://api.tomorrow.io/v4"

  def self.fetch_current_weather
    options = {
      query: {
        location: @zip_code,
        apikey: Rails.application.credentials.tomorrow_io[:api_key],
        timesteps: "daily"
      }
    }

    response = get("/weather/forecast", options)

    if response.success?
      response.parsed_response
    else
      { error: response.parsed_response["error"] || "An error occurred" }
    end
  rescue JSON::ParserError
    { error: "Invalid response format" }
  end

  def self.todays_weather(zip_code)
    @zip_code = zip_code
    fetch_current_weather["data"][0]["timesteps"][0]
  end

  def self.extended_forecast(zip_code)
    @zip_code = zip_code
    # get the next 5 days of weather
    fetch_current_weather["data"][0]["timesteps"][1..5]
  end
end
