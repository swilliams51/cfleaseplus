//
//  ChangeFactors.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation
import SwiftUI

extension Lease {
    func paymentChangeFactors() -> [String] {
        // create temp clone
        let tempLease: Lease = self.clone()
        var arryBase: [Decimal] = [Decimal]()
        var arryIncrease: [Decimal] = [Decimal]()
        var arryDecrease: [Decimal] = [Decimal]()
        var changeFactors: [String] = [String]()
        
        tempLease.groups.lockAllGroups()
        for x in 0..<tempLease.groups.items.count {
            if tempLease.groups.items[x].type == .payment {
                tempLease.groups.items[x].locked = false
                let decBasePayment:Decimal = tempLease.groups.items[x].amount.toDecimal()
                arryBase.append(decBasePayment)
            } else {
                tempLease.groups.items[x].locked = true
            }
        }
        
        var changeRate: Decimal = interestRate.toDecimal() + 0.01
        tempLease.interestRate = changeRate.toString(decPlaces: 7)
        tempLease.solveForUnlockedPayments3()
        var y: Int = 0
        for x in 0..<tempLease.groups.items.count {
            if tempLease.groups.items[x].type == .payment {
                let newPayment: Decimal = tempLease.groups.items[x].amount.toDecimal()
                let perBPChange: Decimal = (newPayment - arryBase[y]) / 100.0
                arryIncrease.append(perBPChange)
                y += 1
            }
        }
            
        changeRate = interestRate.toDecimal() - 0.01
        tempLease.interestRate = changeRate.toString(decPlaces: 7)
        tempLease.solveForUnlockedPayments3()
        y = 0
        for x in 0..<tempLease.groups.items.count {
            if tempLease.groups.items[x].type == .payment {
                let newPayment: Decimal = tempLease.groups.items[x].amount.toDecimal()
                let perBPChange: Decimal = (arryBase[y] - newPayment) / 100.0
                arryDecrease.append(perBPChange)
                y += 1
            }
        }
        
        for x in 0..<arryIncrease.count {
            let avg: Decimal = (arryIncrease[x] + arryDecrease[x] ) / 2.0
            let avgFactor: Decimal = avg / arryBase[x]
            
            changeFactors.append(avgFactor.toString(decPlaces: 7))
        }
        
       return changeFactors
    }
    
    func eboChangeFactor() -> String {
        let baseSpread: Int = getEBOPremium(aLease: self, exerDate: self.earlyBuyOut!.exerciseDate, aEBOAmount: self.earlyBuyOut!.amount, rentDueIsPaid: self.earlyBuyOut!.rentDueIsPaid)
        let baseEBOAmount: Decimal = self.earlyBuyOut!.amount.toDecimal()
        let tempLease: Lease = self.deepClone()
        tempLease.groups.lockAllGroups()
        for x in 0..<tempLease.groups.items.count {
            if tempLease.groups.items[x].type == .payment {
                tempLease.groups.items[x].locked = false
            }
        }
        
        var changeRate: Decimal = interestRate.toDecimal() + 0.01
        tempLease.interestRate = changeRate.toString(decPlaces: 6)
        tempLease.solveForUnlockedPayments3()
        let newEBOAmount1: Decimal = tempLease.getEBOAmount(aLease: tempLease, bpsPremium: baseSpread, exerDate: tempLease.earlyBuyOut!.exerciseDate, rentDueIsPaid: tempLease.earlyBuyOut!.rentDueIsPaid).toDecimal()
        let highFactor = (newEBOAmount1 - baseEBOAmount) / 100.0
        
        changeRate = interestRate.toDecimal() - 0.01
        tempLease.interestRate = changeRate.toString(decPlaces: 6)
        tempLease.solveForUnlockedPayments3()
        let newEBOAmount2: Decimal = tempLease.getEBOAmount(aLease: tempLease, bpsPremium: baseSpread, exerDate: tempLease.earlyBuyOut!.exerciseDate, rentDueIsPaid: tempLease.earlyBuyOut!.rentDueIsPaid).toDecimal()
        let lowFactor: Decimal = (baseEBOAmount - newEBOAmount2) / 100.0
        let avgFactor: Decimal = (lowFactor + highFactor) / 2.0
        let avgFactorToBase: Decimal = avgFactor / baseEBOAmount
        
        
        return avgFactorToBase.toString(decPlaces: 6)
    }
    
}
