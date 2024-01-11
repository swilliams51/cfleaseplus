//
//  CashflowReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct CashflowReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State var myCashflows: Cashflows = Cashflows()
    @State private var myFont: Font = reportFontSmall
    
    @State private var combineDatesLabel: String = "Combine Dates Off"
    @State private var combineDatesImage: String = "square"
    @State private var combineDates: Bool = false
    
    @State private var showEBOCFsLabel: String = "EBO Cashflow"
    @State private var showEBOCFs: Bool = false
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        NavigationView {
            ScrollView (.vertical, showsIndicators: false) {
                Text("\(orientation.isLandscape.toString())")
                    .foregroundColor(.clear)
                Text(textForOneCashflow(aAmount: myLease.amount.toDecimal(), aCFs: myCashflows, currentFile: currentFile, isPad: isPad, isLandscape: orientation.isLandscape))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Cashflow")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar{
                Menu("options") {
                    combineDatesButtonItem
                    eboLeaseCashflowsItem
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
    
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            self.myCashflows = Cashflows(aLease: myLease)
            addFeesToCashflows()
            if self.isPad == true {
                self.myFont = reportFontTiny
            }
        }
        .onRotate { newOrientation in
            self.orientation = newOrientation
        }
    }
    
    var combineDatesButtonItem: some View {
        Button(action: {
            if self.combineDates == false {
                setCombineDatesToOn()
            } else {
                setCombineDatesToOff()
            }
        }) {
            HStack {
                Text(combineDatesLabel)
                Image(systemName: combineDatesImage)
            }
        }
    }
    
    func setCombineDatesToOn() {
        self.combineDates = true
        self.combineDatesLabel = "Combine Dates On"
        self.combineDatesImage = "checkmark.square"
        self.myCashflows.consolidateCashflows()
    }
    
    func setCombineDatesToOff() {
        self.combineDates = false
        self.combineDatesLabel = "Combine Dates Off"
        self.combineDatesImage = "square"
        self.myCashflows.items.removeAll()
        if self.showEBOCFs == true {
            self.myCashflows = Cashflows(aLease: eboLease(aLease: myLease, modDate: myLease.earlyBuyOut!.exerciseDate, rentDueIsPaid: myLease.earlyBuyOut!.rentDueIsPaid))
        } else {
            self.myCashflows = Cashflows(aLease: myLease)
        }
        addFeesToCashflows()
    }
    
    var eboLeaseCashflowsItem: some View {
        Button(action: {
            if self.showEBOCFs == false {
                self.showEBOCFs = true
                self.showEBOCFsLabel = "Lease Cashflow"
                self.myCashflows.items.removeAll()
                self.myCashflows = Cashflows(aLease: eboLease(aLease: myLease, modDate: myLease.earlyBuyOut!.exerciseDate, rentDueIsPaid: myLease.earlyBuyOut!.rentDueIsPaid))
                addFeesToCashflows()
                //
            } else {
                self.showEBOCFs = false
                self.showEBOCFsLabel = "EBO Cashflow"
                self.myCashflows = Cashflows(aLease: myLease)
                addFeesToCashflows()
            }
            setCombineDatesToOff()
        }) {
            Text(showEBOCFsLabel)
        }.disabled(myLease.eboExists() ? false : true )
    }
    
    func addFeesToCashflows() {
        if self.myLease.fees?.totalNetFees() ?? 0.0 > 0.0 {
            let cfFees: Cashflows = Cashflows(aFees: myLease.fees!, aFeeType: .all)
            myCashflows = myCashflows.addCashflow(aCFs: cfFees)
            myCashflows.consolidateCashflows()
        }

    }
    
}

struct CashflowReport_Previews: PreviewProvider {
    static var previews: some View {
        CashflowReport(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
    }
}
