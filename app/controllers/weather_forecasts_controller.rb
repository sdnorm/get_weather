class WeatherForecastsController < ApplicationController
  def extended
    respond_to do |format|
      format.html
      format.turbo_stream { render "weather_forecasts/extended" }
    end
  end
end
