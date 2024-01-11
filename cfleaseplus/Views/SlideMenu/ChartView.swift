//
//  ChartView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/8/23.
//

import SwiftUI
import Charts

struct ChartView: View {
    @ObservedObject var myLease: Lease
    @State var myData:[ChartData] = ChartData.sample
    @State var cashOut: Decimal = 0.0
    @State var cashIn: Decimal = 0.0
    @State private var selectedSlice = -1
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Investment Summary")
                    .font(.headline)
                    .padding(.top, 20)
                ZStack{
                   
                    ForEach(0..<myData.count, id: \.self) { index in
                        Circle()
                            .trim(from: index == 0 ? 0.0 : myData[index - 1].slicePercent, to: myData[index].slicePercent)
                            .stroke(myData[index].color, lineWidth: 50)
                            .onTapGesture {
                                selectedSlice = selectedSlice == index ? -1 : index
                            }
                            .scaleEffect(index == selectedSlice ? 1.1 : 1.0)
                            .animation(.spring(), value: selectedSlice)
                        //Spacer()
                    }
                    if selectedSlice != -1 {
                        Text(String(format:"%.02f",Double(myData[selectedSlice].value))+"")
                    }
                }
                .frame(width: 150, height: 200)
                .padding(.top, 20)
                VStack {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]){
                        ForEach(myData) { data in
                            HStack {
                                Circle()
                                    .foregroundStyle(data.color.gradient)
                                    .frame(width:20, height: 20)
                                Text(data.title)
                                //Spacer()
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
        
        .onAppear{
//            let newOut:ChartData = ChartData(color: .red, value: myLease.amount.toCGFloat, title: "Lease Amount")
//            myData.append(newOut)
//            let newIn: ChartData = ChartData(color: .black, value: myLease.getTotalRents().toString().toCGFloat, title: "Total Rents")
//            myData.append(newIn)
            setupChartData()
        }
    }
    
    private func setupChartData() {
        let total:CGFloat = myData.reduce(0.0) { $0 + $1.value }
        for i in 0..<myData.count {
            let percentage = (myData[i].value / total)
            myData[i].slicePercent = (i == 0 ? 0.0 : myData[i - 1].slicePercent) + percentage
        }
        
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(myLease: Lease(aDate: today(), mode: .leasing))
    }
}

struct ChartData: Identifiable{
    var id = UUID()
    var color: Color
    var slicePercent: CGFloat = 0.0
    var value: Double
    var title: String
}

extension ChartData {
    static let sample: [ChartData] = [ChartData(color: .red, value: 1000000, title: "amount"), ChartData(color: .orange, value: 20000, title: "fees paid"),ChartData(color: .green, value: 355000, title: "profit"), ChartData(color: .black, value: 1200000, title: "rent"), ChartData(color: .gray, value: 175000, title: "residual")]
}

