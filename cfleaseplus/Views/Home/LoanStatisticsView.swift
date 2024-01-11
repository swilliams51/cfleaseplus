//
//  LoanStatisticsView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 8/11/23.
//

import SwiftUI

struct LoanStatisticsView: View {
    @ObservedObject var myLease: Lease
    
    @State private var isTrueLease:  Bool = true
    @State private var fundingDate: Date = today()
    @State private var maturityDate: Date = today()
    @State private var baseTerm: Int = 60
    @State private var averageLife: Decimal = 3.24
    @State private var pvMinRents: Decimal = 0.8995
   
    var body: some View {
        VStack{
            TitleItem
            IsTrueLeaseRow
            FundingDateItem
            MaturityDateItem
            BaseTermItem
            AverageLifeItem
            PVMinRentsItem
            Spacer()
        }
        .padding(.horizontal, 18)
        .overlay (
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("AccentColor"), lineWidth: 4)
        )
        .padding(.horizontal, 25)
        .onAppear{
            self.isTrueLease = myLease.isTrueLease()
            self.fundingDate = myLease.fundingDate
            self.maturityDate = myLease.getMaturityDate()
            self.baseTerm = myLease.getBaseTermInMons()
            self.averageLife = myLease.averageLife()
            self.pvMinRents = (myLease.getPVOfRents(discountRate: myLease.implicitRate()) / myLease.amount.toDecimal())
        }
        
    }
    
    var TitleItem: some View {
        VStack {
            Text("STATISTICS")
                .padding(.top, myTabTopMargin)
                .padding(.bottom, myTabBottomMargin)
                .foregroundColor(myTabFontColor)
            .font(myTabResultsFont)
        }
    }
    var IsTrueLeaseRow: some View {
        HStack {
            Text("Is True Lease:")
                .padding(.leading, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabLabelFont)
            Spacer()
            Text("\(myLease.isTrueLease().toString())")
                .padding(.trailing, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabResultsFont)
        }
    }
    
    var FundingDateItem: some View {
        HStack {
            Text("Funding Date:")
                .padding(.leading, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabLabelFont)
            Spacer()
            Text("\(fundingDate.toStringDateShort(yrDigits: 4))")
                .padding(.trailing, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabResultsFont)
        }
    }
    
    var MaturityDateItem: some View {
        HStack {
            Text("Maturity Date:")
                .padding(.leading, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabLabelFont)
            Spacer()
            Text("\(maturityDate.toStringDateShort(yrDigits: 4))")
                .padding(.trailing, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabResultsFont)
        }
    }
    
    var BaseTermItem: some View {
        HStack {
            Text("Base Term (in mons):")
                .padding(.leading, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabLabelFont)
            Spacer()
            Text("\(baseTerm)")
                .padding(.trailing, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabResultsFont)
        }
    }
    
    var AverageLifeItem: some View {
        HStack {
            Text("Average Life (in yrs):")
                .padding(.leading, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabLabelFont)
            Spacer()
            Text("\(averageLife.toString())")
                .padding(.trailing, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabResultsFont)
        }
    }
    
    var PVMinRentsItem: some View {
        HStack {
            Text("PV of Min Rents:")
                .padding(.leading, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabLabelFont)
            Spacer()
            Text("\(pvMinRents.toPercent(2))")
                .padding(.trailing, myTabMargin)
                .foregroundColor(myTabFontColor)
                .font(myTabResultsFont)
        }
    }
    
    
}

struct LoanStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        LoanStatisticsView(myLease: Lease(aDate: today(), mode: .lending))
    }
}
