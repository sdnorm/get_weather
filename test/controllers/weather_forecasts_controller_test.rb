require "test_helper"

class WeatherForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get current" do
    get weather_forecasts_current_url
    assert_response :success
  end

  test "should get extended" do
    get weather_forecasts_extended_url
    assert_response :success
  end
end
