//
//  ItemAddView.swift
//  JewleryTracker
//
//  Created by Atul Nitin on 10/17/26.
//
import SwiftUI
import PhotosUI
import SwiftData
import UIKit

struct ItemAddView: View{
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State var itemName: String
    @State var itemWeight: Decimal = 0.00
    @State var itemPurity: Int = 24
    @State var itemPurchasePrice: Decimal = 0.00
    @FocusState private var focusedField: Field?
    @State private var selectedImageItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    @State private var selectedImageData = [Data]()
    @State private var presetImageCount: Int = 0
    @State private var show_alert: Bool = false
    var presetItem: JewleryItem? = nil
    var dealing_with_prexisting_item: Bool

    enum Field{
        case name, weight, purity, purchasePrice
    }

    init(presetItem: JewleryItem? = nil) {
        self.presetItem = presetItem
        self.dealing_with_prexisting_item = presetItem != nil
        self._itemName = State(initialValue: presetItem?.name ?? "")
        self._itemWeight = State(initialValue: presetItem?.weight ?? 0.00)
        self._itemPurity = State(initialValue: presetItem?.purity ?? 24)
        self._itemPurchasePrice = State(initialValue: presetItem?.purchasePrice ?? 0.00)
    }

    var body: some View{
        VStack{
            Form{
                HStack{
                    Text("Item Name").font(.title2)
                    Spacer(minLength:20)
                    TextField(text: $itemName,label: {Text("Item Name")}).font(.title2).focused($focusedField, equals: .name)
                }.listRowBackground(Color.clear)
                HStack{
                    Text("Item Purity(kt)").font(.title2)
                    Spacer(minLength:20)
                    TextField(value: $itemPurity, format: .number, label: {Text("Item Purity")}).font(.title2).keyboardType(.decimalPad).focused($focusedField, equals: .purity)
                        .onChange(of: itemPurity) { _, newValue in
                            if newValue > 24 {
                                itemPurity = 24
                            }
                        }
                }.listRowBackground(Color.clear)
                HStack{
                    Text("Item's Gold Weight(g)").font(.title2)
                    Spacer(minLength:20)
                    TextField(value: $itemWeight, format: .number, label: {Text("Item Weight")}).font(.title2).keyboardType(.decimalPad).focused($focusedField, equals: .weight)
                        .onChange(of: itemWeight) { _, newValue in
                            if newValue < 0 {
                                itemWeight = 0
                            }
                        }
                }.listRowBackground(Color.clear)
                
                HStack{
                    Text("Purchase Price($)").font(.title2)
                    Spacer(minLength:20)
                    TextField(value: $itemPurchasePrice, format: .number, label: {Text("Purchase Price")}).font(.title2).keyboardType(.decimalPad).focused($focusedField, equals: .purchasePrice)
                        .onChange(of: itemPurchasePrice) { _, newValue in
                            if newValue < 0 {
                                itemPurchasePrice = 0
                            }
                        }
                }.listRowBackground(Color.clear)
                if !dealing_with_prexisting_item{
                    HStack{
                        Text("Pictures").font(.title2)
                        Spacer().frame(width: 20)
                        PhotosPicker("Select images(\(selectedImages.count))", selection: $selectedImageItems, matching: .images).foregroundStyle(.blue)
                    }.font(.title2)
                    
                        .listRowBackground(Color.clear)
                        .onChange(of: selectedImageItems) {
                            Task{
                                selectedImages = Array(selectedImages.prefix(presetImageCount))
                                selectedImageData = Array(selectedImageData.prefix(presetImageCount))
                                for image in selectedImageItems {
                                    if let imageItem = try? await image.loadTransferable(type: Image.self){
                                        selectedImages.append(imageItem)
                                    }
                                    if let data = try? await image.loadTransferable(type: Data.self){
                                        selectedImageData.append(data)
                                    }
                                }
                            }
                        }
                }
                HStack{
                    Spacer()
                    Button("Submit"){
                        let clearedName = itemName.replacingOccurrences(of: " ", with: "")
                        if clearedName.isEmpty{
                            show_alert = true
                        }
                        else{
                            if !dealing_with_prexisting_item{
                                let createdItem = JewleryItem(name: itemName, weight: itemWeight, purchasePrice: itemPurchasePrice, purity: itemPurity)
                                var jewleryPhotos = Array<JewelryPhoto>()
                                for data in selectedImageData{
                                    let temp = JewelryPhoto(imageData: data)
                                    jewleryPhotos.append(temp)
                                }
                                createdItem.photos = jewleryPhotos
                                modelContext.insert(createdItem)
                                for photo in jewleryPhotos{
                                    modelContext.insert(photo)
                                }
                                dismiss()
                            }
                            else{
                                presetItem?.name = itemName
                                presetItem?.weight = itemWeight
                                presetItem?.purchasePrice = itemPurchasePrice
                                presetItem?.purity = itemPurity
                                dismiss()
                            }
                        }
                    }.buttonStyle(.borderedProminent)
                        .tint(.yellow)
                        .font(.title)
                        .alert("Item Name Required", isPresented: $show_alert, actions: {
                            Button("OK"){
                                show_alert = false
                            }
                        })
                    Spacer()
                }.listRowBackground(Color.clear)
            }
            .foregroundStyle(Color(red:92/255,green: 64/255, blue:51/255))
            .scrollContentBackground(.hidden)
            .background(Color(red: 246.0/255.0, green: 250.0/255.0, blue: 175.0/255.0).ignoresSafeArea())
            .bold()
            
            //.font(.title2)
            
            
            
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Text("Add A Jewelry Item").font(.largeTitle).bold().foregroundStyle(.white)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .background(Color(red: 246.0/255.0, green: 250.0/255.0, blue: 175.0/255.0).ignoresSafeArea())
        .toolbarBackground(.yellow, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview{
    NavigationStack {
        ItemAddView()
    }
}
