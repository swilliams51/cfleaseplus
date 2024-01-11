//
//  Classes.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

struct EarlyPurchaseOption {
    var exerciseDate: Date
    var amount: String
    var rentDueIsPaid: Bool
    
    
    init(aExerciseDate: Date, aAmount: String, rentDue: Bool) {
        exerciseDate = aExerciseDate
        amount = aAmount
        rentDueIsPaid = rentDue
    }
    
    init(aLease: Lease) {
        exerciseDate = aLease.getMaturityDate()
        amount = "0.00"
        rentDueIsPaid = true
    }
    
}

struct Obligations {
    var discountRate: String
    var residualGuarantyAmount: String
    
    init(aDiscountRate: String, aResidualGuarantyAmount: String) {
        discountRate = aDiscountRate
        residualGuarantyAmount = aResidualGuarantyAmount
    }
}

struct Terminations  {
    var discountRate_Rent: Decimal
    var discountRate_Residual: Decimal
    var additionalResidual: Decimal
    
}
