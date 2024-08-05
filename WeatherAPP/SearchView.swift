import SwiftUI

struct SearchView: View {
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
                        
                        NavigationLink(destination: LocationWeatherView()) {
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
            }
            .padding()
            
            .background(Color.red)
        }
    }
    
}

#Preview {
    SearchView()
}
