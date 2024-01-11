//
//  YieldsSummaryView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/11/23.
//

import SwiftUI

struct LeaseYieldsView: View {
    @ObservedObject var myLease: Lease
    
    @State private var dayCountMethod: DayCountMethod = .Actual_ThreeSixty
    @State private var leaseInterestRate: Decimal = 0.05
    @State private var implicitRate: Decimal = 0.050
    @State private var eboInterestRate: String = "N/A"
    @State private var yieldAfterFees: Decimal = 0.0465
    @State private var indexRate: Decimal = 3.25
    @State private var spreadToIndex: Decimal = 1.75
    
    @Binding var margin: CGFloat
    
    var body: some View {
        VStack {
            titleItem
            dayCountMethodItem
            leaseInterestRateItem
            implicitRateItem
            eboInterestRateItem
            yieldItem
            Spacer()
        }
        .padding(.horizontal, 18)
        .overlay (
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("AccentColor"), lineWidth: 4)
        )
        .padding(.horizontal, 25)
        
    }
    
    var titleItem: some View {
        HStack{
            Text("YIELDS")
                .padding(.top, myTabTopMargin)
                .padding(.bottom, myTabBottomMargin)
                .foregroundColor(myTabFontColor)
        }
    }
    
    var dayCountMethodItem: some View{
        HStack {
            Text("Day Count:")
                .padding(.leading, margin)
                .font(myTabLabelFont)
                .foregroundColor(myTabFontColor)
            Spacer()
            Text("\(dayCountMethod.toString())")
                .padding(.trailing, margin)
                .font(myTabResultsFont)
                .foregroundColor(myTabFontColor)
        }
    }
    
    var leaseInterestRateItem: some View {
        HStack {
            Text("Interest Rate:")
                .padding(.leading, margin)
                .font(myTabLabelFont)
                .foregroundColor(myTabFontColor)
            Spacer()
            Text("\(leaseInterestRate.toString())")
                .padding(.trailing, margin)
                .font(myTabResultsFont)
                .foregroundColor(myTabFontColor)
        }
        
    }
    
    var implicitRateItem: some View {
        HStack {
            Text("Implicit Rate:")
                .padding(.leading, margin)
                .font(myTabLabelFont)
                .foregroundColor(myTabFontColor)
            Spacer()
            Text("\(implicitRate.toPercent(2))")
                .padding(.trailing, margin)
                .font(myTabResultsFont)
                .foregroundColor(myTabFontColor)
        }
    }
    
    var eboInterestRateItem: some View {
        HStack {
            Text("EBO Interest Rate:")
                .padding(.leading, margin)
                .font(myTabLabelFont)
                .foregroundColor(myTabFontColor)
            Spacer()
            Text("\(eboInterestRate)")
                .padding(.trailing, margin)
                .font(myTabResultsFont)
                .foregroundColor(myTabFontColor)
            
        }
    }
    
    var yieldItem: some View {
        HStack {
            Text("Yield:")
                .padding(.leading, margin)
                .foregroundColor(myTabFontColor)
                .font(myTabLabelFont)
            Spacer()
            Text("\(yieldAfterFees.toPercent(2))")
                .padding(.trailing, margin)
                .font(myTabResultsFont)
                .foregroundColor(myTabFontColor)
        }
    }
    
    
}


struct YieldsSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        LeaseYieldsView(myLease: Lease(aDate: today(), mode: .leasing), margin: .constant(20))
    }
}


extension LeaseYieldsView {
    func setPrivateVars() {
        self.dayCountMethod = myLease.interestCalcMethod
        self.leaseInterestRate = myLease.interestRate.toDecimal()
        self.eboInterestRate = "N/A"
        if myLease.eboExists() == true {
            self.eboInterestRate = myLease.eboYield(aLease: myLease, rentDueIsPaid: myLease.earlyBuyOut!.rentDueIsPaid, withLesseeFee: true).toPercent(2)
        }
       
        self.yieldAfterFees = myLease.getBuyRate(afterLesseeFee: true).toDecimal()
        
        
    }
}
