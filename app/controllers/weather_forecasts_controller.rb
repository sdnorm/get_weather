class WeatherForecastsController < ApplicationController
  def todays_weather
    @zip_code = params[:zip_code]
    cache_key = "todays_weather_#{@zip_code}"
    @is_cached = Rails.cache.exist?(cache_key)

    @todays_weather = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      WeatherService.new(@zip_code, "current").get_forecast
    end

    respond_to do |format|
      format.html
      format.turbo_stream { render "weather_forecasts/todays_weather" }
    end
  end

  def extended
    cache_key = "extended_weather_#{params[:zip_code]}"
    @is_cached = Rails.cache.exist?(cache_key)
    @extended_forecast = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      WeatherService.new(params[:zip_code], "extended").get_forecast
    end
    respond_to do |format|
      format.html
      format.turbo_stream { render "weather_forecasts/extended" }
    end
  end
end
