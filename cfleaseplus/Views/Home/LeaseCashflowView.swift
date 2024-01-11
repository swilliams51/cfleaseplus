//
//  CashflowSummaryView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/11/23.
//

import SwiftUI

struct LeaseCashflowView: View {
    @ObservedObject var myLease: Lease
    @State private var totalCashOut: Decimal = 0.0
    @State private var totalCashIn: Decimal = 0.0
    @State private var totalNetCash: Decimal = 0.0

    @Binding var isDark: Bool
    
    var body: some View {
        VStack{
            cashFlowTitleItem
            totalCashOutItem
            totalCashInItem
            totalNetCashItem
            Spacer()
        }
        .padding(.horizontal, 18)
        .overlay (
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("AccentColor"), lineWidth: 4)
        )
        .padding(.horizontal, 25)
        .onAppear {
           setPrivateVars()
        }
    }
    
    var totalCashOutItem: some View {
        VStack {
            HStack {
                Text ("Amount:")
                    .font(myTabLabelFont)
                    .padding(.leading, myTabMargin)
                    .foregroundColor(myTabFontColor)
                Spacer()
                Text("\(myLease.amount.toDecimal().toCurrency(false))")
                    .font(myTabResultsFont)
                    .padding(.trailing, myTabMargin)
                    .foregroundColor(myTabFontColor)
            }
               
            HStack{
                Text ("Fees Paid:")
                    .font(myTabLabelFont)
                    .padding(.leading, myTabMargin)
                    .foregroundColor(myTabFontColor)
                Spacer()
                Text("\((myLease.fees?.totalFeesPaid() ?? 0.00).toCurrency(false))")
                    .font(myTabResultsFont)
                    .padding(.trailing, myTabMargin)
                    .foregroundColor(myTabFontColor)
            }
            HStack{
                Text ("Total Out:")
                    .font(myTabLabelFont)
                    .padding(.leading, 50)
                    .foregroundColor(myTabFontColor)
                Spacer()
                Text("\(totalCashOut.toCurrency(false))")
                    .font(myTabResultsFont)
                    .padding(.trailing, myTabMargin)
                    .foregroundColor(myTabFontColor)
            }
            
            Divider()
                .frame(width: 200, height: 1)
                .overlay(myTabFontColor)
        }
    }
    
    var cashFlowTitleItem: some View {
        HStack {
            Text("CASHFLOW")
                .font(myTabResultsFont)
                .padding(.top, myTabTopMargin)
                .padding(.bottom, 1)
                .foregroundColor(myTabFontColor)
        }
    }
    
    var totalCashInItem: some View {
        VStack {
            HStack{
                Text("Fees Received:")
                    .font(myTabLabelFont)
                    .padding(.leading, myTabMargin)
                    .foregroundColor(myTabFontColor)
                Spacer()
                Text("\((myLease.fees?.totalCustomerPaidFees() ?? 0.0).toCurrency(false))")
                    .font(myTabResultsFont)
                    .padding(.trailing, myTabMargin)
                    .foregroundColor(myTabFontColor)
            }
            HStack{
                Text("Rent:")
                    .font(myTabLabelFont)
                    .padding(.leading, myTabMargin)
                    .foregroundColor(myTabFontColor)
                Spacer()
                Text("\(myLease.getTotalRents().toCurrency(false))")
                    .font(myTabResultsFont)
                    .padding(.trailing, myTabMargin)
                    .foregroundColor(myTabFontColor)
            }
            HStack{
                Text("Residual:")
                    .font(myTabLabelFont)
                    .padding(.leading, myTabMargin)
                    .foregroundColor(myTabFontColor)
                Spacer()
                Text("\(myLease.getTotalResidual().toCurrency(false))")
                    .font(myTabResultsFont)
                    .padding(.trailing, myTabMargin)
                    .foregroundColor(myTabFontColor)
            }
            
            HStack{
                Text ("Total In:")
                    .font(myTabLabelFont)
                    .padding(.leading, 50)
                    .foregroundColor(myTabFontColor)
                Spacer()
                Text("\(totalCashIn.toCurrency(false))")
                    .font(myTabResultsFont)
                    .padding(.trailing, myTabMargin)
                    .foregroundColor(myTabFontColor)
            }
            Divider()
                .frame(width: 200, height: 1)
                .overlay(myTabFontColor)
           
        }
    }
    var totalNetCashItem: some View {
        HStack{
            Text ("Total Net:")
                .font(myTabLabelFont)
                .padding(.leading, 50)
                .foregroundColor(myTabFontColor)
            Spacer()
            Text("\(totalNetCash.toCurrency(false))")
                .font(myTabResultsFont)
                .padding(.trailing, myTabMargin)
                .foregroundColor(myTabFontColor)
        }
    }
}
    


struct CashflowSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        LeaseCashflowView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
    }
}

extension LeaseCashflowView {
    func setPrivateVars() {
        self.totalCashIn = myLease.getTotalRents() + myLease.getTotalResidual() + myLease.fees!.totalFeesReceived()
        self.totalCashOut = myLease.amount.toDecimal() + myLease.fees!.totalFeesPaid()
        self.totalNetCash = self.totalCashIn - self.totalCashOut
    }
}
