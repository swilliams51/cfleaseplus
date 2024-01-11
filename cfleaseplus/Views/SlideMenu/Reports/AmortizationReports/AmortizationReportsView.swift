//
//  AmortizationReportsView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct AmortizationReportsView: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State var amortizationTitle: String = "Amortization"
    @State var eboAmortizationTitle: String = "EBO Amortization"
    @State var leaseBalanceAmortizationTitle: String = "Balance Amortization"
    
    @State private var purchaseFeeExists: Bool = false
    @State private var lesseePaidFeeExists: Bool = false

    @State private var eboLease: Lease = Lease(aDate: today(), mode: .leasing)
    @State private var balanceLease: Lease = Lease(aDate: today(), mode: .leasing)
    @State private var leaseBalanceActive: Bool = false
  
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AmortizationsReport(myLease: myLease, currentFile: $currentFile, reportTitle: $amortizationTitle, isDark: $isDark, isPad: $isPad)) {
                    Text("Interest Rate")
                        .font(.subheadline)
                }
                
                NavigationLink(destination: AmortizationsReport(myLease: eboLease, currentFile: $currentFile, reportTitle: $eboAmortizationTitle, isDark: $isDark, isPad: $isPad)){
                    Text("Early Buyout Rate")
                        .font(.subheadline)
                }.disabled(myLease.eboExists() ? false : true )
                
                NavigationLink(destination: AmortizationsReport(myLease: balanceLease, currentFile: $currentFile, reportTitle: $leaseBalanceAmortizationTitle, isDark: $isDark, isPad: $isPad)) {
                    Text("Oustanding Balance")
                        .font(.subheadline)
                }.disabled(leaseBalanceActive ? false : true)
                
                NavigationLink(destination: AnnualInterestReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                    Text("Interest Income")
                        .font(.subheadline)
                }
                
            }
            .navigationTitle("Amortization Reports")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            if self.myLease.eboExists() == true {
                self.eboLease = eboLease.resetLeaseToEBO(aLease: myLease, modDate: myLease.earlyBuyOut!.exerciseDate, amount: myLease.earlyBuyOut!.amount)
            }
            
            if modificationDate != "01/01/1900" {
                self.leaseBalanceActive = true
                self.balanceLease = modifiedLease(aLease: self.myLease, modDate: stringToDate(strAskDate: modificationDate))
            }
        }
    }
}

struct AmortizationReportsView_Previews: PreviewProvider {
    static var previews: some View {
        AmortizationReportsView(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
    }
}
