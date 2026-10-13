import SwiftUI
import Playgrounds

struct ContentView: View {
    @AppStorage("GoldPrice", store: UserDefaults(suiteName: "group.com.atulnitin1604.JewleryTracker"))
        private var goldprice = 4000
    var body: some View {
        
        Text("Hello, world!")
            .padding()
        Text("Gold Price: \(goldprice)")
    }
}

#Preview {
    ContentView()
}


