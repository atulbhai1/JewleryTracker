//
//  Jewlery.swift
//  JewleryTracker
//
//  Created by Atul Nitin on 10/11/26.
//

import SwiftData
import Foundation

@Model
class JewleryItem {
    var name: String
    var weight: Decimal
    var purchasePrice: Decimal
    var purity: Int

    @Relationship(deleteRule: .cascade, inverse: \JewelryPhoto.item)
    var photos: [JewelryPhoto] = []

    init(name:String, weight: Decimal, purchasePrice: Decimal, purity: Int) {
        self.name = name
        self.weight = weight
        self.purchasePrice = purchasePrice
        self.purity = purity
    }
}

@Model
class JewelryPhoto {
    @Attribute(.externalStorage)
    var imageData: Data

    var dateAdded: Date
    var item: JewleryItem?

    init(imageData: Data, dateAdded: Date = .now) {
        self.imageData = imageData
        self.dateAdded = dateAdded
    }
}

func fetchLiveGoldPrice() async throws -> Decimal{
    var request = URLRequest(url: URL(string: "https://api.goldprice.dev/v1/prices?symbol=XAU-USD-SPOT")!)
    request.timeoutInterval = 10;
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200
    else { throw URLError(.badServerResponse) }
    print(String(data: data, encoding: .utf8)!)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    guard let symbols = json?["symbols"] as? [[String: Any]],
          let priceString = symbols.first?["price"] as? String,
          let price = Decimal(string: priceString)
    else { throw URLError(.cannotParseResponse) }
    return price
}
