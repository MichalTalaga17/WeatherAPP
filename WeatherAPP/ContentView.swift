import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cities: [City]
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
                .padding(.bottom, 40)
                List {
                    ForEach(cities) { item in
                        NavigationLink(destination: LocationWeatherView(cityName: cityName)) {
                            Text(item.name)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                Spacer()
            }
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.blue.opacity(0.7)]),
                startPoint: .bottom,
                endPoint: .top
            ))
            
            
        }
        
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cities[index])
            }
        }
    }
    
    
}


#Preview {
    ContentView()
}
