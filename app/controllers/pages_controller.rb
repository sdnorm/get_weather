class PagesController < ApplicationController
  def index
    @weather_data_cached = true
  end
end
