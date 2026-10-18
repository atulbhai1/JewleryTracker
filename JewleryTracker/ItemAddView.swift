//
//  ItemAddView.swift
//  JewleryTracker
//
//  Created by Atul Nitin on 10/17/26.
//
import SwiftUI

struct ItemAddView: View{
    @Environment(\.dismiss) private var dismiss
    @State var itemName: String = ""
    @State var itemWeight: Decimal = 0.00
    @State var itemPurity: Int = 24
    @State var itemPurchasePrice: Decimal = 0.00
    @FocusState private var focusedField: Field?

    enum Field{
        case name, weight
    }

    var body: some View{
        VStack{
            Form{
                HStack{
                    Text("What's the Item's Name?").font(.title2)
                    Spacer(minLength:20)
                    TextField(text: $itemName,label: {Text("Item Name")}).font(.title2).focused($focusedField, equals: .name)
                }
                HStack{
                    Text("What's the Item's Gold Weight?").font(.title2)
                    Spacer(minLength:20)
                    TextField(value: $itemWeight, format: .number, label: {Text("Item Weight")}).font(.title2).keyboardType(.decimalPad).focused($focusedField, equals: .weight)
                        
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 246.0/255.0, green: 250.0/255.0, blue: 175.0/255.0).ignoresSafeArea())
            Text("Pomato")
            
            
            
            
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
