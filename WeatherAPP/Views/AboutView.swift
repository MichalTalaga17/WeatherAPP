import SwiftUI

struct AboutView: View {
    let aboutText: String = """
    About WeatherAPP

    WeatherAPP is a comprehensive weather forecasting application designed to provide you with accurate and timely weather information. Our goal is to help you plan your day with confidence by delivering reliable weather updates and forecasts.

    Features:
    - Current weather conditions
    - Hourly and daily forecasts
    - Air pollution
    - Widgets

    Our Team:
    WeatherAPP is developed by a team of dedicated professionals passionate about weather and technology. We are committed to bringing you the best weather experience possible.

    Contact Us:
    If you have any questions, feedback, or suggestions, please reach out to us at michal.talaga.programming@gmail.com . We value your input and are here to assist you.

    Thank you for using WeatherAPP!
    """

    var body: some View {
        ScrollView {
            Text(aboutText)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
        }
        .navigationTitle("About WeatherAPP")
    }
}

#Preview {
    AboutView()
}
