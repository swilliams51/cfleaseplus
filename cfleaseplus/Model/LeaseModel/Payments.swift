//
//  Payments.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

class Payments {
    var items: [Payment]
 
    init() {
        items = []
    }
    
    func reset () {
        let range = (0..<items.count).reversed()
        for x in range {
            items.remove(at: x)
        }
    }
    func getPaymentsEndingFactor() -> Decimal {
        let indexOfLast = items.count - 1
        return items[indexOfLast].factor
    }
    
    func getTotalAmount() -> Decimal {
        var runTotal: Decimal = 0.0
        
        for x in 0..<items.count {
            runTotal = runTotal + items[x].amount
        }
        return runTotal
    }
    
    func getPaymentsTotalPV() -> Decimal {
        var decPV: Decimal = 0.0
        
        for x in 0..<items.count {
            decPV = decPV + items[x].pv
        }
        return decPV
    }
}

struct Payment {
    var amount: Decimal
    var dueDate: Date
    var factor: Decimal
    var pv: Decimal
    var timing: PaymentTiming
    var type: PaymentType
    
}
