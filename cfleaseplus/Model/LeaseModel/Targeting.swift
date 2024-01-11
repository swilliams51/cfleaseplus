//
//  Targeting.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

extension Lease {
    func solveForPrincipal() {
        let myLease = self.clone()
        let decAmount1: Decimal = myLease.amount.toDecimal()
        let decBalance1: Decimal = myLease.getEndingBalance()
        let decAmount2: Decimal = decAmount1 * 1.50
        myLease.amount = decAmount2.toString(decPlaces: 8)
        let decBalance2 = myLease.getEndingBalance()

        let mxb: Decimal = mxbFactor(factor1: decAmount1, value1: decBalance1, factor2: decAmount2, value2: decBalance2)
        amount = mxb.toString(decPlaces: 6)
    }
}

extension Lease {

    func solveForUnlockedPayments3() {
        let myLease: Lease = self.clone()
        var x1: Decimal = 1.0
        var y1: Decimal = myLease.getEndingBalance()

        let myResult = result(aLease: myLease, x1: x1, y1: y1)
        x1 = myResult.x2
        y1 = myResult.y2

        for x in 0..<groups.items.count{
            if groups.items[x].locked == false {
                if groups.items[x].isCalculatedPaymentType() == false {
                    let adjustedAmount: Decimal = groups.items[x].amount.toDecimal() * x1
                    groups.items[x].amount = adjustedAmount.toString(decPlaces: 8)
                }
            }
        }
    }

    func result(aLease: Lease, x1: Decimal, y1: Decimal) -> (x2: Decimal, y2: Decimal) {
        let tempLease: Lease = aLease.clone()
        var y2 = y1
        var x2 = x1
        let adjFactor:Decimal = 0.33

        if y1 < 0.0 {
                x2 = x2 - (x2 * adjFactor)
                y2 = getBalanceAfterNewFactor(aLease: tempLease, aFactor: x2)
        } else {
                x2 = x2 + (x2 * adjFactor)
                y2 = getBalanceAfterNewFactor(aLease: tempLease, aFactor: x2)
        }

        let newX: Decimal = mxbFactor(factor1: x1, value1: y1, factor2: x2, value2: y2)
        let newY:Decimal = getBalanceAfterNewFactor(aLease: tempLease, aFactor: newX)

        return (newX, newY)
    }

    func getBalanceAfterNewFactor (aLease: Lease, aFactor: Decimal) -> Decimal {
        let tempLease: Lease = aLease.clone()

        for x in 0..<tempLease.groups.items.count {
            if tempLease.groups.items[x].locked == false {
                if tempLease.groups.items[x].isCalculatedPaymentType() == false {
                    let adjustedAmount: Decimal = tempLease.groups.items[x].amount.toDecimal() * aFactor
                    tempLease.groups.items[x].amount = adjustedAmount.toString(decPlaces: 10)
                }
            }
        }

        return tempLease.getEndingBalance()
    }
}

extension Lease {
    func solveForRate3() {
        let myLease = self.clone()
        let myLeaseCF: Cashflows = Cashflows(aLease: myLease)
        let decRate: Decimal = myLeaseCF.XIRR2(guessRate: 0.15, _DayCountMethod: myLease.interestCalcMethod)
        interestRate = decRate.toString(decPlaces: 10)
    }
}


extension Lease {
    func solveForTerm(maxBase: Int) {
        let idx: Int = groups.getIndexOfUnlocked()
        let decBalance: Decimal = self.getEndingBalance()

        if decBalance > 0.0 {
            solveForIncreasingTerm(grpNo: idx, maxBase: maxBase, endingBalance: decBalance)
        } else {
            solveForDecreasingTerm(grpNo: idx, maxBase: maxBase, endingBalance: decBalance)
        }
        groups.unlockAllGroups()
    }

    func solveForIncreasingTerm(grpNo: Int, maxBase: Int, endingBalance: Decimal) {
        var maxTermExceeded: Bool = false
        let maxNumber: Int = self.getMaxRemainNumberPayments(maxBaseTerm: maxBase, freq: self.paymentsPerYear, eom: self.endOfMonthRule, aRefer: self.firstAnniversaryDate)
        var intNumber: Int = 0
        let startNoOfPayments = self.groups.items[grpNo].noOfPayments
        var newNoOfPayments: Int = startNoOfPayments

        intNumber = (abs(endingBalance) / self.groups.items[grpNo].amount.toDecimal()).toInteger() + startNoOfPayments
        groups.items[grpNo].noOfPayments = intNumber

        while intNumber < maxNumber {
            let decBalance: Decimal = self.getEndingBalance()
            if decBalance < 0.0 {
                break
            }

            intNumber += 1
            newNoOfPayments = intNumber
            self.groups.items[grpNo].noOfPayments = newNoOfPayments
        }

        if intNumber >= maxNumber {
            maxTermExceeded = true
        } else {
            newNoOfPayments = newNoOfPayments - 1
        }

        if maxTermExceeded == false {
            self.groups.items[grpNo].noOfPayments = newNoOfPayments
            self.groups.items[grpNo].locked = true
            let endDate: Date = self.groups.items[grpNo].endDate
            self.groups.items[grpNo].endDate = subtractOnePeriodFromDate(dateStart: endDate, payperYear: self.paymentsPerYear, dateRefer: self.firstAnniversaryDate, bolEOMRule: self.endOfMonthRule)

            // add 1 new payment group, unlock the group and solve for unlocked payments
            let strAmount:String = self.groups.items[grpNo].amount
            let grpStart:Date = self.groups.items[grpNo].endDate
            let grpEnd:Date = addOnePeriodToDate(dateStart: self.groups.items[grpNo].endDate, payperYear: self.paymentsPerYear, dateRefer: self.firstAnniversaryDate, bolEOMRule: self.endOfMonthRule)
            let aTiming:PaymentTiming = groups.items[grpNo].timing
            let aType: PaymentType = groups.items[grpNo].type

            let myGroup = Group(aAmount: strAmount, aEndDate: grpEnd, aLocked: false, aNoOfPayments: 1, aStartDate: grpStart, aTiming: aTiming, aType: aType, aUndeletable: false, aIsInterim: false)

            self.groups.items.insert(myGroup, at: grpNo + 1)
            self.resetFirstGroup(isInterim: self.interimGroupExists())
            self.groups.items[grpNo].locked = true
            self.solveForUnlockedPayments3()
        } else {
            self.groups.items[grpNo].noOfPayments = -1
        }

    }

    func solveForDecreasingTerm(grpNo: Int, maxBase: Int, endingBalance: Decimal) {
        let minNumber = self.getMinTotalNumberPayments()
        let startNoOfPayments = self.groups.items[grpNo].noOfPayments
        let intNumber: Int = (abs(endingBalance) / self.groups.items[grpNo].amount.toDecimal()).toInteger()
        let newNoOfPayments = startNoOfPayments - intNumber

        if newNoOfPayments < minNumber {
            self.groups.items[grpNo].noOfPayments = -1
        } else {
            groups.items[grpNo].noOfPayments = newNoOfPayments
            let decBalance: Decimal = getEndingBalance()

            self.solveForIncreasingTerm(grpNo: grpNo, maxBase: maxBase, endingBalance: decBalance)
        }

    }

}
