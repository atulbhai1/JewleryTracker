import SwiftUI
import _SwiftData_SwiftUI
import Playgrounds

struct ContentView: View {
    @AppStorage("GoldPrice", store: UserDefaults(suiteName: "group.com.atulnitin1604.JewleryTracker"))
        private var goldprice = 4000
    @State private var viewSize: CGSize = .zero
    @Query var allItems: [JewleryItem]
    var body: some View {
        let total_weight = allItems.reduce(0) { $0 + $1.weight*Decimal($1.purity/24) }
        let total_price = allItems.reduce(0) { $0 + $1.purchasePrice }
        let total_value = total_weight*Decimal(goldprice)
        let profit = total_value - total_price
        NavigationStack {
        VStack {

            Text("Your Golden Jewlery Tracker").font(.largeTitle).bold().multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                .background(.yellow)
                .foregroundStyle(.white)
            
            Spacer(minLength: 20)
            if goldprice>0{
                Text("Latest Gold Price: $\(goldprice)")
                    .font(.title)
                    .bold()
                Text("Total Gold Value: \(total_value.formatted(.currency(code: "USD")))").font(.title).bold()
                Text("Total Pure Gold Weight: \(total_weight.formatted())g").font(.title).bold()
                HStack{
                    Text("Profit:").font(.title).bold()
                    Text("\(profit.formatted(.currency(code: "USD")))").foregroundStyle(profit > 0 ? .green : .red).font(.title).bold()
                }
            }
            else{
                Text("Couldn't Load Gold Price").font(.title).bold()
            }
            Spacer()
            Text("Jewlery Items").font(.largeTitle).bold()
            ScrollView{
                LazyVStack{
                    Button {
                        print("hi")
                        //Need to make add item view
                    } label: {

                        Text("Add Item")
                            .font(.title2)
                            .bold()
                            .padding(8)
                            .frame(maxWidth:viewSize.width*0.9)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 221.0/255.0, green: 227.0/255.0, blue: 115.0/255.0))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.yellow, lineWidth: 2)
                            )
                    }

                    ForEach(allItems){ item in
                        NavigationLink(destination: JewleryItemView(jewleryItem: item)){Text(item.name)
                                .font(.title2)
                                .bold()
                                .padding(8)
                                .frame(maxWidth:viewSize.width*0.9)
                                .background(.yellow)
                            .cornerRadius(10)}
                    }
                }
            }/*.frame(maxWidth:viewSize.width*0.9)
                .background(Color(red: 221.0/255.0, green: 227.0/255.0, blue: 115.0/255.0))
                .cornerRadius(40)*/



        }
        .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newValue in
                    viewSize = newValue
                }
        .frame(maxWidth: .infinity)
        .background(Color(red: 246.0/255.0, green: 250.0/255.0, blue: 175.0/255.0).ignoresSafeArea())
        }
    }
}

#Preview {
    ContentView()
}


