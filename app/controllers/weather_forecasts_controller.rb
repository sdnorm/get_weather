class WeatherForecastsController < ApplicationController
  def todays_weather
    @zip_code = params[:zip_code]
    cache_key = "todays_weather_#{@zip_code}"
    @is_cached = Rails.cache.exist?(cache_key)
    @todays_weather = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      WeatherService.new(@zip_code, "current").get_forecast
    end

    if @todays_weather.is_a?(Hash) && @todays_weather.key?(:error)
      @error_message = @todays_weather[:error]
      @todays_weather = nil
    end

    respond_to do |format|
      format.html
      format.turbo_stream { render "weather_forecasts/todays_weather" }
    end
  end

  def extended
    @zip_code = params[:zip_code]
    cache_key = "extended_weather_#{@zip_code}"
    @is_cached = Rails.cache.exist?(cache_key)
    @extended_forecast = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      WeatherService.new(@zip_code, "extended").get_forecast
    end

    if @extended_forecast.is_a?(Hash) && @extended_forecast.key?(:error)
      @error_message = @extended_forecast[:error]
      @extended_forecast = nil
    end

    respond_to do |format|
      format.html
      format.turbo_stream { render "weather_forecasts/extended" }
    end
  end
end
