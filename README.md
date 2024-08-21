# WeatherApp

WeatherApp is a weather application built in SwiftUI, utilizing `SwiftData` for data management and `WidgetKit` to display a dynamic widget on the home screen. The app allows users to search for cities, save favorite locations, and display current and forecasted weather conditions.

## Features

- **Weather Search:** Users can search for weather in selected cities using the OpenWeatherMap API.
- **Favorites List:** Users can add cities to their favorites for quick access to current weather information.




## Requirements

- Xcode 14.0 or newer
- iOS 15.0 or newer
- OpenWeatherMap account to obtain an API key

## Installation

1. **Set up the project:**
   - Clone the repository and open the project in Xcode.
   - Add your API key to `API.swift` where `key` is located.

2. **Building and running:**
   - Select the app target and run the project on a simulator or device.


## Usage

1. **Search for a city:**
   - Enter the city name in the search field and press `Search` to display the current weather for the selected location.

2. **Add to Favorites:**
   - You can add searched cities to your favorites list. These cities will appear on the main list in the app.


## Future Development

- **Notifications:** Adding notifications for changing weather conditions.
- **Expanded Widget:** Enhancing the widget with additional information, such as forecasts for the coming hours.
- **Support for more cities:** Allowing multiple cities to be added to the widget.

## Author

- **Michał Talaga**
- **Contact:** michal.talaga.programming@gmail.com

## License

The project is available under the MIT license. Details are in the `LICENSE` file.
