//
//  FeesView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/15/23.
//

import SwiftUI

struct FeesView: View {
    @Binding var myFees: Fees?
    @ObservedObject var myLease: Lease
    @Binding var selfIsNew: Bool
    @Binding var isDark: Bool
    @Binding var showMenu: ShowMenu
   
    @State private var netAmount: Decimal = 0.0
    @State private var selectedFee: Fee? = nil
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Fee Groups")) {
                    if myFees?.items.count ?? 0 == 0 {
                        Text("No Fees")
                    } else {
                        ForEach(myFees!.items) { fee in
                            feeGroupItem(aFee: fee)
                        }
                    }
                    
                }
                Section (header: Text("Totals")) {
                    totalsSectionViewItem
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Add New Fee") {
                        myFees!.addNewFee()
                        myLease.fees = myFees
                    }
                }
            }
            .navigationTitle("Fees")
            .navigationBarTitleDisplayMode(.large)
            .onAppear{
                self.showMenu = .neither

            }
            .onDisappear{
                self.showMenu = .closed
            }
        }
        .fullScreenCover(item: $selectedFee) { myFee in
            FeeView2(myFee: myFee, myFees: myFees!, myLease: myLease, isDark: $isDark)
        }
        
    }
        
    @ViewBuilder func feeGroupItem(aFee: Fee) -> some View {
        VStack{
           
                //Row #1
                HStack {
                    Text(textForRowOne(aName:aFee.name))
                    Spacer()
                    Button(action: {
                        self.selectedFee = aFee
                    }) {
                       Text("Edit")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    } .disabled(selfIsNew ? true : false )

                }
                
                //Row #2
                HStack {
                    Text(textForRowTwo(aAmount: aFee.amount, aDate: aFee.effectiveDate, aIncomeType:aFee.incomeType))
                    Spacer()
                    Text("Place")
                        .font(.subheadline)
                        .foregroundColor(.clear)
                }
                
                //Row #3
                HStack {
                    Text(textForRowThree(aType: aFee.type, aLocked: aFee.locked))
                    Spacer()
                    Text("Place")
                        .font(.subheadline)
                        .foregroundColor(.clear)
                }
        }
    }
    
    var totalsSectionViewItem: some View {
        VStack {
            HStack{
                Text("Number:")
                Spacer()
                Text("Net Paid:")
            }
            HStack {
                Text("\(myFees!.items.count.toString())")
                Spacer()
                Text("\(myFees!.totalNetFees().toCurrency(false))")
            }
        }
        
    }

}

struct FeesView_Previews: PreviewProvider {
    static var previews: some View {
        FeesView(myFees: .constant(Fees()), myLease: Lease(aDate: today(), mode: .leasing), selfIsNew: .constant(false), isDark: .constant(false), showMenu: .constant(.open))
    }
}


// Functions
extension FeesView {
    func textForRowOne (aName: String) -> String {
        let strLine: String = aName
        return strLine
    }
    
    func textForRowTwo (aAmount: String, aDate: Date, aIncomeType: FeeIncomeType) -> String {
        let strLine: String = aAmount.toDecimal().toCurrency(false) + "  |  " + aDate.toStringDateShort(yrDigits: 2) + "  |  " + aIncomeType.toString()
        return strLine
    }
    
    func textForRowThree (aType: FeeType, aLocked: Bool) -> String {
        var strLocked: String = "Locked"
        if aLocked == false {
            strLocked = "Unlocked"
        }
        let strLine: String = aType.toString() + "  |  " + strLocked
        return strLine
    }
}
