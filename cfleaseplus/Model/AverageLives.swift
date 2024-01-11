//
//  AverageLives.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

class AverageLives {
    var items: [AverageLife]
    
    init(aLease: Lease) {
        items = [AverageLife]()
        
        aLease.setAmortizationsFromCashflow(consolidate: false)
        let aDayCount: DayCountMethod = aLease.interestCalcMethod
        let decAmount: Decimal = aLease.amount.toDecimal()
        var cumDays: Int = 0
        for x in 0..<aLease.amortizations.items.count {
            let date: Date = aLease.amortizations.items[x].dueDate
            var days: Int = 0
            if x > 0 {
                days = dayCount(aDate1: aLease.amortizations.items[x - 1].dueDate, aDate2: aLease.amortizations.items[x].dueDate, aDaycount: aDayCount)
            }
            cumDays = cumDays + days
            var daysInYr: Decimal = 0.0
            if x > 0 {
                daysInYr = Decimal(daysInYear(aDate1: aLease.amortizations.items[x - 1].dueDate, aDate2: aLease.amortizations.items[x].dueDate, aDayCountMethod: aDayCount))
            }
            let yearsOut: Decimal = safeDivision(aNumerator: Decimal(cumDays), aDenominator: daysInYr)
            let princPaid: Decimal = safeDivision(aNumerator: aLease.amortizations.items[x].principal, aDenominator: decAmount)
            let princOut: Decimal = yearsOut * princPaid
            let myAverageLife = AverageLife(
                dueDate: date,
                dayCount: days,
                cumulativeDays: cumDays,
                daysInYear: daysInYr,
                yearsOutstanding: yearsOut,
                principalPaid: princPaid,
                principalOutstanding: princOut)
            items.append(myAverageLife)
        }
        aLease.amortizations.items.removeAll()
    }
    
    func getWeightedAverageLife () -> Decimal {
        var runTotal:Decimal = 0.0
        
        for x in 0..<items.count {
            runTotal = runTotal + items[x].principalOutstanding
        }
        
        return runTotal
    }
    
    func getTotalPrincipalPaid() -> Decimal {
        var runTotal:Decimal = 0.0
        
        for x in 0..<items.count {
            runTotal = runTotal + items[x].principalPaid
        }
        
        return runTotal
    }
}

struct AverageLife {
    let dueDate: Date
    let dayCount: Int
    let cumulativeDays: Int
    let daysInYear: Decimal
    let yearsOutstanding: Decimal
    let principalPaid: Decimal
    let principalOutstanding: Decimal
    
    
    
}
