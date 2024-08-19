class PagesController < ApplicationController
  def index
    @weather_data_cached = false
  end
end
