//
//  Fee.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/10/23.
//

import Foundation


class Fees {
    var items: [Fee]
    
    init() {
        items = []
    }
    
    func addNewFee() {
        let myNewFee: Fee = Fee.new
        items.append(myNewFee)
    }
    
    func removeFee(index: Int) {
        items.remove(at: index)
    }
    
    func totalFeesPaid () -> Decimal {
        var runTotal: Decimal = 0.0
        
        for x in 0..<items.count {
            if items[x].incomeType == .expense {
                runTotal = runTotal + items[x].amount.toDecimal()
            }
        }
        
        return runTotal
    }
    
    func totalFeesReceived () -> Decimal {
        var runTotal: Decimal = 0.0
        
        for x in 0..<items.count {
            if items[x].incomeType == .income {
                runTotal = runTotal + items[x].amount.toDecimal()
            }
        }
        
        return runTotal
    }
    
    func totalNetFees () -> Decimal {
        return totalFeesPaid() - totalFeesReceived()
    }
    
    func totalCustomerPaidFees () -> Decimal {
        var runTotal: Decimal = 0.0
        
        for x in 0..<items.count {
            if items[x].type == .customerPaid {
                runTotal = runTotal + items[x].amount.toDecimal()
            }
        }
        
        return runTotal
    }
    
    func totalPurchaseFees () -> Decimal {
        var runTotal: Decimal = 0.0
        
        for x in 0..<items.count {
            if items[x].type == .purchase {
                runTotal = runTotal + items[x].amount.toDecimal()
            }
        }
        
        return runTotal
    }
}



struct Fee: Identifiable {
    let id = UUID()
    var name: String
    var effectiveDate: Date
    var incomeType: FeeIncomeType
    var amount: String
    var type: FeeType
    var locked: Bool
    
    init(title: String, effectDate: Date, acctgType: FeeIncomeType, strAmount: String, feeType: FeeType, feeLocked: Bool) {
        name = title
        effectiveDate = effectDate
        incomeType = acctgType
        amount = strAmount
        type = feeType
        locked = feeLocked
    }
    
    static let new: Fee = Fee(
        title: "My Lessee Paid Fee",
        effectDate: today(),
        acctgType: .income,
        strAmount: "2000.0",
        feeType: .customerPaid,
        feeLocked: false)
}
