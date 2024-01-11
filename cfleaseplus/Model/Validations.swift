//
//  Validations.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

func isModDateValid(aLease: Lease, aModDate: Date) -> Bool {
    let minDate = aLease.fundingDate
    let maxDate = subtractOnePeriodFromDate(dateStart: aLease.getMaturityDate(), payperYear: aLease.paymentsPerYear, dateRefer: aLease.firstAnniversaryDate, bolEOMRule: aLease.endOfMonthRule)
    if aModDate >= minDate && aModDate <= maxDate {
        return true
    } else {
        return false
    }
}

func isAmountValid(strAmount: String, decLow: Decimal, decHigh: Decimal, inclusiveLow:  Bool, inclusiveHigh: Bool) -> Bool {
    // IsDecimal
    if strAmount.isDecimal() == false {
        return false
    }
    // Convert to decimal
    let decAmount = strAmount.toDecimal()

    if inclusiveLow == true {
        if decAmount < decLow {
            return false
        }
    } else {
        if decAmount <= decLow {
            return false
        }
    }
    if inclusiveHigh == true {
        if decAmount > decHigh {
            return false
        }
    } else {
        if decAmount >= decHigh {
            return false
        }
    }

    return true
}

func isIntegerValid(strInteger: String, intLow: Int, intHight: Int, inclusiveLow: Bool, inclusiveHigh: Bool) -> Bool {

    return false
}

func isInterestRateValid(strRate: String, decLow: Decimal, decHigh: Decimal, inclusiveLow: Bool, inclusiveHigh: Bool) -> Bool {
    if strRate.isDecimal() == false {
        return false
    }

    let decRate = strRate.toDecimal()

    if inclusiveLow == true {
        if decRate < decLow {
            return false
        }
    } else {
        if decRate <= decLow {
            return false
        }
    }
    if inclusiveHigh == true {
        if decRate > decHigh {
            return false
        }
    } else {
        if decRate >= decHigh {
            return false
        }
    }

    return true
}
