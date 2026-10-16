import SwiftUI
import SwiftData

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color(red: 246.0/255.0, green: 250.0/255.0, blue: 175.0/255.0).ignoresSafeArea())//246, 250, 175
                .onAppear {
                    let defaults = UserDefaults(suiteName: "group.com.atulnitin1604.JewleryTracker") ?? .standard
                    if let lastUpdated = defaults.object(forKey: "lastUpdatedPrice") as? Date {
                        if Date().timeIntervalSince(lastUpdated) > 86400 {
                            Task {
                                do {
                                    print("Updating Gold Price")
                                    let newGoldPrice = try await fetchLiveGoldPrice()
                                    defaults.set(newGoldPrice, forKey: "GoldPrice")
                                    defaults.set(Date(), forKey:"lastUpdatedPrice")
                                } catch {
                                    print("Failed to fetch live gold price: \(error)")
                                }
                            }
                        }
                        else{
                            print("Not updating gold price - existing price found within last day")
                        }
                    }
                    else{
                        Task {
                            do {
                                print("Updating Gold Price")
                                let newGoldPrice = try await fetchLiveGoldPrice()
                                defaults.set(newGoldPrice, forKey: "GoldPrice")
                                defaults.set(Date(), forKey:"lastUpdatedPrice")
                            } catch {
                                print("Failed to fetch live gold price: \(error)")
                            }
                        }
                    }
                }
        }
        .modelContainer(for: [JewleryItem.self, JewelryPhoto.self])
    }
}
