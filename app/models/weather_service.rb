require "httparty"
# require "ostruct"

class WeatherService
  include HTTParty
  base_uri "https://api.tomorrow.io/v4"

  def initialize(zip_code, timesteps)
    @zip_code = zip_code
    @timesteps = normalize_timesteps(timesteps)
  end

  def get_forecast
    if @timesteps == "1m,1d"
      parse_current_weather(fetch_weather_data)
    elsif @timesteps == "daily"
      parse_extended_forecast(fetch_weather_data)
    end
  end

  private

  def normalize_timesteps(timesteps)
    case timesteps
    when "current" then "1m,1d"
    when "extended" then "daily"
    else timesteps
    end
  end

  def fetch_weather_data
    options = {
      query: {
        location: @zip_code,
        units: "imperial",
        timesteps: @timesteps,
        apikey: Rails.application.credentials.tomorrow_io_weather[:key]
      }
    }
    response = self.class.get("/weather/forecast", options)
    if response.success?
      response.parsed_response
    else
      if response.code == 429
        return { error: "Rate limit exceeded. Please try again later." }
      end
      { error: response.parsed_response["error"] || "An error occurred" }
    end
  rescue JSON::ParserError
    { error: "Invalid response format" }
  rescue HTTParty::Error => e
    { error: "HTTP request failed: #{e.message}" }
  end

  def parse_current_weather(data)
    minutely_data = data.dig("timelines", "minutely", 0, "values")
    daily_data = data.dig("timelines", "daily", 0)
    location_data = data.dig("location")
    OpenStruct.new(
      current_temp: minutely_data&.dig("temperature").round,
      high_temp: daily_data&.dig("values", "temperatureMax").round,
      low_temp: daily_data&.dig("values", "temperatureMin").round,
      location: location_data&.dig("name"),
      date: daily_data&.dig("time").to_date.strftime("%A, %B %d")
    )
  end

  def parse_extended_forecast(data)
    extended_forecast = []
    data.dig("timelines", "daily").map do |day|
      extended_forecast << OpenStruct.new(
        date: day["time"].to_date.strftime("%A, %B %d"),
        high_temp: day["values"]["temperatureMax"].round,
        low_temp: day["values"]["temperatureMin"].round
      )
    end
    extended_forecast
  end
end
