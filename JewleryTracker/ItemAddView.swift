//
//  ItemAddView.swift
//  JewleryTracker
//
//  Created by Atul Nitin on 10/17/26.
//
import SwiftUI

struct ItemAddView: View{
    @Environment(\.dismiss) private var dismiss
    @State var itemName: String = "My item"
    @State var itemWeight: Decimal = 0.00
    @State var itemPurity: Int = 24
    @State var itemPurchasePrice: Decimal = 0.00

    var body: some View{
        VStack{
            Text("Pomato")
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Text("Add An Item").font(.largeTitle).bold().foregroundStyle(.white)
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
