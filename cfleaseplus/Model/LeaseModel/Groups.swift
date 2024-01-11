//
//  Groups.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation


class Groups {
    var items: [Group]

    init() {
        items = []
    }

    func deepClone() -> Groups {
        var deepClone:Groups = Groups()
        let strGroups: String = writeGroups(aGroups: self)
        let arryGroups: [String] = strGroups.components(separatedBy: "<")
        deepClone = readGroups(strGroups: arryGroups)

        return deepClone
    }

    func addBalloonGroup(leaseAmount: String) {
        let amount:Decimal = leaseAmount.toDecimal()
        let residual: Decimal = amount * 0.15
        let startDate:Date = items[items.count - 1].endDate
        let newGroup: Group = Group(
            aAmount: residual.toString(decPlaces: 2),
            aEndDate: startDate,
            aLocked: true,
            aNoOfPayments: 1,
            aStartDate: startDate,
            aTiming: .equals,
            aType: .balloon,
            aUndeletable: false,
            aIsInterim: false)
        items.append(newGroup)
    }

    func addResidualGroup(leaseAmount: String) {
        let amount:Decimal = leaseAmount.toDecimal()
        let residual: Decimal = amount * 0.15
        let startDate:Date = items[items.count - 1].endDate
        let newGroup: Group = Group(
            aAmount: residual.toString(decPlaces: 2),
            aEndDate: startDate,
            aLocked: true,
            aNoOfPayments: 1,
            aStartDate: startDate,
            aTiming: .equals,
            aType: .residual,
            aUndeletable: false,
            aIsInterim: false)
        items.append(newGroup)
    }

    func allGroupsAreLocked() -> Bool {
        var allAreLocked: Bool = true

        for x in 0..<items.count {
            if items[x].locked == false {
                allAreLocked = false
                break
            }
        }

        return allAreLocked
    }

    func addDuplicateGroup(groupToCopy: Group, numberPayments: Int) {
        let newCopy: String = writeGroup(aGroup: groupToCopy)
        var newGroup: Group = readGroup(strGroup: newCopy)
        newGroup.noOfPayments = numberPayments
        newGroup.undeletable = false

        items.append(newGroup)
    }

    func getAveragePayment () -> Decimal {
        var runTotalAmount: Decimal = 0.00
        var runTotalNumber: Decimal = 0.00

        for x in 0..<items.count {
            if items[x].type == .payment {
                let decAmount = items[x].amount.toDecimal()
                let decNumber = Decimal(items[x].noOfPayments)
                let totalAmount = decAmount * decNumber
                runTotalAmount = runTotalAmount + totalAmount
                runTotalNumber = runTotalNumber + decNumber
            }
        }
        let average: Decimal = safeDivision(aNumerator: runTotalAmount, aDenominator: runTotalNumber)

        return average
     }

    func getTotalResidual() -> Decimal {
        var totalResidual: Decimal = 0.0

        for x in 0..<items.count {
            if items[x].type == PaymentType.residual {
                totalResidual = items[x].amount.toDecimal()
            }
        }
        return totalResidual
    }

    func getIndexOfUnlocked () -> Int {
        var idx: Int = -1

        for x in 0..<items.count {
            if items[x].locked == false {
                idx = x
            }
        }
        return idx
    }

    func getNumberOfUnlockedGroups() -> Int {
        var count: Int = 0

        for x in 0..<items.count {
            if items[x].locked == false {
                count = count + 1
            }
        }
        return count
    }


    func getTotalNoOfPayments() -> Int {
        var runTotalNoOfPmts: Int = 0

        for x in 0..<items.count {
            runTotalNoOfPmts = runTotalNoOfPmts + items[x].noOfPayments
        }

        return runTotalNoOfPmts
    }

    func getTotalNoOfBasePayments(aFreq: Frequency, eomRule: Bool, aRefer: Date, interimGroupExists: Bool) -> Int {
        var runTotalNoOfPmts: Int = 0

        for x in 0..<items.count {
            if x == 0 {
                if interimGroupExists == true && items[x].noOfPayments == 1{
                    continue
                }
            }
            if x == items.count - 1 {
                let isResidual: Bool = items[x].isResidualPaymentType()
                if isResidual == true {
                    continue
                }
            }
            runTotalNoOfPmts = runTotalNoOfPmts + items[x].noOfPayments
        }

        return runTotalNoOfPmts
    }


    func getTotalOfRents() -> Decimal {
        var runTotalRents: Decimal = 0.0

        for x in 0..<items.count {
            if items[x].type != PaymentType.residual {
                let totalOfGroup = items[x].payments.getTotalAmount()
                runTotalRents = runTotalRents + totalOfGroup
            }
        }

        return runTotalRents
    }

    func getTotalOfPrincipalPayments() -> Decimal {
        var runTotal: Decimal = 0.00

        for x in 0..<items.count {
            if items[x].type == .principal {
                let i: Int = items[x].noOfPayments
                let j: Decimal = items[x].amount.toDecimal()
                let groupTotal: Decimal = i.toString().toDecimal() * j
                runTotal = runTotal + groupTotal
            }
        }

        return runTotal
    }

    func hasInValidGroup() -> Bool {
        var bolHasInvalidGroup: Bool = false

        for x in 0..<items.count {
            if items[x].noOfPayments == -1 {
                bolHasInvalidGroup = true
                break
            }
        }
        return bolHasInvalidGroup
    }

    func hasAllCalculatedPayments() -> Bool {
        var bolAllCalculatedPayments: Bool = true

        for x in 0..<items.count{
            if items[x].isCalculatedPaymentType() == false {
                bolAllCalculatedPayments = false
                break
            }
        }

        return bolAllCalculatedPayments
    }

    func hasAllPrincipalPayments() -> Bool {
        var bolAllPrincipalPayments: Bool = true

        for x in 0..<items.count {
            if items[x].noOfPayments > 1 {
                if items[x].type == .payment {
                    bolAllPrincipalPayments = false
                    break
                }
            }
        }

        return bolAllPrincipalPayments
    }

    func hasPrincipalPayments() -> Bool {
        var bolPrincipalPayments: Bool = false

        for x in 0..<items.count {
            if items[x].type == .principal {
                bolPrincipalPayments = true
                break
            }
        }

        return bolPrincipalPayments
    }

    func hasNegativePayments() -> Bool {
        for x in 0..<items.count {
            if items[x].amount.toDecimal() < 0.0 {
                return true
            }
        }

        return false
    }

    func indexOfGroupWithMoreThanOnePayment() -> Int {
        var idx: Int = -1

        for x in 0..<items.count {
            if items[x].noOfPayments > 1 && items[x].isDefaultPaymentType() {
                idx = x
            }
        }

        return idx
    }

    func areAdvArrSwitchesValid() -> Bool {
        var switchesAreValid: Bool = true

        if noOfGroupsWithMoreThanOnePayment() == 1 {
            return switchesAreValid
        }

        var intTiming1: Int = 0
        for x in 0..<items.count {
            if items[x].noOfPayments > 1 {
                if items[x].timing == .arrears {
                    intTiming1 = 1
                }
            }
        }

        for x in 0..<items.count {
            if items[x].noOfPayments > 1 {
                var intTiming2 = 0
                if items[x].timing == .arrears {
                    intTiming2 = 1
                }
                if intTiming2 != intTiming1 {
                    switchesAreValid = false
                    break
                }
            }
        }

        return switchesAreValid
    }

    func lockAllGroups () {
        for x in 0..<items.count {
            items[x].locked = true
        }
    }

    func noOfGroupsWithMoreThanOnePayment() -> Int {
        var counter: Int = 0

        for x in 0..<items.count {
            if items[x].noOfPayments > 1 {
                counter += 1
            }
        }
        return counter
    }

    func noOfDefaultPaymentGroups() -> Int {
        var counter: Int = 0

        for x in 0..<items.count {
            if items[x].isDefaultPaymentType() {
                counter += 1
            }
        }
        return counter
    }

    func unlockAllGroups () {
        for x in 0..<items.count {
            items[x].locked = false
        }
    }

    func residualGroupExists() -> Bool {
        var bolResidualExists: Bool = false

        for x in 0..<items.count {
            if items[x].type == PaymentType.residual || items[x].type == PaymentType.balloon {
                bolResidualExists = true
                break
            }
        }
        return bolResidualExists
    }

}
