//
//  Group.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

struct Group: Identifiable {
    let id = UUID()
    var amount: String
    var endDate: Date
    var locked: Bool
    var noOfPayments: Int
    var startDate: Date
    var timing: PaymentTiming
    var type: PaymentType
    var undeletable: Bool
    var isInterim: Bool
    var payments = Payments()
    
    init(aAmount: String, aEndDate: Date, aLocked: Bool, aNoOfPayments: Int, aStartDate: Date, aTiming: PaymentTiming, aType: PaymentType, aUndeletable: Bool, aIsInterim: Bool) {
        amount = aAmount
        endDate = aEndDate
        locked = aLocked
        noOfPayments = aNoOfPayments
        startDate = aStartDate
        timing = aTiming
        type = aType
        undeletable = aUndeletable
        isInterim = aIsInterim
    }
    
    mutating func noOfMonthsInGroup() -> Int {
        var months: Int = 0
        
        if noOfPayments > 1 {
            months = monthsBetween(start: startDate, end: endDate)
        }
        
        return months
    }
    

    mutating func clone() -> Group {
        let stringGroup = writeGroup(aGroup: self)
        let clone: Group = readGroup(strGroup: stringGroup)
        return clone
    }
    
    mutating func isCalculatedPaymentType() -> Bool {
        var bolIsCalcPayment: Bool = false
        
        if type == .deAll || type == .deNext || type == .interest {
            bolIsCalcPayment = true
        }
        
        return bolIsCalcPayment
    }
    
    mutating func isDefaultPaymentType() -> Bool {
        var bolIsDefaultPaymentType: Bool = false
        
        if type == .interest || type == .payment || type == .principal {
            bolIsDefaultPaymentType = true
        }
        return bolIsDefaultPaymentType
    }
    
    mutating func isResidualPaymentType() -> Bool {
        var bolIsResidualPaymentType: Bool = false
        
        if type == .balloon || type == .residual {
            bolIsResidualPaymentType = true
        }
        return bolIsResidualPaymentType
    }
    
}
