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

private struct TitleWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct JewleryItemView: View{
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var showImageDeletionPopup: Bool = false
    @State var showDeletionPopup: Bool = false
    @State private var selectedPicture: PhotosPickerItem?
    @State private var nameOverflowsTitleBar: Bool = false
    private let titleBarMaxWidth: CGFloat = 300
    var jewleryItem: JewleryItem
    let defaults = UserDefaults(suiteName: "group.com.atulnitin1604.JewleryTracker") ?? .standard
    var body: some View {
        let goldPrice = defaults.integer(forKey: "GoldPrice")
        let currentValue = jewleryItem.weight*(Decimal(jewleryItem.purity)/24.0)*Decimal(goldPrice)/31.1035
        let profit = currentValue - jewleryItem.purchasePrice
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if nameOverflowsTitleBar{
                    HStack{
                        Spacer()
                        Text(jewleryItem.name).font(.largeTitle).bold().multilineTextAlignment(.center).foregroundStyle(Color(red:92/255,green: 64/255, blue:51/255))
                        Spacer()
                    }
                }
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
                    PhotosPicker(
                                    selection: $selectedPicture,
                                    matching: .images, // Filter to only show images
                                    photoLibrary: .shared()
                                ) {
                                    Label("Select a Photo", systemImage: "photo")
                                        .font(.headline)
                                        .padding()
                                        .background(.yellow)
                                        .foregroundColor(.white)
                                        .clipShape(.capsule)
                                        .cornerRadius(8)
                                }
                                .onChange(of: selectedPicture) { _, newValue in
                                    guard let newValue else { return }
                                    Task {
                                        if let data = try? await newValue.loadTransferable(type: Data.self) {
                                            let photo = JewelryPhoto(imageData: data)
                                            modelContext.insert(photo)
                                            jewleryItem.photos.append(photo)
                                        }
                                        selectedPicture = nil
                                    }
                                }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 350)

                VStack(alignment: .leading, spacing: 12) {
                    LabeledContent("Weight") {
                        Text("\(jewleryItem.weight.formatted()) g")
                    }.foregroundStyle(Color(red:92/255,green: 64/255, blue:51/255))
                    LabeledContent("Purchase Price") {
                        Text(jewleryItem.purchasePrice, format: .currency(code: "USD"))
                    }.foregroundStyle(Color(red:92/255,green: 64/255, blue:51/255))
                    LabeledContent("Purity") {
                        Text("\(jewleryItem.purity)k")
                    }.foregroundStyle(Color(red:92/255,green: 64/255, blue:51/255))
                    LabeledContent("Current Value"){
                        if currentValue > 0{
                            Text("\(currentValue.formatted(.currency(code: "USD")))").foregroundStyle(Color(red:92/255,green: 64/255, blue:51/255))
                        }
                        else {
                            Text("Unable to fetch live gold price")
                        }
                    }.foregroundStyle(Color(red:92/255,green: 64/255, blue:51/255))
                    LabeledContent("Profit"){
                        if currentValue > 0{
                            Text("\(profit.formatted(.currency(code: "USD")))").foregroundStyle(profit > 0 ? .green : .red)
                        }
                        else {
                            Text("Unable to fetch live gold price")
                        }
                    }.foregroundStyle(Color(red:92/255,green: 64/255, blue:51/255))
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
        }
        .scrollContentBackground(.hidden)
        .background(Color(red: 246.0/255.0, green: 250.0/255.0, blue: 175.0/255.0).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                ZStack {
                    if !nameOverflowsTitleBar{
                        Text(jewleryItem.name)
                            .font(.largeTitle).bold()
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: titleBarMaxWidth)
                    }
                    Text(jewleryItem.name)
                        .font(.largeTitle).bold()
                        .padding(.horizontal, 20)
                        .fixedSize()
                        .hidden()
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: TitleWidthKey.self, value: geo.size.width)
                            }
                        )
                }
                .onPreferenceChange(TitleWidthKey.self) { naturalWidth in
                    nameOverflowsTitleBar = naturalWidth > titleBarMaxWidth
                }
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: ItemAddView(presetItem: jewleryItem)){
                    Label("modify", systemImage: "pencil")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("", systemImage: "trash"){
                    showDeletionPopup = true
                }.labelStyle(.iconOnly)
                    .tint(.blue)
            }
        }
        .toolbarBackground(.yellow, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Are you sure you want to delete this jewelery item?", isPresented: $showDeletionPopup){
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
    let item = JewleryItem(name: "Navaratna Set", weight: 5.2, purchasePrice: 450.00, purity: 22)
    item.photos = [
        JewelryPhoto(imageData: previewImageData(color: .systemYellow)),
        JewelryPhoto(imageData: previewImageData(color: .systemOrange)),
        JewelryPhoto(imageData: previewImageData(color: .systemBrown))
    ]
    return NavigationStack {
        JewleryItemView(jewleryItem: item)
    }
}
