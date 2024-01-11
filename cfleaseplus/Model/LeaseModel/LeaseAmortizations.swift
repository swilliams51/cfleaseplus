//
//  LeaseAmortizations.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation
import SwiftUI


extension Lease {
    
    func setAmortizationsFromLease() {
        createPayments()
        let annualRate: Decimal = interestRate.toDecimal()
        let fundingAmount: Decimal = amount.toDecimal()
        let dateFunding: Date = fundingDate
        var endBalance: Decimal = amount.toDecimal()
        let dateFirst: Date = baseTermCommenceDate
        let dayCountMethod: DayCountMethod = interestCalcMethod
        var intDaysInYear: Double = daysInYear(aDate1: dateFunding, aDate2: dateFirst, aDayCountMethod: dayCountMethod)
        var decDailyRate: Decimal = annualRate / Decimal(intDaysInYear)
        
        var myAmort = Amortization(aAnnualRate: annualRate, aBeginBalance: 0.0, aDueDate: dateFunding, aDays: 0, aDaysInYear: Decimal(intDaysInYear), aDailyRate: decDailyRate, aEndBalance: fundingAmount, aInterest: 0.0, aFunding: fundingAmount, aPayment: 0.0, aPrincipal: 0.0, aTiming: .equals, aType: .funding)
        amortizations.items.append(myAmort)
    
        var prevDate = amortizations.items[0].dueDate
        for z in 0..<groups.items.count {
            for y in 0..<groups.items[z].payments.items.count {
                let currDate: Date = groups.items[z].payments.items[y].dueDate
                let lngDays: Int = dayCount(aDate1: prevDate, aDate2: currDate, aDaycount: dayCountMethod)
                let begBalance: Decimal = endBalance
                intDaysInYear = daysInYear(aDate1: prevDate, aDate2: currDate, aDayCountMethod: dayCountMethod)
                decDailyRate = annualRate / Decimal(intDaysInYear)
                let decInterest: Decimal = begBalance * decDailyRate * Decimal(lngDays)
                let type: PaymentType = groups.items[z].payments.items[y].type
                let timing: PaymentTiming = groups.items[z].payments.items[y].timing
                let decAmount: Decimal = groups.items[z].payments.items[y].amount
                var decFunding: Decimal = 0.0
                var decPayment: Decimal = 0.0
                var decPrincipal: Decimal = 0.0
                if type == .funding {
                    decFunding = decAmount * -1.0
                } else {
                    decPayment = decAmount
                    decPrincipal = decPayment - decInterest
                }
                endBalance = begBalance - decPrincipal + decFunding
                myAmort = Amortization(aAnnualRate: annualRate, aBeginBalance: begBalance, aDueDate: currDate, aDays: lngDays, aDaysInYear: Decimal(intDaysInYear), aDailyRate: decDailyRate, aEndBalance: endBalance, aInterest: decInterest, aFunding: decFunding, aPayment: decPayment, aPrincipal: decPrincipal, aTiming: timing , aType: type)
                amortizations.items.append(myAmort)
                prevDate = currDate
            }
        }
        resetPayments()
    }
    
    func setAmortizationsFromCashflow(consolidate: Bool) {
        let aCashflows: Cashflows = Cashflows(aLease: self)
        if consolidate {
            aCashflows.consolidateCashflows()
        }
        
        let decAnnualRate: Decimal = interestRate.toDecimal()
        var currDate: Date = aCashflows.items[0].dueDate
        var endBalance: Decimal = aCashflows.items[0].amount * -1.0
        
        var myAmort: Amortization = Amortization(aAnnualRate: decAnnualRate, aBeginBalance: 0.0, aDueDate: currDate, aDays: 0, aDaysInYear: 0.0, aDailyRate: 0.0, aEndBalance: endBalance, aInterest: 0.0, aFunding: endBalance, aPayment: 0.0, aPrincipal: 0.0, aTiming: .arrears, aType: .funding)
        amortizations.items.append(myAmort)
        
        var prevDate: Date = currDate
        for x in 1..<aCashflows.items.count {
            currDate = aCashflows.items[x].dueDate
            let lngDays = dayCount(aDate1: prevDate, aDate2: currDate, aDaycount: interestCalcMethod)
            let dblDaysInYear = daysInYear(aDate1: prevDate, aDate2: currDate, aDayCountMethod: interestCalcMethod)
            let decDailyRate = decAnnualRate / Decimal(dblDaysInYear)
            let decBeginBalance = endBalance
            
            let decInterest = decBeginBalance * decDailyRate * Decimal(lngDays)
            var decFunding: Decimal = 0.0
            var decPayment: Decimal = 0.0
            if aCashflows.items[x].amount < 0.0 {
                decFunding = aCashflows.items[x].amount * -1.0
            } else {
                decPayment = aCashflows.items[x].amount
            }
            let decPrincipal: Decimal = decPayment - decInterest
            endBalance = decBeginBalance - decPrincipal + decFunding
            myAmort = Amortization(aAnnualRate: decAnnualRate, aBeginBalance: decBeginBalance, aDueDate: currDate, aDays: lngDays, aDaysInYear: Decimal(dblDaysInYear), aDailyRate: decDailyRate, aEndBalance: endBalance, aInterest: decInterest, aFunding: decFunding, aPayment: decPayment, aPrincipal: decPrincipal, aTiming: .arrears, aType: .payment)
            amortizations.items.append(myAmort)
            prevDate = currDate
        }
    }
    
}

func getAmortizationsFromCashflow(aCashflows: Cashflows, decAnnualRate: Decimal, aDayCount: DayCountMethod) -> Amortizations {
    let myAmortizations: Amortizations = Amortizations()
    
    var currDate: Date = aCashflows.items[0].dueDate
    var endBalance: Decimal = aCashflows.items[0].amount * -1.0
    
    var myAmort: Amortization = Amortization(aAnnualRate: decAnnualRate, aBeginBalance: 0.0, aDueDate: currDate, aDays: 0, aDaysInYear: 0.0, aDailyRate: 0.0, aEndBalance: endBalance, aInterest: 0.0, aFunding: endBalance, aPayment: 0.0, aPrincipal: 0.0, aTiming: .arrears, aType: .funding)
    myAmortizations.items.append(myAmort)
    
    var prevDate: Date = currDate
    for x in 1..<aCashflows.items.count {
        currDate = aCashflows.items[x].dueDate
        let lngDays = dayCount(aDate1: prevDate, aDate2: currDate, aDaycount: aDayCount)
        let dblDaysInYear = daysInYear(aDate1: prevDate, aDate2: currDate, aDayCountMethod: aDayCount)
        let decDailyRate = decAnnualRate / Decimal(dblDaysInYear)
        let decBeginBalance = endBalance
        let decInterest = decBeginBalance * decDailyRate * Decimal(lngDays)
        let decFunding: Decimal = 0.0
        let decPayment: Decimal =  aCashflows.items[x].amount
        let decPrincipal: Decimal = decPayment - decInterest
        endBalance = decBeginBalance - decPrincipal + decFunding
        myAmort = Amortization(aAnnualRate: decAnnualRate, aBeginBalance: decBeginBalance, aDueDate: currDate, aDays: lngDays, aDaysInYear: Decimal(dblDaysInYear), aDailyRate: decDailyRate, aEndBalance: endBalance, aInterest: decInterest, aFunding: decFunding, aPayment: decPayment, aPrincipal: decPrincipal, aTiming: .arrears, aType: .payment)
        myAmortizations.items.append(myAmort)
        prevDate = currDate
    }
    
    return myAmortizations
}
