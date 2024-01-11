//
//  LeaseFxns.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation


extension Lease {

    func getPremiumPaid(aBuyRate: String) -> String {
        let tempLease: Lease = self.clone()
        var premiumPaid: String = tempLease.getNetAmount().toString()

        if aBuyRate.toDecimal() > 0.00 {
            let parAmount: Decimal = tempLease.amount.toDecimal()
            let strBuyRate: String = aBuyRate
            tempLease.interestRate = strBuyRate
            tempLease.solveForPrincipal()
            let adjAmount: Decimal = tempLease.amount.toDecimal()
            premiumPaid = (adjAmount - parAmount).toString()
        }

        return  premiumPaid.toTruncDecimalString(decPlaces: 2)
    }

    func getBuyRate(afterLesseeFee: Bool) -> String {
        let tempLease: Lease = self.clone()
        if afterLesseeFee == true {
            tempLease.amount = (tempLease.amount.toDecimal() - (tempLease.fees?.totalCustomerPaidFees() ?? 0.0)).toString(decPlaces: 8)
        }

        if tempLease.fees?.totalPurchaseFees() ?? 0.0 != 0.00 {
            let decFeePaid: Decimal = tempLease.fees?.totalPurchaseFees() ?? 0.0
            let leaseAmount: Decimal = tempLease.amount.truncateAmount(decPlaces: 4).toDecimal()
            let total: Decimal = leaseAmount + decFeePaid
            let premiumAmount: String = total.toString(decPlaces: 4)
            tempLease.amount = premiumAmount
        }
        tempLease.solveForRate3()

        return tempLease.interestRate
    }

}

extension Lease {

    func getRentDue (exerDate: Date, rentDueIsPaid: Bool) -> (String, PaymentTiming) {
        let m_EBOLease = eboLease(aLease: self, modDate: exerDate, rentDueIsPaid: rentDueIsPaid)
        let rentDue: String = m_EBOLease.groups.items[m_EBOLease.groups.items.count - 2].amount
        let timing: PaymentTiming = m_EBOLease.groups.items[m_EBOLease.groups.items.count - 2].timing

        return (rentDue, timing)
    }

    func getEBOTerm(exerDate: Date) -> Int {
        return Calendar.current.dateComponents([.month], from:baseTermCommenceDate, to: exerDate).month!
    }

    func getEBOAmount (aLease: Lease, bpsPremium: Int, exerDate: Date, rentDueIsPaid: Bool) -> String {
        var strEBOAmount: String = "0.00"
        let myLease = aLease.clone()
        let m_EBOLease = eboLease(aLease: myLease, modDate: exerDate, rentDueIsPaid: rentDueIsPaid)

        m_EBOLease.groups.lockAllGroups()
        m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].locked = false

        if bpsPremium > 0 {
            var decPremium = Decimal(bpsPremium)
            decPremium = decPremium / 10000.0
            let eboYield: Decimal = m_EBOLease.interestRate.toDecimal() + decPremium
            m_EBOLease.interestRate = eboYield.toString(decPlaces: 5)
            m_EBOLease.solveForUnlockedPayments3()
            strEBOAmount = m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].amount
        } else {
            strEBOAmount = m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].amount
        }

        return strEBOAmount.toTruncDecimalString(decPlaces: 2)
    }

    func getExerciseDate(term: Int) -> Date {
        let newDate: Date = addPeriodsToDate(dateStart: self.baseTermCommenceDate, payPerYear: self.paymentsPerYear, noOfPeriods: term, referDate: self.firstAnniversaryDate, bolEOMRule: self.endOfMonthRule)
        return newDate
    }

    func eboYield(aLease: Lease, rentDueIsPaid: Bool, withLesseeFee: Bool) -> Decimal {
        let myLease = aLease.deepClone()
        let m_EBOLease = eboLease(aLease: myLease, modDate: myLease.earlyBuyOut!.exerciseDate, rentDueIsPaid: rentDueIsPaid)

        m_EBOLease.groups.lockAllGroups()
        m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].locked = false

        m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].amount = myLease.earlyBuyOut!.amount
        if withLesseeFee == true {
            m_EBOLease.amount = (m_EBOLease.amount.toDecimal() - (aLease.fees?.totalCustomerPaidFees() ?? 0.0)).toString()
        }
        m_EBOLease.solveForRate3()
        let decEBOYield: Decimal = m_EBOLease.interestRate.toDecimal()

        return decEBOYield
    }

    func eboBuyerYield(aLease: Lease, rentDueIsPaid: Bool, withLesseeFee: Bool) -> Decimal {
        let myLease = aLease.deepClone()
        let m_EBOLease = eboLease(aLease: myLease, modDate: myLease.earlyBuyOut!.exerciseDate, rentDueIsPaid: rentDueIsPaid)
        let decPurchaseFee: Decimal = myLease.fees?.totalPurchaseFees() ?? 0.0
        var decAmount = m_EBOLease.amount.toDecimal()
        decAmount = decAmount + decPurchaseFee
        m_EBOLease.amount = decAmount.toString(decPlaces: 6)

        m_EBOLease.groups.lockAllGroups()
        m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].locked = false

        m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].amount = myLease.earlyBuyOut!.amount
        if withLesseeFee == true {
            m_EBOLease.amount = (m_EBOLease.amount.toDecimal() - (aLease.fees?.totalCustomerPaidFees() ?? 0.0)).toString()
        }
        m_EBOLease.solveForRate3()
        let decEBOYield: Decimal = m_EBOLease.interestRate.toDecimal()

        return decEBOYield
    }

    func getEBOPremium(aLease: Lease, exerDate: Date, aEBOAmount: String, rentDueIsPaid: Bool) -> Int {
        var bpsPremium: Int = 0
        let myLease = aLease.clone()
        let m_EBOLease = eboLease(aLease: myLease, modDate: exerDate, rentDueIsPaid: rentDueIsPaid)

        if amountsAreEqual(aAmt1: m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].amount.toDecimal(), aAmt2: aEBOAmount.toDecimal(), aLamda: 0.5) == false {
            m_EBOLease.groups.items[m_EBOLease.groups.items.count - 1].amount = aEBOAmount
            m_EBOLease.solveForRate3()
            let decDiff: Decimal = m_EBOLease.interestRate.toDecimal() - myLease.interestRate.toDecimal()
            bpsPremium = (decDiff * 10000.00).toInteger()
        }

        return bpsPremium
    }


    func getParValue(askDate: Date, rentDueIsPaid: Bool) -> Decimal {
        self.setAmortizationsFromCashflow(consolidate: true)
        var decBalance: Decimal = amortizations.lookUpBalance(askDate: askDate)
        let rentDue: Decimal = amortizations.lookUpPayment(askDate: askDate)
        if rentDueIsPaid == false {
            decBalance = decBalance + rentDue
        }
        self.amortizations.items.removeAll()

        return decBalance
    }


}


extension Lease {

    func getPVOfRents(discountRate: Decimal) -> Decimal {
        var m_Rents: Cashflows = Cashflows()
        m_Rents = Cashflows(aLease: self, returnType: .payment)
        return m_Rents.XNPV(aDiscountRate: discountRate, aDayCountMethod: interestCalcMethod)
    }

    func getPVOfResidualGuaranty(discountRate: Decimal, residualGuaranty: Decimal) -> Decimal {
        let m_ResidualObligation: Cashflows = Cashflows(aLease: self, returnType: .residual)
        let last = m_ResidualObligation.items.count - 1
        m_ResidualObligation.items[last].amount = residualGuaranty

        return m_ResidualObligation.XNPV(aDiscountRate: discountRate, aDayCountMethod: interestCalcMethod)
    }

    func getMaxResidualGuaranty (discountRate: Decimal) -> Decimal {
        let pvOfMaxGty: Decimal =  (0.8995 * amount.toDecimal()) - (fees?.totalCustomerPaidFees() ?? 0.0) - getPVOfRents(discountRate: discountRate)
        let m_LeaseTemplate: Cashflows = Cashflows(aLease: self, returnType: .residual)
        m_LeaseTemplate.zeroOutAmounts()
        m_LeaseTemplate.items[0].amount = pvOfMaxGty
        return m_LeaseTemplate.XNFV(aPVAmount: pvOfMaxGty, aCompoundRate: discountRate, aDayCount: interestCalcMethod)
    }

    func getTotalObligation(discountRate: Decimal, residualGuaranty: Decimal) -> Decimal {
        return (fees?.totalCustomerPaidFees() ?? 0.0) + getPVOfRents(discountRate: discountRate) + getPVOfResidualGuaranty(discountRate: discountRate, residualGuaranty: residualGuaranty)
    }

    func getLessorAccountingOfLease(residualGuaranty: Decimal) -> String {
        let pvMinRents: Decimal = getTotalObligation(discountRate: implicitRate(), residualGuaranty: residualGuaranty)
        let pvMinRentsAsPercent = pvMinRents / amount.toDecimal()

        if pvMinRentsAsPercent < 0.90 {
            return "Operating"
        } else {
            return "Finance"
        }
    }

    func getLesseeAccountingOfLease() -> String {
        let pvMinRents: Decimal = getTotalObligation(discountRate: leaseObligations!.discountRate.toDecimal(), residualGuaranty: leaseObligations!.residualGuarantyAmount.toDecimal())
        let pvMinRentsAsPercent = pvMinRents / amount.toDecimal()

        if pvMinRentsAsPercent < 0.90 {
            return "Operating"
        } else {
            return "Finance"
        }
    }

    func getThirdPartyGuarantyForFinance(residualGuaranty: Decimal) -> Decimal {
        let pvMinRents: Decimal = getTotalObligation(discountRate: implicitRate(), residualGuaranty: residualGuaranty)
        let pvMinRentsAsPercent = pvMinRents / amount.toDecimal()

        if pvMinRentsAsPercent < 0.90 {
            let pvOfGuaranty = (0.90 - pvMinRentsAsPercent) * amount.toDecimal()
            let m_LeaseTemplate: Cashflows = Cashflows(aLease: self, returnType: .residual)
            m_LeaseTemplate.zeroOutAmounts()
            m_LeaseTemplate.items[0].amount = pvOfGuaranty
            let fvOfGuaranty = m_LeaseTemplate.XNFV(aPVAmount: pvOfGuaranty, aCompoundRate: implicitRate(), aDayCount: interestCalcMethod)

            return fvOfGuaranty
        } else {
            return 0.00
        }
    }
}

extension Lease {

    func createRentalTValues(discountRate: Decimal, inLieuRent: Bool) -> Cashflows {
        let m_RentCashflows: Cashflows = Cashflows(aLease: self, returnType: .payment)

        let m_RentNPVs: Cashflows = Cashflows()
        if inLieuRent == true {
            m_RentCashflows.items[0].amount = 0.00
        }
        var decNPVRentRemaining = m_RentCashflows.XNPV(aDiscountRate: discountRate, aDayCountMethod: interestCalcMethod) / amount.toDecimal()

        var myCF = Cashflow(due: m_RentCashflows.items[0].dueDate, amt: decNPVRentRemaining)
        m_RentNPVs.items.append(myCF)
        m_RentCashflows.items.remove(at: 0)

        while m_RentCashflows.items.count > 0 {
            if inLieuRent == true {
                m_RentCashflows.items[0].amount = 0.00
            }
            decNPVRentRemaining = m_RentCashflows.XNPV(aDiscountRate: discountRate, aDayCountMethod: interestCalcMethod) / amount.toDecimal()
            myCF = Cashflow(due: m_RentCashflows.items[0].dueDate, amt: decNPVRentRemaining)
            m_RentNPVs.items.append(myCF)
            m_RentCashflows.items.remove(at: 0)
        }

        return m_RentNPVs
    }

    func createResidualTValues(discountRate: Decimal, addedResidual: Decimal) -> Cashflows {
        let m_ResidualCashflows: Cashflows = Cashflows(aLease: self, returnType: .residual)
        let totalResidual: Decimal = (addedResidual * self.amount.toDecimal()) + m_ResidualCashflows.items[m_ResidualCashflows.items.count - 1].amount
        m_ResidualCashflows.items[m_ResidualCashflows.items.count - 1].amount = totalResidual

        let m_ResidualNPVs: Cashflows = Cashflows()


        while m_ResidualCashflows.items.count > 0 {
            let decAmount = m_ResidualCashflows.XNPV(aDiscountRate: discountRate, aDayCountMethod: interestCalcMethod) / amount.toDecimal()
            let myCF = Cashflow(due: m_ResidualCashflows.items[0].dueDate, amt: decAmount)
            m_ResidualNPVs.items.append(myCF)
            m_ResidualCashflows.items.remove(at: 0)
        }

        return m_ResidualNPVs
    }


    func terminationValues(rateForRent: Decimal, rateForResidual: Decimal, adder: Decimal, inLieuOfRent: Bool) -> Cashflows {
        let rentNPVs: Cashflows = createRentalTValues(discountRate: rateForRent, inLieuRent: inLieuOfRent)
        let residualNPVs: Cashflows = createResidualTValues(discountRate: rateForResidual, addedResidual: adder)
        let myTValues: Cashflows = Cashflows()
        for x in 0..<rentNPVs.items.count {
            let decAmount = rentNPVs.items[x].amount + residualNPVs.items[x].amount
            let due = rentNPVs.items[x].dueDate
            let myTV: Cashflow = Cashflow(due: due, amt: decAmount)
            myTValues.items.append(myTV)
        }

        return myTValues
    }


    func parValues2(inLieuOfRent: Bool) -> Cashflows {
        let rentNPVs: Cashflows = createRentalTValues(discountRate: interestRate.toDecimal(), inLieuRent: inLieuOfRent)
        let residualNPVs: Cashflows = createResidualTValues(discountRate: interestRate.toDecimal(), addedResidual: 0.0)
        let myParValues: Cashflows = Cashflows()

        for x in 0..<rentNPVs.items.count {
            let decAmount = rentNPVs.items[x].amount + residualNPVs.items[x].amount
            let due = rentNPVs.items[x].dueDate
            let myTV: Cashflow = Cashflow(due: due, amt: decAmount)
            myParValues.items.append(myTV)
        }
         return myParValues
    }

}
