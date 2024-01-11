//
//  Modifications.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

func chopPayments (aSchedule: Groups, asOfDate: Date, returnBefore: Bool, inclusiveOfDate: Bool) -> Groups {
    var chopped: Groups = Groups()

    if returnBefore == true {
        chopped = getGroupsBeforeModDate(aSchedule: aSchedule, modDate: asOfDate, inclusiveOfDate: inclusiveOfDate)
    } else {
        chopped = getGroupsAfterModDate(aSchedule: aSchedule, modDate: asOfDate)
    }

    return chopped
}

func getGroupsBeforeModDate (aSchedule: Groups, modDate: Date, inclusiveOfDate: Bool) -> Groups {
    let tempGroups: Groups = Groups()

    for x in 0..<aSchedule.items.count {
        if aSchedule.items[x].timing == PaymentTiming.arrears {
            if inclusiveOfDate == true {
                if aSchedule.items[x].endDate <= modDate {
                    tempGroups.items.append(aSchedule.items[x])
                }
            } else {
                if aSchedule.items[x].endDate < modDate {
                    tempGroups.items.append(aSchedule.items[x])
                }
            }
        } else {
            if inclusiveOfDate == true {
                if aSchedule.items[x].startDate <= modDate {
                    tempGroups.items.append(aSchedule.items[x])
                }
            } else {
                if  aSchedule.items[x].startDate < modDate {
                    tempGroups.items.append(aSchedule.items[x])
                }
            }
        }
    }
    return tempGroups
}

func getGroupsAfterModDate(aSchedule: Groups, modDate: Date) -> Groups {
    let tempGroups: Groups = Groups()
    var interimAdded: Bool = false
    var y = 0
    
    while y < aSchedule.items.count {
        if aSchedule.items[y].timing == PaymentTiming.arrears || aSchedule.items[y].timing == PaymentTiming.equals {
            if aSchedule.items[y].endDate > modDate {
                if aSchedule.items[y].startDate < modDate {
                    aSchedule.items[y].startDate = modDate
                }
                tempGroups.items.append(aSchedule.items[y])
            }
        } else {
            if aSchedule.items[y].startDate >= modDate {
                if aSchedule.items[y].startDate == modDate {
                    let newGroup = Group(aAmount: "0.0", aEndDate: aSchedule.items[y].endDate, aLocked: true, aNoOfPayments: 1, aStartDate: modDate, aTiming: .advance, aType: .payment, aUndeletable: false, aIsInterim: true)
                    tempGroups.items.append(newGroup)
                    interimAdded = true
                } else {
                    if interimAdded == false {
                        let newGroup = Group(aAmount: "0.0", aEndDate: aSchedule.items[y].startDate, aLocked: true, aNoOfPayments: 1, aStartDate: modDate, aTiming: .advance, aType: .payment, aUndeletable: false, aIsInterim: false)
                        tempGroups.items.append(newGroup)
                        interimAdded = true
                    }
                    tempGroups.items.append(aSchedule.items[y])
                }
            }
        }
        y = y + 1
    }
    
    return tempGroups
}

func groupsToSchedule(aGroups: Groups, aPayPerYear: Frequency, aReferDate: Date, aEOM: Bool) -> Groups {
    let wrkGroups = aGroups.deepClone()
    let myGroups = Groups()

    for x in 0..<wrkGroups.items.count {
        if wrkGroups.items[x].noOfPayments == 1 {
            let myGroup = Group(aAmount: wrkGroups.items[x].amount, aEndDate: wrkGroups.items[x].endDate, aLocked: wrkGroups.items[x].locked, aNoOfPayments: 1, aStartDate: wrkGroups.items[x].startDate, aTiming: wrkGroups.items[x].timing, aType: wrkGroups.items[x].type, aUndeletable: wrkGroups.items[x].undeletable, aIsInterim: wrkGroups.items[x].isInterim)
            myGroups.items.append(myGroup)
        } else {
            let strAmount = wrkGroups.items[x].amount
            
            var currStart = wrkGroups.items[x].startDate
            let aType = wrkGroups.items[x].type
            let aTiming = wrkGroups.items[x].timing
            let aLocked = wrkGroups.items[x].locked
            let aUndeletable = wrkGroups.items[x].undeletable
            let aIsInterim = wrkGroups.items[x].isInterim
            var iCounter: Int = 1
            while iCounter <= wrkGroups.items[x].noOfPayments {
                let currEnd = addOnePeriodToDate(dateStart: currStart, payperYear: aPayPerYear, dateRefer: aReferDate, bolEOMRule: aEOM)
                let myGroup = Group(aAmount: strAmount, aEndDate: currEnd, aLocked: aLocked, aNoOfPayments: 1, aStartDate: currStart, aTiming: aTiming, aType: aType, aUndeletable: aUndeletable, aIsInterim: aIsInterim)
                myGroups.items.append(myGroup)
                currStart = currEnd
                iCounter = iCounter + 1
            }
        }
    }
    return myGroups
}

func paymentsToGroups(aGroups: Groups) -> Groups {
    let myNewGroups: Groups = Groups()
    
    for x in 0..<aGroups.items.count {
        for y in 0..<aGroups.items[x].payments.items.count{
            let newGroup =
            Group(aAmount: aGroups.items[x].payments.items[y].amount.toString(),
                  aEndDate: aGroups.items[x].endDate,
                  aLocked: true,
                  aNoOfPayments: 1,
                  aStartDate: aGroups.items[x].startDate,
                  aTiming: aGroups.items[x].payments.items[y].timing,
                  aType: .payment,
                  aUndeletable: true,
                  aIsInterim: aGroups.items[x].isInterim)
            myNewGroups.items.append(newGroup)
        }
    }
    
    return myNewGroups
}

func scheduleToGroups(aGroups: Groups, aPayPerYear: Frequency, aReferDate: Date, aEOM: Bool) -> Groups {
    let wrkGroups = aGroups.deepClone()
    let myGroups = Groups()
    var tempStartDate: Date = dateDefault()
    var lastGroupAdded: Bool = false


    var iCounter: Int = 1
    for x in 0..<wrkGroups.items.count {
        let amount: String = wrkGroups.items[x].amount
        let dateEnd: Date = wrkGroups.items[x].endDate
        let locked: Bool = wrkGroups.items[x].locked
        var noOfPayments: Int
        var dateStart: Date = wrkGroups.items[x].startDate
        let timing: PaymentTiming = wrkGroups.items[x].timing
        let type: PaymentType = wrkGroups.items[x].type
        let undeletable: Bool = wrkGroups.items[x].undeletable
        let isinterim: Bool = wrkGroups.items[x].isInterim

        if x == wrkGroups.items.count - 1  {
            if lastGroupAdded == true {
                noOfPayments = iCounter
                if iCounter > 1 {
                    dateStart = tempStartDate
                }
            } else {
                noOfPayments = 1
            }
            let myGroup = Group(
                aAmount: amount,
                aEndDate: dateEnd,
                aLocked: locked,
                aNoOfPayments: noOfPayments,
                aStartDate: dateStart,
                aTiming: timing,
                aType: type,
                aUndeletable: undeletable,
                aIsInterim: isinterim)
            myGroups.items.append(myGroup)
        } else {
            if areTwoPaymentsOfSameGroup(aGroups: wrkGroups, pmtNo1: x, pmtNo2: x + 1, aPayPerYear: aPayPerYear, referDate: aReferDate, aEOM: aEOM) == true {
                if iCounter == 1 {
                    tempStartDate = wrkGroups.items[x].startDate
                }
                if x == wrkGroups.items.count - 2 {
                    lastGroupAdded = true
                }
                iCounter = iCounter + 1
            } else {
                if iCounter > 1 {
                    dateStart = tempStartDate
                }
                noOfPayments = iCounter
                let myGroup = Group(
                    aAmount: amount,
                    aEndDate: dateEnd,
                    aLocked: locked,
                    aNoOfPayments: noOfPayments,
                    aStartDate: dateStart,
                    aTiming: timing,
                    aType: type,
                    aUndeletable: undeletable,
                    aIsInterim: isinterim)
                myGroups.items.append(myGroup)
                iCounter = 1
            }
        }
    }
    return myGroups
}

func areTwoPaymentsOfSameGroup(aGroups: Groups, pmtNo1: Int, pmtNo2: Int, aPayPerYear: Frequency, referDate: Date, aEOM: Bool)  -> Bool{
    if aGroups.items[pmtNo1].type != aGroups.items[pmtNo2].type {
        return false
    }

    if aGroups.items[pmtNo1].timing != aGroups.items[pmtNo2].timing {
        return false
    }

    if isDatePeriodic(compareDate: aGroups.items[pmtNo1].startDate, askDate: aGroups.items[pmtNo2].startDate, aFreq: aPayPerYear, endOfMonthRule: aEOM, referDate: referDate) == false {
        return false
    }
    if isDatePeriodic(compareDate: aGroups.items[pmtNo1].endDate, askDate: aGroups.items[pmtNo2].endDate, aFreq: aPayPerYear, endOfMonthRule: aEOM, referDate: referDate) == false {
        return false
    }

    if aGroups.items[pmtNo1].amount == "CALCULATED" {
        if aGroups.items[pmtNo2].amount != "CALCULATED" {
            return false
        }
    } else {
        let decAmount1 = aGroups.items[pmtNo1].amount.toDecimal()
        let decAmount2 = aGroups.items[pmtNo2].amount.toDecimal()
        if abs(decAmount1 - decAmount2) > toleranceAmounts {
            return false
        }
    }

    return true
}

func modifiedLease(aLease: Lease, modDate: Date) -> Lease {
    let tempLease = aLease.deepClone()
    tempLease.groups = groupsToSchedule(aGroups: tempLease.groups, aPayPerYear: tempLease.paymentsPerYear, aReferDate: tempLease.firstAnniversaryDate, aEOM: tempLease.endOfMonthRule)
    tempLease.createPayments()
    tempLease.groups = paymentsToGroups(aGroups: tempLease.groups)
    var tempGroupsBefore = chopPayments(aSchedule: tempLease.groups, asOfDate: modDate, returnBefore: true, inclusiveOfDate: true)
    let x: Int = tempGroupsBefore.items.count
    
    
    //Calculate payoff - outstanding balance + accrued interest
    let lastPaymentDateBeforeMod: Date = getLastPaymentDateBeforeMod(aLease: tempLease, modDate: modDate)
    let principal: Decimal = getPrincipalBalance(aLease: tempLease, askDate: modDate)
    let interest: Decimal = getAccruedInterest(aLease: tempLease, principalBalance: principal, startDate: lastPaymentDateBeforeMod, endDate: modDate)
    let prepaidAmount: Decimal = principal + interest
    
    //determine start and end date for the payoff group to be added
    var dateStart = aLease.fundingDate
    var dateEnd = modDate
    var intTiming: PaymentTiming = .arrears
    
    if x > 0 {
        dateStart = tempGroupsBefore.items[x - 1].startDate // arrs: 11/5, adv: 12/5
        dateEnd = modDate
        intTiming = tempGroupsBefore.items[x - 1].timing
        
        if intTiming == .advance{
            dateStart = modDate

        } else {
            dateStart = tempGroupsBefore.items[x - 1].endDate
        }
    } else {
        tempLease.baseTermCommenceDate = modDate
    }

    //Add payoff payment to Groups Before
    let myGroup: Group = Group(aAmount: prepaidAmount.toString(decPlaces: 5), aEndDate: dateEnd, aLocked: true, aNoOfPayments: 1, aStartDate: dateStart, aTiming: intTiming, aType: .payment, aUndeletable: true, aIsInterim: false)
    tempGroupsBefore.items.append(myGroup)
   
    tempGroupsBefore = scheduleToGroups(aGroups: tempGroupsBefore, aPayPerYear: tempLease.paymentsPerYear, aReferDate: tempLease.firstAnniversaryDate, aEOM: tempLease.endOfMonthRule)
    tempLease.groups = tempGroupsBefore
    
    return tempLease
}

func newLeaseAfterSale(aLease: Lease, modDate: Date) -> Lease {
    let tempLease = aLease.deepClone()
    tempLease.createPayments()
    for x in 0..<tempLease.groups.items.count {
        if tempLease.groups.items[x].amount == "CALCULATED" {
            tempLease.groups.items[x].amount = tempLease.groups.items[x].payments.items[0].amount.toString(decPlaces: 5)
            tempLease.groups.items[x].type = .payment
        }
    }
    let tempGroups: Groups = tempLease.groups.deepClone()
    
    tempLease.resetPayments()
    let tempSchedule: Groups = groupsToSchedule(aGroups: tempGroups, aPayPerYear: tempLease.paymentsPerYear, aReferDate: tempLease.firstAnniversaryDate, aEOM: tempLease.endOfMonthRule)
    let tempGroupsBefore = chopPayments(aSchedule: tempSchedule, asOfDate: modDate, returnBefore: true, inclusiveOfDate: true)
    var tempGroupsAfter = chopPayments(aSchedule: tempSchedule, asOfDate: modDate, returnBefore: false, inclusiveOfDate: false)
   
    var lastPaymentDateBefore = tempLease.fundingDate
    if tempGroupsBefore.items.count > 0 {
        lastPaymentDateBefore = tempGroupsBefore.items[tempGroupsBefore.items.count - 1].startDate
        if tempGroupsBefore.items[tempGroupsBefore.items.count - 1].timing == .arrears {
            lastPaymentDateBefore = tempGroupsBefore.items[tempGroupsBefore.items.count - 1].endDate
        }
    }
    
    var firstPaymentDateAfter: Date = tempGroupsAfter.items[0].endDate
    if tempGroupsAfter.items[0].timing == .arrears {
        firstPaymentDateAfter = tempGroupsAfter.items[1].startDate
    }

    let fundingAmount: Decimal = getFundingAmountForNewLease(aLease: tempLease, modDate: modDate, lastPaymentDateBefore: lastPaymentDateBefore, firstPaymentDateAfter: firstPaymentDateAfter)
    var baseStartDate: Date = firstPaymentDateAfter
    let isPeriodic: Bool = isDatePeriodic(compareDate: modDate, askDate: firstPaymentDateAfter, aFreq: tempLease.paymentsPerYear, endOfMonthRule: tempLease.endOfMonthRule, referDate: tempLease.firstAnniversaryDate)
    if isPeriodic == true {
        baseStartDate = modDate
    }
    let newTerm: Int = monthsBetween(start: baseStartDate, end: tempLease.getMaturityDate())
    
    let myNewLease: Lease = Lease(
        amt: fundingAmount.toString(),
        baseCommence: baseStartDate,
        term: newTerm,
        EOM: tempLease.endOfMonthRule,
        firstAnnual: tempLease.firstAnniversaryDate,
        funding: modDate,
        intCalcMethod: tempLease.interestCalcMethod,
        rate: tempLease.interestRate,
        payPerYear: tempLease.paymentsPerYear,
        mode: tempLease.operatingMode)
    
    tempGroupsAfter = scheduleToGroups(aGroups: tempGroupsAfter, aPayPerYear: myNewLease.paymentsPerYear, aReferDate: myNewLease.firstAnniversaryDate, aEOM: myNewLease.endOfMonthRule)
    
    for x in 0..<tempGroupsAfter.items.count {
        myNewLease.groups.items.append(tempGroupsAfter.items[x])
    }
    
    if myNewLease.groups.items[0].noOfPayments == 1 {
        let strAmount = myNewLease.groups.items[0].amount
        let type: PaymentType = myNewLease.groups.items[0].type
        let strFullPaymentAmount = getFullPeriodPayment(aLease: myNewLease, aPaymentType: type, strAmount: strAmount, lastPaymentDateBefore: lastPaymentDateBefore, firstPaymentDateAfter: firstPaymentDateAfter, principalBalance: getPrincipalBalance(aLease: tempLease, askDate: modDate))
        myNewLease.groups.items[0].amount = strFullPaymentAmount
        myNewLease.groups.items[0].isInterim = true
    }
    myNewLease.solveForRate3()
    
    myNewLease.leaseObligations = Obligations(aDiscountRate: tempLease.leaseObligations!.discountRate, aResidualGuarantyAmount: tempLease.leaseObligations!.residualGuarantyAmount)
    myNewLease.earlyBuyOut = getResetEBO(aLease: tempLease, modDate: modDate)
    myNewLease.terminations = Terminations(discountRate_Rent: tempLease.terminations!.discountRate_Rent, discountRate_Residual: tempLease.terminations!.discountRate_Residual, additionalResidual: tempLease.terminations!.additionalResidual)
   
    return myNewLease
}

func modOccursOnPaymentDate(aLease: Lease, modDate: Date) -> Bool {
    var modOccursOnDate: Bool = false
    let tempCashflows: Cashflows = Cashflows(aLease: aLease, returnType: .payment)
    
    for x in 0..<tempCashflows.items.count - 1{
        if modDate == tempCashflows.items[x].dueDate {
            modOccursOnDate = true
            break
        }
    }
    
    return modOccursOnDate
}

func getFundingAmountForNewLease(aLease: Lease, modDate: Date, lastPaymentDateBefore: Date, firstPaymentDateAfter: Date) -> Decimal {
    let principalBalance = getPrincipalBalance(aLease: aLease, askDate: modDate)
    let accruedInterest = getAccruedInterest(aLease: aLease, principalBalance: principalBalance, startDate: lastPaymentDateBefore, endDate: modDate)
    let outstandingBalance = principalBalance + accruedInterest
    var capInterest: Decimal = 0.00
    if modOccursOnPaymentDate(aLease: aLease, modDate: modDate) == false {
        capInterest = getCapitalizedInterest(aAccruedInterest: accruedInterest, aInterestRate: aLease.interestRate.toDecimal(), aDayCountMethod: aLease.interestCalcMethod, aEOM: aLease.endOfMonthRule, dateOfMod: modDate, dateFirstPayment: firstPaymentDateAfter)
    }
    
    return outstandingBalance - capInterest
    
}

func getFullPeriodPayment(aLease: Lease, aPaymentType: PaymentType, strAmount: String, lastPaymentDateBefore: Date, firstPaymentDateAfter: Date, principalBalance: Decimal) -> String {
    var decFullPeriodPayment: Decimal = 0.00
    let decDaysInYear = daysInYear(aDate1: lastPaymentDateBefore, aDate2: firstPaymentDateAfter, aDayCountMethod: aLease.interestCalcMethod)
    let decDailyRate = safeDivision(aNumerator: aLease.interestRate.toDecimal(), aDenominator: Decimal(decDaysInYear))
    let noOfDays: Int = dayCount(aDate1: lastPaymentDateBefore, aDate2: firstPaymentDateAfter, aDaycount: aLease.interestCalcMethod)
    
    switch aPaymentType {
    case .deAll:
        let daysInTerm: Int = dayCount(aDate1: aLease.setFirstAnniversaryDate(), aDate2: aLease.getMaturityDate(), aDaycount: aLease.interestCalcMethod)
        let rentsTotal: Decimal = aLease.getTotalRents()
        let perDiem: Decimal = safeDivision(aNumerator: rentsTotal, aDenominator: Decimal(daysInTerm))
        decFullPeriodPayment = perDiem * Decimal(noOfDays)
    case .deNext:
        let daysInPeriod = daysInPmtPeriod(aFrequency: aLease.paymentsPerYear)
        let decPerDiem = safeDivision(aNumerator: strAmount.toDecimal(), aDenominator: daysInPeriod)
        decFullPeriodPayment = decPerDiem * Decimal(noOfDays)
    case .interest:
        decFullPeriodPayment = principalBalance * decDailyRate * Decimal(noOfDays)
    case .principal:
        decFullPeriodPayment = strAmount.toDecimal() + principalBalance * decDailyRate * Decimal(noOfDays)
    default:
        decFullPeriodPayment = strAmount.toDecimal()
    }
    
    return decFullPeriodPayment.toString(decPlaces: 8)
}

func getResetEBO(aLease: Lease, modDate: Date) -> EarlyPurchaseOption {
    if modDate >= aLease.earlyBuyOut!.exerciseDate {
        aLease.resetEarlyBuyOut()
    }
    return aLease.earlyBuyOut!
}

func eboLease(aLease: Lease, modDate: Date, rentDueIsPaid: Bool) -> Lease {
    let myLease = aLease.clone()

    // create groups before Mod Date
    myLease.groups = groupsToSchedule(aGroups: myLease.groups, aPayPerYear: myLease.paymentsPerYear, aReferDate: myLease.firstAnniversaryDate, aEOM: myLease.endOfMonthRule)
    var myGroupsBefore = Groups()
    myGroupsBefore = chopPayments(aSchedule: myLease.groups, asOfDate: modDate, returnBefore: true, inclusiveOfDate: true)
    myGroupsBefore.lockAllGroups()
    
    //Adjust last rent payment amount if not paid in addition to EBO
    if rentDueIsPaid == false {
        myGroupsBefore.items[myGroupsBefore.items.count - 1].amount = "0.00"
    }
   
    // create residual group and add to groups
    let strEBOAmount = (myLease.amount.toDecimal() * 0.5).toString()
    var aDateEnd = myGroupsBefore.items[myGroupsBefore.items.count - 1].endDate
    if myGroupsBefore.items[myGroupsBefore.items.count - 1].timing == .advance {
        aDateEnd = myGroupsBefore.items[myGroupsBefore.items.count - 1].startDate
    }
    let residualGroup = Group(aAmount: strEBOAmount, aEndDate: aDateEnd, aLocked: false, aNoOfPayments: 1, aStartDate: aDateEnd, aTiming: .equals, aType: .residual, aUndeletable: false, aIsInterim: false)
    myGroupsBefore.items.append(residualGroup)

    //Put schedule back into groups, add groups to myLease and solve for par EBO amount
    myGroupsBefore = scheduleToGroups(aGroups: myGroupsBefore, aPayPerYear: myLease.paymentsPerYear, aReferDate: myLease.firstAnniversaryDate, aEOM: myLease.endOfMonthRule)
    myLease.groups.items.removeAll()
    for x in 0..<myGroupsBefore.items.count {
        myLease.groups.items.append(myGroupsBefore.items[x])
    }
    myLease.solveForUnlockedPayments3()

    return myLease
}

func getExerciseDateFromTerm(aLease: Lease, term: Int) -> Date {
    return addPeriodsToDate(dateStart: aLease.baseTermCommenceDate, payPerYear: aLease.paymentsPerYear, noOfPeriods: term, referDate: aLease.firstAnniversaryDate, bolEOMRule: aLease.endOfMonthRule)
}

func getCapitalizedInterest(aAccruedInterest: Decimal, aInterestRate: Decimal, aDayCountMethod: DayCountMethod, aEOM: Bool, dateOfMod: Date, dateFirstPayment: Date) -> Decimal {
    let daysToFirstPayment: Int = dayCount(aDate1: dateOfMod, aDate2: dateFirstPayment, aDaycount: aDayCountMethod)
    let daysInYear: Double = daysInYear(aDate1: dateOfMod, aDate2: dateFirstPayment, aDayCountMethod: aDayCountMethod)
    let dailyRate: Decimal = aInterestRate / Decimal(daysInYear)

    let capInterest = aAccruedInterest - (aAccruedInterest / (1 + (dailyRate * Decimal(daysToFirstPayment))))
    return capInterest
}

func getAccruedInterest(aLease: Lease, principalBalance: Decimal, startDate: Date, endDate: Date) -> Decimal {
    var accruedInterest: Decimal = 0.0
    
    if endDate > startDate {
        let dayCount: Int = dayCount(aDate1: startDate, aDate2: endDate, aDaycount: aLease.interestCalcMethod)
        let dailyRate: Decimal = dailyRate(iRate: aLease.interestRate.toDecimal(), aDate1: startDate, aDate2: endDate, aDayCountMethod: aLease.interestCalcMethod)
        accruedInterest = principalBalance * dailyRate * Decimal(dayCount)
    }
   
    return accruedInterest
}

func getPerDiem(aLease: Lease, askDate: Date) -> Decimal {
    var dailyInterest: Decimal = 0.0
    
    if askDate >= aLease.fundingDate {
        aLease.setAmortizationsFromCashflow(consolidate: true)
        let interestInPeriod: Decimal = aLease.amortizations.lookUpInterest(askDate: askDate)
        let daysInPeriod: Int = aLease.amortizations.lookUpDaysInPeriod(askDate: askDate)
        dailyInterest = safeDivision(aNumerator: interestInPeriod, aDenominator: Decimal(daysInPeriod))
        aLease.amortizations.items.removeAll()
    }

    return dailyInterest
}

func getLastPaymentDateBeforeMod(aLease: Lease, modDate: Date) -> Date {
    let tempLease = aLease.deepClone()
    let tempGroups: Groups = tempLease.groups.deepClone()
    let tempSchedule: Groups = groupsToSchedule(aGroups: tempGroups, aPayPerYear: tempLease.paymentsPerYear, aReferDate: tempLease.firstAnniversaryDate, aEOM: tempLease.endOfMonthRule)
    let tempGroupsBefore = chopPayments(aSchedule: tempSchedule, asOfDate: modDate, returnBefore: true, inclusiveOfDate: true)
    let x: Int = tempGroupsBefore.items.count
    
    //Calculate payoff - outstanding balance + accrued interest
    var lastPaymentDateBeforeMod: Date = aLease.fundingDate
    if x > 0 {
        if tempGroupsBefore.items[x - 1].timing == .advance {
            lastPaymentDateBeforeMod = tempGroupsBefore.items[x - 1].startDate
        } else {
            lastPaymentDateBeforeMod = tempGroupsBefore.items[x - 1].endDate
        }
    }
    
    return lastPaymentDateBeforeMod
}

func getPrincipalBalance (aLease: Lease, askDate: Date) ->Decimal {
    aLease.setAmortizationsFromCashflow(consolidate: true)
  
    var decBalance: Decimal = aLease.amortizations.items[0].endBalance
    var x: Int = 1
    if aLease.amortizations.items[0].dueDate != askDate {
        while x < aLease.amortizations.items.count {
            if aLease.amortizations.items[x].dueDate > askDate {
                decBalance = aLease.amortizations.items[x - 1].endBalance
                break
            }
            x += 1
        }
    }
    aLease.amortizations.items.removeAll()
    
    return decBalance
}
