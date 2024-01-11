//
//  Cashflow.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

struct Cashflow {
    var dueDate : Date
    var amount: Decimal
    var locked: Bool? = false
    
    init(due: Date, amt: Decimal) {
        dueDate = due
        amount = amt
    }
    
    init(due: Date, amt: Decimal, lock: Bool) {
        dueDate = due
        amount = amt
        locked = lock
    }
    
    func toString () -> String {
        return "Due Date: " + dateToString(dateAsk: dueDate) + ", Amount: " + amount.toString()
    }
}

class  Cashflows {
    var items: [Cashflow]

    init() {
        items = [Cashflow]()
    }
    
    init(aLease: Lease, returnType: PaymentType, aFactor: Decimal = 1.0) {
        items = [Cashflow]()
        let myLease = aLease.clone()
        myLease.createPayments()
        var amount: Decimal
        var dateDue: Date
        
        switch returnType {
        //all payments excluding the residual or the balloon, no funding
        case .payment:
                amount = 0.0
                dateDue = myLease.fundingDate
                let myCF = Cashflow(due: dateDue, amt: amount)
                items.append(myCF)
                for x in 0..<myLease.groups.items.count {
                    for y in 0..<myLease.groups.items[x].payments.items.count {
                        dateDue = myLease.groups.items[x].payments.items[y].dueDate
                        amount = myLease.groups.items[x].payments.items[y].amount
                        if myLease.groups.items[x].payments.items[y].type == .residual || myLease.groups.items[x].payments.items[y].type == .balloon {
                            amount = 0.0
                        }
                        let myCF = Cashflow(due: dateDue, amt: amount)
                        items.append(myCF)
                    }
            }
            //just the residual or balloon payment
            case .residual:
                amount = 0.0
                dateDue = myLease.fundingDate
                let myCF = Cashflow(due: dateDue, amt: amount)
                items.append(myCF)
                for x in 0..<myLease.groups.items.count {
                    for y in 0..<myLease.groups.items[x].payments.items.count {
                        dateDue = myLease.groups.items[x].payments.items[y].dueDate
                        amount = 0.0
                        if myLease.groups.items[x].payments.items[y].type == .residual {
                            amount = myLease.groups.items[x].payments.items[y].amount
                        }
                        let myCF = Cashflow(due: dateDue, amt: amount)
                        items.append(myCF)
                    }
                }
            //all payments except funding
            default:
                amount = 0.0
                dateDue = myLease.fundingDate
                let myCF = Cashflow(due: dateDue, amt: amount)
                items.append(myCF)
                for x in 0..<myLease.groups.items.count {
                    for y in 0..<myLease.groups.items[x].payments.items.count {
                        dateDue = myLease.groups.items[x].payments.items[y].dueDate
                        amount = myLease.groups.items[x].payments.items[y].amount * aFactor
                        let myCF = Cashflow(due: dateDue, amt: amount)
                        items.append(myCF)
                    }
                }
        }
        myLease.resetPayments()
        consolidateCashflows()
    }
    
    //all lease payments including funding as negative amount
    init(aLease: Lease) {
        items = [Cashflow]()
        let myLease = aLease.clone()
        myLease.createPayments()
        var amount: Decimal
        var dateDue: Date
        var locked: Bool
        
        amount = myLease.amount.toDecimal() * -1.0
        dateDue = myLease.fundingDate
        let myCF = Cashflow(due: dateDue, amt: amount)
        items.append(myCF)
        
        for x in 0..<myLease.groups.items.count {
            for y in 0..<myLease.groups.items[x].payments.items.count {
                amount = myLease.groups.items[x].payments.items[y].amount
                dateDue = myLease.groups.items[x].payments.items[y].dueDate
                locked = myLease.groups.items[x].locked
                let myCF = Cashflow(due: dateDue, amt: amount, lock: locked)
                items.append(myCF)
            }
        }
        myLease.resetPayments()
    }
    
    //returns lease cashflows from an amortization object
    init(aAmortizations: Amortizations, returnPayments: Bool) {
        items = [Cashflow]()
        if returnPayments == true {
            for x in 0..<aAmortizations.items.count {
                var decAmount = aAmortizations.items[x].payment
                if x == 0 {
                    decAmount = aAmortizations.items[x].funding * -1.0
                }
                let myCF = Cashflow(due: aAmortizations.items[x].dueDate, amt: decAmount)
                items.append(myCF)
            }
        } else {
            for x in 0..<aAmortizations.items.count {
                let decAmount = aAmortizations.items[x].endBalance
                let myCF = Cashflow(due: aAmortizations.items[x].dueDate, amt: decAmount)
                items.append(myCF)
            }
        }
    }
    
    //initializes a Cashflows object of the interest components from an Amortizations Object
    init(aAmortizations: Amortizations) {
        items = [Cashflow]()
        for x in 0..<aAmortizations.items.count {
            let interestAmount = aAmortizations.items[x].interest
            let myCF = Cashflow(due: aAmortizations.items[x].dueDate, amt: interestAmount)
            items.append(myCF)
        }
    }
    
    init(aFees: Fees, aFeeType: FeeType) {
        items = [Cashflow]()
        
        switch aFeeType {
        case .customerPaid:
            var decAmount: Decimal = 0.0
            for x in 0..<aFees.items.count{
                if aFees.items[x].type == .customerPaid {
                    decAmount = aFees.items[x].amount.toDecimal()
                    let asOfDate: Date = aFees.items[x].effectiveDate
                    let myCF: Cashflow = Cashflow(due: asOfDate, amt: decAmount)
                    items.append(myCF)
                }
            }
        case .other:
            for x in 0..<aFees.items.count{
                var decAmount: Decimal = aFees.items[x].amount.toDecimal()
                if aFees.items[x].type == .other {
                    if aFees.items[x].incomeType == .expense {
                        decAmount = decAmount * -1.0
                    }
                    let asOfDate: Date = aFees.items[x].effectiveDate
                    let myCF: Cashflow = Cashflow(due: asOfDate, amt: decAmount)
                    items.append(myCF)
                }
            }
            
        case .purchase:
            for x in 0..<aFees.items.count{
                var decAmount: Decimal = aFees.items[x].amount.toDecimal()
                if aFees.items[x].type == .purchase {
                    if aFees.items[x].incomeType == .expense {
                        decAmount = decAmount * -1.0
                    }
                    let asOfDate: Date = aFees.items[x].effectiveDate
                    let myCF: Cashflow = Cashflow(due: asOfDate, amt: decAmount)
                    items.append(myCF)
                }
            }
            
        default:
            for x in 0..<aFees.items.count{
                var decAmount: Decimal = aFees.items[x].amount.toDecimal()
                if aFees.items[x].incomeType == .expense {
                    decAmount = decAmount * -1.0
                }
                let asOfDate: Date = aFees.items[x].effectiveDate
                let myCF: Cashflow = Cashflow(due: asOfDate, amt: decAmount)
                items.append(myCF)
            }
        }
            
    }
       
    
    
    func getTotalCashflow () -> Decimal {
        var runTotalAmount: Decimal = 0.0
        
        for x in 0..<items.count {
            runTotalAmount = runTotalAmount + items[x].amount
        }
        return runTotalAmount
    }
    
    func getTotalAnnualCashflow () -> Cashflows {
        let totalAnnualCF: Cashflows = Cashflows()
        let startYear: Int = getYearComponent(dateIn: items[0].dueDate)
    
        var comps = DateComponents()
        comps.day = 31
        comps.month = 12
        comps.year = startYear
        
        var yearEnd = Calendar.current.date(from: comps)!
        var runTotal: Decimal = 0
        for x in 0..<items.count {
            if items[x].dueDate <= yearEnd {
                runTotal = runTotal + items[x].amount
            }
            let annualCF: Cashflow = Cashflow(due: yearEnd, amt: runTotal)
            totalAnnualCF.items.append(annualCF)
            runTotal = 0.0
            yearEnd = Calendar.current.date(byAdding: .year, value: 1, to: yearEnd)!
        }
        return totalAnnualCF
    }
    
  
    func consolidateCashflows() {
        while checkConsolidation() == false {
            if items.count > 1 {
                for x in 0..<items.count {
                    for y in 1..<items.count {
                        if x + y > items.count - 1 {
                            break
                        }
                        if items[x].dueDate == items[x + y].dueDate {
                            let newAmount = items[x].amount + items[x + y].amount
                            items[x].amount = newAmount
                            items.remove(at: x + y)
                        }
                    }
                }
            }
        }
    }
    
    func addCashflow(aCFs: Cashflows) -> Cashflows {
        let myCashflows: Cashflows = self
        for x in 0..<myCashflows.items.count{
            let myCF: Cashflow = Cashflow(due: myCashflows.items[x].dueDate, amt: aCFs.items[x].amount)
            myCashflows.items.append(myCF)
        }
        return myCashflows
    }
    
    func subtractCashflow(aCFs: Cashflows) -> Cashflows {
        let myCashflows: Cashflows = self
        for x in 0..<myCashflows.items.count{
            let decAmount: Decimal = aCFs.items[x].amount * -1.0
            let myCF: Cashflow = Cashflow(due: aCFs.items[x].dueDate, amt: decAmount)
            myCashflows.items.append(myCF)
        }
        return myCashflows
    }
    
    
    func checkConsolidation() -> Bool {
        var consolidationIsValid: Bool = true
        
        for x in 0..<items.count - 1 {
            if items[x].dueDate == items[x + 1].dueDate {
                consolidationIsValid = false
                break
            }
        }
        
        return consolidationIsValid
    }
    
    func deepClone () -> Cashflows {
        let strCashflows = writeCashflows(aCFs: self)
        return readCashflows(strCFs: strCashflows)
    }
    
    func netTwoCashflows(cfsOne: Cashflows, cfsTwo: Cashflows) -> Cashflows {
        let one: Cashflows = cfsOne.deepClone()
        let two: Cashflows = cfsTwo.deepClone()
        let temp = Cashflows()
        var iCount = one.items.count + two.items.count
        
        while iCount > 1 {
            let amt: Decimal
            let due: Date
            if one.items.count == 0 {
                for x in 0..<two.items.count {
                    temp.items.append(two.items[x])
                }
                iCount = 0
                break
            }
            if two.items.count == 0 {
                for x in 0..<one.items.count {
                    temp.items.append(one.items[x])
                }
                iCount = 0
                break
            }
            if one.items[0].dueDate == two.items[0].dueDate {
                amt = one.items[0].amount + two.items[0].amount
                due = one.items[0].dueDate
                one.items.remove(at: 0)
                two.items.remove(at: 0)
            } else if one.items[0].dueDate > two.items[0].dueDate {
                amt = two.items[0].amount
                due = two.items[0].dueDate
                two.items.remove(at: 0)
            } else {
                amt = one.items[0].amount
                due = one.items[0].dueDate
                one.items.remove(at: 0)
            }
            let myCF = Cashflow(due: due, amt: amt)
            temp.items.append(myCF)
            iCount = one.items.count + two.items.count
        }
        return temp
    }
    
    func getIndex(dateAsk: Date, returnNextOnMatch: Bool) -> Int {
        var idx:Int = 0
        
        for i in 0..<items.count {
            if dateAsk == items[i].dueDate {
                idx = i
                break
            } else if dateAsk < items[i].dueDate {
                if returnNextOnMatch == true {
                    idx = i - 1
                    break
                } else {
                    idx = i
                    break
                }
            }
        }
        
        return idx
    }
    
    func vLookup(dateAsk: Date, returnNextOnMatch: Bool) -> Cashflow {
        var myCashflow: Cashflow = items[0]
        
        for i in 0..<items.count {
            if dateAsk == items[i].dueDate {
                myCashflow = items[i]
                break
            } else if dateAsk < items[i].dueDate {
                if returnNextOnMatch == true {
                    myCashflow = items[i - 1]
                    break
                } else {
                    myCashflow = items[i]
                    break
                }
            }
        }
        
        return myCashflow
    }
    
    func vLookupMonth(dateAsk: Date) -> Int {
        var month: Int = 0
        
        for i in 0..<items.count {
            if dateAsk == items[i].dueDate {
                month = i
             break
            }
        }
        return month
    }
    
    func vLookupDate(month: Int) -> Date {
        return items[month].dueDate
    }
    
//
    
    func XIRR2(guessRate: Decimal, _DayCountMethod: DayCountMethod) -> Decimal {
        var irr: Decimal = guessRate
        var y: Decimal = XNPV(aDiscountRate: irr, aDayCountMethod: _DayCountMethod)
        var iCount: Int = 1
        
        while abs(y) > toleranceAmounts {
            if y > 0.0 {
                irr = incrementRate(x1: irr, y1: y, iCounter: iCount, _DayCountMethod: _DayCountMethod)
            } else {
                irr = decrementRate(x1: irr, y1: y, iCounter: iCount, _DayCountMethod: _DayCountMethod)
            }
            y =  XNPV(aDiscountRate: irr, aDayCountMethod: _DayCountMethod)
            iCount += 1
        }
        
       return irr
    }
    
    func incrementRate(x1: Decimal, y1: Decimal, iCounter: Int, _DayCountMethod: DayCountMethod) -> Decimal {
        //when NPV > 0.0
        var newX: Decimal = x1
        var newY: Decimal = y1
        let factor: Decimal = power(base: 10.0, exp: iCounter)
        
        while newY > 0.0 {
            newX = newX + newX / factor
            newY = XNPV(aDiscountRate: newX, aDayCountMethod: _DayCountMethod)
        }
        return mxbFactor(factor1: x1, value1: y1, factor2: newX, value2: newY)
    }
    
    func decrementRate(x1: Decimal, y1: Decimal, iCounter: Int, _DayCountMethod: DayCountMethod) -> Decimal {
        //when NPV < 0.0
        var newX: Decimal = x1
        var newY: Decimal = y1
        let factor: Decimal = power(base: 10.0, exp: iCounter)
        
        while newY < 0.0 {
            newX = newX - newX / factor
            newY = XNPV(aDiscountRate: newX, aDayCountMethod: _DayCountMethod)
        }
        return mxbFactor(factor1: x1, value1: y1, factor2: newX, value2: newY)
    }
    
    
    func XNPV (aDiscountRate: Decimal, aDayCountMethod: DayCountMethod) -> Decimal {
        var tempSum = items[0].amount
        if items.count > 1 {
            var prevPVFactor: Decimal = 1.0
            var x = 1
            while x < items.count {
                let dateStart = items[x - 1].dueDate
                let dateEnd = items[x].dueDate
                let aDailyRate: Decimal = dailyRate(iRate: aDiscountRate, aDate1: dateStart, aDate2: dateEnd, aDayCountMethod: aDayCountMethod)
                let aDayCount = dayCount(aDate1: dateStart, aDate2: dateEnd, aDaycount: aDayCountMethod)
                let currPVFactor: Decimal = prevPVFactor / ( 1.0 + aDailyRate * Decimal(aDayCount))
                let pvAmount: Decimal = currPVFactor * items[x].amount
                tempSum = tempSum + pvAmount
                prevPVFactor = currPVFactor
                x = x + 1
            }
        }
        return tempSum
    }
    
    func XNFV (aPVAmount: Decimal, aCompoundRate: Decimal, aDayCount: DayCountMethod) -> Decimal {
        var prevFVFactor: Decimal = 1.0
        
        for i in 1..<items.count {
            let dateStart = items[i - 1].dueDate
            let dateEnd = items[i].dueDate
            let dailyCompound = dailyRate(iRate: aCompoundRate, aDate1: dateStart, aDate2: dateEnd, aDayCountMethod: aDayCount)
            let noOfDays = Decimal(dayCount(aDate1: dateStart, aDate2: dateEnd, aDaycount: aDayCount))
            let compoundRate = 1.0 + dailyCompound * noOfDays
            let currFVFactor = prevFVFactor * compoundRate
            prevFVFactor = currFVFactor
        }
       return aPVAmount * prevFVFactor
    }
    
    func zeroOutAmounts() {
        for x in 0..<items.count {
            items[x].amount = 0.0
        }
    }
    
}

class CollCashflows {
    var items: [Cashflows]
    
    init() {
        items = [Cashflows]()
    }

    func netAllCashflows() -> Cashflows {
        var tempCF = Cashflows()
        tempCF = tempCF.netTwoCashflows(cfsOne: items[0], cfsTwo: items[1])
        
        if items.count < 3 {
            tempCF.consolidateCashflows()
            return tempCF
        }
        
        for i in 2...items.count - 1 {
            tempCF = tempCF.netTwoCashflows(cfsOne: tempCF, cfsTwo: items[i])
        }
        
        tempCF.consolidateCashflows()
        return tempCF
    }
    
    func totalCashflow() -> Decimal {
        var runTotal: Decimal = 0.0
        for i in 0..<items.count {
            runTotal = runTotal + items[i].getTotalCashflow()
        }
        return runTotal
    }
    
}
