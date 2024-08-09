# WeatherApp

WeatherApp is a weather application built in SwiftUI, utilizing `SwiftData` for data management and `WidgetKit` to display a dynamic widget on the home screen. The app allows users to search for cities, save favorite locations, and display current and forecasted weather conditions.

## Features

- **Weather Search:** Users can search for weather in selected cities using the OpenWeatherMap API.
- **Favorites List:** Users can add cities to their favorites for quick access to current weather information.
- **Dynamic Widget:** The home screen widget displays the current temperature, weather icon, and city name. Clicking on the widget takes the user to the detailed weather view in the app.

## Project Structure

### Main Components

- **`ContentView.swift`**: The main view structure of the app, responsible for searching cities and displaying the list of favorites.
- **`LocationWeatherView.swift`**: A detailed view showing the full weather forecast for the selected city.
- **`API.swift`**: A class responsible for fetching weather data from the OpenWeatherMap API.
- **`CurrentResponse.swift` & `ForecastData.swift`**: Data models for mapping JSON responses from the API to Swift structures.
- **`Wigets files`**: Code responsible for creating the widget, integrating with WidgetKit, and managing widget data.

### Widget

- **`WeatherWidgetMedium`**: Medium-sized widget with detailed weather information. Displays the city name, temperature, feels like temperature, humidity, wind speed, cloudiness, visibility, and pressure.

- **`WeatherWidget`**: Small widget with basic weather information. Shows the city name, current temperature, and weather icon.

- **`WeatherWidgetForecast`**: Medium-sized widget with a forecast for the next few hours. Presents the city name along with forecasted temperatures and icons for the upcoming hours.


## Requirements

- Xcode 14.0 or newer
- iOS 15.0 or newer
- OpenWeatherMap account to obtain an API key

## Installation

1. **Set up the project:**
   - Clone the repository and open the project in Xcode.
   - Add your API key to `API.swift` where `"{YourKey}"` is located.
   - Ensure `App Groups` is properly configured in the project settings.

2. **Building and running:**
   - Select the app target and run the project on a simulator or device.

3. **Widget Configuration:**
   - Ensure the widget is correctly set up to work with `App Groups`. The widget will read data saved by the app in `UserDefaults`.

## Usage

1. **Search for a city:**
   - Enter the city name in the search field and press `Search` to display the current weather for the selected location.

2. **Add to Favorites:**
   - You can add searched cities to your favorites list. These cities will appear on the main list in the app.

3. **Using the widget:**
   - Add the app widget to the home screen for quick access to the current weather in your favorite city. Clicking on the widget will take you to the detailed weather view in the app.

## Future Development

- **Notifications:** Adding notifications for changing weather conditions.
- **Expanded Widget:** Enhancing the widget with additional information, such as forecasts for the coming hours.
- **Support for more cities:** Allowing multiple cities to be added to the widget.

## Author

- **Michał Talaga**
- **Contact:** michal.talaga.programming@gmail.com

## License

The project is available under the MIT license. Details are in the `LICENSE` file.
