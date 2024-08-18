require "test_helper"

class WeatherForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get extended" do
    get extended_weather_forecast_url
    assert_response :success
  end
end
