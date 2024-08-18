class WeatherService < ApplicationRecord
  CURRENT_WEATHER_URL = "https://api.tomorrow.io/v4/weather/forecast"
  # ?location=70769&apikey=#{Rails.application.credentials.tomorrow_io_weather[:key]}"
end
