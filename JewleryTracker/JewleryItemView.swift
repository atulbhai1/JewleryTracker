//
//  JewleryItemView.swift
//  JewleryTracker
//
//  Created by Atul Nitin on 10/12/26.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct JewleryItemView: View{
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var showImageDeletionPopup: Bool = false
    @State var showDeletionPopup: Bool = false
    var jewleryItem: JewleryItem
    let defaults = UserDefaults(suiteName: "group.com.atulnitin1604.JewleryTracker") ?? .standard
    var body: some View {
        var goldPrice = defaults.integer(forKey: "GoldPrice")
        let currentValue = jewleryItem.weight*(Decimal(jewleryItem.purity)/24.0)*Decimal(goldPrice)/31.1035
        let profit = currentValue - jewleryItem.purchasePrice
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                //Need to code, delete pictures option
                TabView {
                    ForEach(jewleryItem.photos) { photo in
                        if let uiImage = UIImage(data: photo.imageData) {
                            ZStack(alignment: .bottomTrailing){
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                Button("", systemImage: "trash.fill"){
                                    showImageDeletionPopup=true
                                }.backgroundStyle(.white)
                                    .buttonBorderShape(.circle)
                                    .buttonStyle(.borderedProminent)
                                    .padding()
                            }.alert("Are you sure you want to delete this image?", isPresented: $showImageDeletionPopup){
                                Button("Yes", role: .destructive){
                                    jewleryItem.photos.removeAll { $0 === photo }
                                    modelContext.delete(photo)
                                }
                                Button("Cancel", role: .cancel){
                                    showImageDeletionPopup = false
                                }
                            }
                            
                        }
                        
                    }
                    Button("Add Another Image", systemImage: "pencil"){
                        print("ATUL FINISH MEEEEE")
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 350)

                VStack(alignment: .leading, spacing: 12) {
                    LabeledContent("Weight") {
                        Text("\(jewleryItem.weight.formatted()) g")
                    }
                    LabeledContent("Purchase Price") {
                        Text(jewleryItem.purchasePrice, format: .currency(code: "USD"))
                    }
                    LabeledContent("Purity") {
                        Text("\(jewleryItem.purity)k")
                    }
                    LabeledContent("Current Value"){
                        if currentValue > 0{
                            Text("\(currentValue.formatted(.currency(code: "USD")))")
                        }
                        else {
                            Text("Unable to fetch live gold price")
                        }
                    }
                    LabeledContent("Profit"){
                        if currentValue > 0{
                            Text("\(profit.formatted(.currency(code: "USD")))").foregroundStyle(profit > 0 ? .green : .red)
                        }
                        else {
                            Text("Unable to fetch live gold price")
                        }
                    }
                }
                .padding(.horizontal)
            }
        }.toolbar {
            Button("", systemImage: "trash"){
                showDeletionPopup = true
            }.labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .tint(.blue)
        
        }.alert("Are you sure you want to delete this jewelery item?", isPresented: $showDeletionPopup){
            Button("Yes", role: .destructive){
                for photo in jewleryItem.photos{
                    modelContext.delete(photo)
                }
                modelContext.delete(jewleryItem)
                dismiss()
            }
            Button("Cancel", role: .cancel){
                showDeletionPopup = false
            }
        }
    }
}

private func previewImageData(color: UIColor) -> Data {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 300))
    let image = renderer.image { _ in
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 300, height: 300))
    }
    return image.pngData()!
}

#Preview {
    let item = JewleryItem(weight: 5.2, purchasePrice: 450.00, purity: 22)
    item.photos = [
        JewelryPhoto(imageData: previewImageData(color: .systemYellow)),
        JewelryPhoto(imageData: previewImageData(color: .systemOrange)),
        JewelryPhoto(imageData: previewImageData(color: .systemBrown))
    ]
    return NavigationStack {
        JewleryItemView(jewleryItem: item)
    }
}
