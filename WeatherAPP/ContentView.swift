import SwiftUI

struct ContentView: View {
    @State private var cityName = ""
    
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack {
                    Text("Pogoda")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 10) {
                        TextField("Podaj miasto", text: $cityName)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        
                        NavigationLink(destination: LocationWeatherView(cityName: cityName)) {
                            Text("Szukaj")
                                .font(.callout)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.bottom, 20)
                Spacer()
                
                CircularProgressView(
                    progress: 0.78,
                                gradientColors: [Color.yellow, Color.orange] // Ustal kolor gradientu
                            )
                                .frame(width: 150, height: 150)
            }
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.blue.opacity(0.7)]),
                startPoint: .bottom,
                endPoint: .top
            ))
        }
        
    }
    
}

#Preview {
    ContentView()
}
