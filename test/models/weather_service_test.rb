require "test_helper"
require "webmock/minitest"

class WeatherServiceTest < ActiveSupport::TestCase
  setup do
    @api_key = "test_api_key"
    Rails.application.credentials.stubs(:dig).with(:tomorrow_io_weather, :key).returns(@api_key)
  end
end
