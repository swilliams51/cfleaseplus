//
//  Amortizations.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

import Foundation

class Amortizations: ObservableObject {
    var items : [Amortization]
    
    init () {
        items = [Amortization]()
    }
    
    func getTotalDays () -> Int {
        var runTotal: Int = 0
        
        for x in 0..<items.count {
            let days = items[x].days
            runTotal = runTotal +  days
        }
        return runTotal
    }
    
    func getTotalInterest () -> Decimal {
        var runTotal: Decimal = 0.00
        
        for x in 0..<items.count {
            let interest  = items[x].interest
            runTotal = runTotal +  interest
        }
        return runTotal
    }
    
    func getTotalPayments () -> Decimal {
        var runTotal: Decimal = 0.00
        
        for x in 0..<items.count {
            let payment  = items[x].payment
            runTotal = runTotal +  payment
        }
        return runTotal
    }
    
    func getTotalPrincipal () -> Decimal {
        var runTotal: Decimal = 0.00
        
        for x in 0..<items.count {
            let principal  = items[x].principal
            runTotal = runTotal +  principal
        }
        return runTotal
    }
    
    func lookUpBalance(askDate: Date)-> Decimal {
        var decEndBalance:Decimal = 0.00
        
        for x in 0..<items.count{
            if items[x].dueDate == askDate {
                if items[x].timing == .advance {
                    let rentDue: Decimal = lookUpPayment(askDate: askDate)
                    decEndBalance = items[x].endBalance + rentDue
                } else {
                    decEndBalance = items[x].endBalance
                }
                break
            }
        }
        
        return decEndBalance
    }
    
    func lookUpPayment(askDate: Date) -> Decimal {
        var decPayment:Decimal = 0.00
        
        for x in 0..<items.count{
            if items[x].dueDate == askDate {
                decPayment = items[x].payment
            break
            }
        }
        
        return decPayment
    }
    
    func lookUpInterest(askDate: Date) -> Decimal {
        var decInterest: Decimal = 0.00
        
        for x in 0..<items.count {
            if items[x].dueDate == askDate {
                if x == items.count - 1 {
                    break
                } else {
                    decInterest = items[x + 1].interest
                    break
                }
            } else if items[x].dueDate > askDate {
                decInterest = items[x].interest
                break
            }
                        
        }
        
        return decInterest
    }
    
    func lookUpDaysInPeriod(askDate: Date) -> Int {
        var days: Int = 0
        
        for x in 0..<items.count {
            if items[x].dueDate == askDate {
                if x == items.count - 1 {
                    break
                } else {
                    days = items[x + 1].days
                    break
                }
            } else if items[x].dueDate > askDate {
                days = items[x].days
                break
            }
        }
        
        return days
    }
}

struct Amortization {
    let annualRate: Decimal
    let beginBalance: Decimal
    let dueDate: Date
    let days: Int
    let daysInYear: Decimal
    let dailyRate: Decimal
    let endBalance: Decimal
    let funding: Decimal
    let interest: Decimal
    let payment: Decimal
    let principal: Decimal
    let timing: PaymentTiming
    let type: PaymentType
    
    init(aAnnualRate: Decimal, aBeginBalance: Decimal, aDueDate: Date, aDays: Int, aDaysInYear: Decimal, aDailyRate: Decimal, aEndBalance: Decimal, aInterest: Decimal, aFunding: Decimal, aPayment: Decimal, aPrincipal: Decimal, aTiming: PaymentTiming, aType: PaymentType) {
        annualRate = aAnnualRate
        beginBalance = aBeginBalance
        dueDate = aDueDate
        days = aDays
        daysInYear = aDaysInYear
        dailyRate = aDailyRate
        endBalance = aEndBalance
        funding = aFunding
        interest = aInterest
        payment = aPayment
        principal = aPrincipal
        timing = aTiming
        type = aType
    }
    
    
}
