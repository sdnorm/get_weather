require "test_helper"

class WeatherServiceTest < ActiveSupport::TestCase
  def setup
    @zip_code = "12345"
    @api_key = "fake_api_key"
    Rails.application.credentials.stubs(:tomorrow_io_weather).returns({ key: @api_key })
  end

  test "initialize sets zip_code and normalizes timesteps" do
    service = WeatherService.new(@zip_code, "current")
    assert_equal @zip_code, service.instance_variable_get(:@zip_code)
    assert_equal "1m,1d", service.instance_variable_get(:@timesteps)
  end

  test "get_forecast returns current weather" do
    mock_response = {
      "timelines" => {
        "minutely" => [ { "values" => { "temperature" => 72.5 } } ],
        "daily" => [
          {
            "time" => "2023-04-15T00:00:00Z",
            "values" => { "temperatureMax" => 75.2, "temperatureMin" => 68.7 }
          }
        ]
      },
      "location" => { "name" => "Test City" }
    }

    WeatherService.any_instance.stubs(:fetch_weather_data).returns(mock_response)

    service = WeatherService.new(@zip_code, "current")
    forecast = service.get_forecast

    assert_equal 73, forecast.current_temp
    assert_equal 75, forecast.high_temp
    assert_equal 69, forecast.low_temp
    assert_equal "Test City", forecast.location
    assert_equal "Saturday, April 15", forecast.date
  end

  test "get_forecast returns extended forecast" do
    mock_response = {
      "timelines" => {
        "daily" => [
          { "time" => "2023-04-15T00:00:00Z", "values" => { "temperatureMax" => 75.2, "temperatureMin" => 68.7 } },
          { "time" => "2023-04-16T00:00:00Z", "values" => { "temperatureMax" => 77.5, "temperatureMin" => 70.1 } }
        ]
      }
    }

    WeatherService.any_instance.stubs(:fetch_weather_data).returns(mock_response)

    service = WeatherService.new(@zip_code, "extended")
    forecast = service.get_forecast

    assert_equal 2, forecast.length
    assert_equal "Saturday, April 15", forecast[0].date
    assert_equal 75, forecast[0].high_temp
    assert_equal 69, forecast[0].low_temp
    assert_equal "Sunday, April 16", forecast[1].date
    assert_equal 78, forecast[1].high_temp
    assert_equal 70, forecast[1].low_temp
  end

  test "fetch_weather_data handles rate limit error" do
    mock_response = Struct.new(:success?, :code, :parsed_response).new(false, 429, {})
    WeatherService.stubs(:get).returns(mock_response)

    service = WeatherService.new(@zip_code, "current")
    result = service.send(:fetch_weather_data)

    assert_equal({ error: "Rate limit exceeded. Please try again later." }, result)
  end

  test "fetch_weather_data handles general error" do
    mock_response = Struct.new(:success?, :code, :parsed_response).new(false, 500, { "message" => "Server error" })
    WeatherService.stubs(:get).returns(mock_response)

    service = WeatherService.new(@zip_code, "current")
    result = service.send(:fetch_weather_data)

    assert_equal({ error: "Server error" }, result)
  end

  test "fetch_weather_data handles unexpected error format" do
    mock_response = Struct.new(:success?, :code, :parsed_response).new(false, 500, "Unexpected error")
    WeatherService.stubs(:get).returns(mock_response)

    service = WeatherService.new(@zip_code, "current")
    result = service.send(:fetch_weather_data)

    assert_equal({ error: "An error occurred: 500" }, result)
  end

  test "parse_current_weather handles missing data" do
    service = WeatherService.new(@zip_code, "current")
    result = service.send(:parse_current_weather, { "timelines" => {} })

    assert_equal({ error: "Unable to retrieve weather data. Please check your zip code and try again." }, result)
  end

  test "parse_extended_forecast handles missing data" do
    service = WeatherService.new(@zip_code, "extended")
    result = service.send(:parse_extended_forecast, { "timelines" => {} })

    assert_equal({ error: "Unable to retrieve extended forecast. Please check your zip code and try again." }, result)
  end
end
