//
//  Lease.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

class Lease: ObservableObject {
    @Published var amount: String
    @Published var baseTermCommenceDate: Date
    @Published var baseTerm: Int
    @Published var childOf: Int
    @Published var endOfMonthRule: Bool
    @Published var firstAnniversaryDate: Date
    @Published var fundingDate: Date
    @Published var interestCalcMethod: DayCountMethod
    @Published var interestRate: String
   
    @Published var paymentsPerYear: Frequency
   
    @Published var groups: Groups
    @Published var fees: Fees?
    @Published var leaseObligations: Obligations?
    @Published var earlyBuyOut: EarlyPurchaseOption?
    @Published var amortizations: Amortizations
    @Published var terminations: Terminations?
    @Published var operatingMode: Mode
    
    //MARK: - Initialization
    init(amt: String, baseCommence: Date, term: Int, child: Int = -1, EOM: Bool, firstAnnual: Date, funding: Date, intCalcMethod: DayCountMethod, rate: String, payPerYear: Frequency, mode: Mode) {
        amount = amt
        baseTermCommenceDate = baseCommence
        baseTerm = term
        childOf = child
        endOfMonthRule = EOM
        firstAnniversaryDate = firstAnnual
        fundingDate = funding
        interestCalcMethod = intCalcMethod
        interestRate = rate
        paymentsPerYear = payPerYear
        groups = Groups()
        amortizations = Amortizations()
        operatingMode = mode
    }
    
    init (aDate: Date, mode: Mode) {
        amount = "1000000.00"
        baseTermCommenceDate = aDate
        baseTerm = 60
        childOf = -1
        endOfMonthRule = true
        firstAnniversaryDate = addPeriodsToDate(dateStart: aDate, payPerYear: .monthly, noOfPeriods: 12, referDate: aDate, bolEOMRule: true)
        fundingDate = aDate
        interestCalcMethod = DayCountMethod.Thirty_ThreeSixty_ConvUS
        interestRate = "0.05"
        paymentsPerYear = Frequency.monthly
        groups = Groups()
        amortizations = Amortizations()
        operatingMode = mode
        
        let endDate: Date = addPeriodsToDate(dateStart: fundingDate, payPerYear: .monthly, noOfPeriods: 60, referDate: fundingDate, bolEOMRule: true)
      
        let myGroup1 = Group(
            aAmount: "18871.40",
            aEndDate: endDate,
            aLocked: false,
            aNoOfPayments: 60,
            aStartDate: fundingDate,
            aTiming: PaymentTiming.arrears,
            aType: PaymentType.payment,
            aUndeletable: true,
            aIsInterim: false)
        
        groups.items.append(myGroup1)
        solveForUnlockedPayments3()
        initializeClasses()
    }
    
    func initializeClasses() {
        fees = Fees()
        leaseObligations = Obligations(aDiscountRate: interestRate, aResidualGuarantyAmount: "0.00")
        earlyBuyOut = EarlyPurchaseOption(aLease: self)
        terminations = Terminations(discountRate_Rent: interestRate.toDecimal(), discountRate_Residual: interestRate.toDecimal(), additionalResidual: 0.00)
    }
    
    
    func clone () -> Lease {
        let stringLease: String = writeLeaseOnly(aLease: self)
        let myClone: Lease = readLeaseOnly(strLease: stringLease)
        return myClone
    }
    
    func deepClone() -> Lease {
        let strLease: String = writeLeaseAndClasses(aLease: self)
        let myDeepClone: Lease = readLeaseAndClasses(strLease: strLease)
        return myDeepClone
    }
    
    func resetPayments () {
        for x in 0..<groups.items.count {
            groups.items[x].payments.reset()
        }
    }
  //MARK: - Create Payments
    func createPayments() {
        var begBalance: Decimal = amount.toDecimal()
        var prevFactor: Decimal = 1.0
        var prevStartDate: Date = fundingDate
        let dateRefer: Date = firstAnniversaryDate
        var dailyEquivNext: Decimal = 0.0
        var dailyEquivAll: Decimal = 0.0
        
        if groups.items.count > 1 {
            if groups.items[0].type == PaymentType.deNext || groups.items[0].type == PaymentType.deAll {
                let days = daysInPmtPeriod(aFrequency: paymentsPerYear)
                if groups.items[1].amount.isDecimal() {
                    let nextPayment: Decimal = Decimal(string: groups.items[1].amount) ?? 0.0
                    dailyEquivNext = nextPayment / days
                }
                dailyEquivAll = groups.getAveragePayment() / days
            }
        }
        for i in 0..<groups.items.count {
            var pmtsAreInAdvance: Bool = false
            let gpTiming = groups.items[i].timing
            if gpTiming == PaymentTiming.advance {
                pmtsAreInAdvance = true
            }
            let gpType = groups.items[i].type
            let gpAmount = groups.items[i].amount
            let gpNoOfPmts = groups.items[i].noOfPayments
            
            for j in 1...gpNoOfPmts {
                let currDueDate = getDueDate(x: i, y: j, bolPmtsInAdvance: pmtsAreInAdvance, prevDate: prevStartDate, aType: gpType, referDate: firstAnniversaryDate)
                var isDateMaturity = false
                if currDueDate == getMaturityDate() {
                    isDateMaturity = true
                }
                let decAmount = getPayment(aAmount: gpAmount, type: gpType, aTiming: gpTiming, begBalance: begBalance, dateStart: prevStartDate, dateEnd: currDueDate, referDate: dateRefer, deNext: dailyEquivNext, deAll: dailyEquivAll, dateEndIsMaturity: isDateMaturity, x: i, y: j)
                let decDailyRate = dailyRate(iRate: interestRate.toDecimal(), aDate1: prevStartDate, aDate2: currDueDate, aDayCountMethod: interestCalcMethod)
                let days = dayCount(aDate1: prevStartDate, aDate2: currDueDate, aDaycount: interestCalcMethod)
                let currFactor = getPVFactor(prevFactor: prevFactor, dailyRate: decDailyRate, daysInPmtPeriod: days)
                let decPV = decAmount * currFactor
                let newPayment = Payment(amount: decAmount, dueDate: currDueDate, factor: currFactor, pv: decPV, timing: gpTiming, type: gpType)
                groups.items[i].payments.items.append(newPayment)
                prevFactor = currFactor
                prevStartDate = currDueDate
                begBalance  = getBalance(grpNo: i)
            }
        }
        
    }
    
    func isFirstPaymentDatePeriodic() -> Bool {
        return isDatePeriodic(compareDate: fundingDate, askDate: baseTermCommenceDate, aFreq: paymentsPerYear, endOfMonthRule: endOfMonthRule, referDate: firstAnniversaryDate)
    }
        
    func getDueDate (x: Int, y: Int, bolPmtsInAdvance: Bool, prevDate: Date, aType: PaymentType, referDate: Date) -> Date {
        var dateDue: Date = prevDate
        
        if x == 0 && y == 1 {
            if bolPmtsInAdvance == true {
                dateDue = fundingDate
            } else {
                dateDue = getFirstPeriodEndDate()
            }
        } else if x > 0 && y == 1 {
            if groups.items[x].noOfPayments == 1 {
                if bolPmtsInAdvance == false {
                    dateDue = groups.items[x].endDate
                } else {
                    dateDue = groups.items[x].startDate
                }
            } else {
                if bolPmtsInAdvance == false {
                    dateDue = addOnePeriodToDate(dateStart: groups.items[x].startDate, payperYear: paymentsPerYear, dateRefer: referDate, bolEOMRule: endOfMonthRule)
                } else {
                    dateDue = groups.items[x].startDate
                }
            }
        } else {
            switch aType {
            case .balloon:
                return dateDue
            case .funding:
                return dateDue
            case .residual:
                return dateDue
            default:
                return addOnePeriodToDate(dateStart: dateDue, payperYear: paymentsPerYear, dateRefer: referDate, bolEOMRule: endOfMonthRule)
            }
        }
        return dateDue
    }
        
    func getFirstPeriodEndDate() -> Date {
        if baseTermCommenceDate == fundingDate {
            return addOnePeriodToDate(dateStart: fundingDate, payperYear: paymentsPerYear, dateRefer: fundingDate, bolEOMRule: endOfMonthRule)
        } else {
            return baseTermCommenceDate
        }
    }
        
    func getPVFactor (prevFactor: Decimal, dailyRate: Decimal, daysInPmtPeriod: Int) -> Decimal {
        return prevFactor / (1 + dailyRate * Decimal(daysInPmtPeriod))
    }
        
    func interestOnly (beginBalance: Decimal, dateStart: Date, dateEnd: Date, aDateEndIsMaturity: Bool) -> Decimal {
        let myDailyRate: Decimal = dailyRate(iRate: interestRate.toDecimal(), aDate1: dateStart, aDate2: dateEnd, aDayCountMethod: interestCalcMethod)
        let daysInPeriod: Int = dayCount(aDate1: dateStart, aDate2: dateEnd, aDaycount: interestCalcMethod)
        
        return beginBalance * Decimal(daysInPeriod) * myDailyRate
    }
        
    func getPayment(aAmount: String, type: PaymentType, aTiming: PaymentTiming, begBalance: Decimal, dateStart: Date, dateEnd: Date, referDate: Date, deNext: Decimal, deAll:Decimal, dateEndIsMaturity: Bool, x: Int, y: Int) -> Decimal {
        var myStartDate = dateStart
        var myEndDate = dateEnd
        var interestExpense: Decimal = interestOnly(beginBalance: begBalance, dateStart: myStartDate, dateEnd: myEndDate, aDateEndIsMaturity: dateEndIsMaturity)
        
        if x == 0 && y == 1 {
            myStartDate = fundingDate
            myEndDate = baseTermCommenceDate
            if aTiming == PaymentTiming.advance {
                interestExpense = 0.0
            }
        }
        
        switch type {
        case .deAll:
            let days = dayCount(aDate1: myStartDate, aDate2: myEndDate, aDaycount: interestCalcMethod)
            return deAll * Decimal(days)
        case .deNext:
            let days = dayCount(aDate1: myStartDate, aDate2: myEndDate, aDaycount: interestCalcMethod)
            return deNext * Decimal(days)
        case .interest:
            return interestExpense
        case .principal:
            return interestExpense + aAmount.toDecimal()
        default:
            return aAmount.toDecimal()
        }
    }
    
    func isTrueLease() -> Bool {
        var bolIsTrueLease: Bool = false
        
        if getTotalResidual() > 0.0 {
            bolIsTrueLease = true
        }
        return bolIsTrueLease
    }
    
    func averageLife() -> Decimal {
        let interestOneYear = amount.toDecimal() * interestRate.toDecimal()
        let totalInterest = getNetAmount()
        return totalInterest / interestOneYear
    }
    
    func baseTermIsSteppable() -> Bool {
        var counter: Int = 0
        for x in 0..<groups.items.count {
            if groups.items[x].noOfPayments > 1 {
                counter = counter + 1
            }
        }
        if counter > 1 {
            return false
        } else {
            return true
        }
    }
    
    func baseTermIsInWholeYears() -> Bool {
        var baseTermMonsInYears: Bool = true
        
        if getBaseTermInMons() % 12 != 0 {
            baseTermMonsInYears = false
        }
        
        return baseTermMonsInYears
    }
    
    func implicitRate() -> Decimal {
        let tempLease: Lease = self.clone()
        var strImplicit: String = tempLease.interestRate
        
        if tempLease.fees?.totalCustomerPaidFees() ?? 0.0 > 0.0 {
            let decAmount: Decimal = tempLease.amount.toDecimal() - tempLease.fees!.totalCustomerPaidFees()
            tempLease.amount = decAmount.toString()
            tempLease.solveForRate3()
            strImplicit = tempLease.interestRate.toTruncDecimalString(decPlaces: 8)
        }
        
        return strImplicit.toDecimal()
    }
    
    func getMaturityDate () -> Date {
        return groups.items[groups.items.count - 1].endDate
    }
    
    func getMaxTotalNumberPayments(maxBaseTerm: Int) -> Int {
        switch paymentsPerYear {
        case .annual:
            return maxBaseTerm / 12
        case .semiannual:
            return maxBaseTerm / 6
        case .quarterly:
            return maxBaseTerm / 3
        default:
            return maxBaseTerm
        }
    }
    
    func getMinTotalNumberPayments() -> Int {
        switch paymentsPerYear {
        case .annual:
            return 1
        case .semiannual:
            return 2
        case .quarterly:
            return 4
        default:
            return 12
        }
    }
    
    func getMaxRemainNumberPayments(maxBaseTerm: Int, freq: Frequency, eom: Bool, aRefer: Date) -> Int {
        let totalPossible = getMaxTotalNumberPayments(maxBaseTerm: maxBaseTerm)
        let totalExisting: Int = groups.getTotalNoOfBasePayments(aFreq: freq, eomRule: eom, aRefer: aRefer, interimGroupExists: self.interimGroupExists())
        
        return totalPossible - totalExisting
    }
    
    
    func getBaseTermInMons() -> Int {
        return monthsBetween(start: baseTermCommenceDate, end: groups.items[groups.items.count - 1].endDate)
    }
    
    func setBaseTermInMons(_ newBaseTerm: Int) {
        var step: Int = 1
        var grpIndex: Int = 0
        
        for x in 0..<groups.items.count{
            if groups.items[x].noOfPayments > 1 {
                if newBaseTerm < groups.items[x].noOfPayments * (12 / paymentsPerYear.rawValue) {
                    step = -1
                }
                let newNoOfPayments: Int = groups.items[x].noOfPayments + step
                groups.items[x].noOfPayments = newNoOfPayments
                grpIndex = x
                break
            }
        }
        if grpIndex == 0 {
            resetFirstGroup(isInterim: false)
        } else {
            resetRemainderOfGroups(startGrp: grpIndex)
        }
        baseTerm = getBaseTermInMons()
    }
    
    func getFullTerm() -> Decimal {
        let numberOfDays = daysBetween(start: fundingDate, end: getMaturityDate())
        return Decimal(numberOfDays) / 365.25
    }
        
    func getBalance(grpNo: Int) -> Decimal {
        var runTotal: Decimal = 0.0
        var decBalance: Decimal = 0.0
        
        for i in 0...grpNo {
            for j in 0..<groups.items[i].payments.items.count {
                runTotal = runTotal + groups.items[i].payments.items[j].pv
            }
        }
        
        let lastPmtNo = groups.items[grpNo].payments.items.count - 1
        let decFactor = groups.items[grpNo].payments.items[lastPmtNo].factor
        decBalance = (amount.toDecimal() - runTotal) * 1 / decFactor
        
        return decBalance
    }
    
    func getEndingBalance() -> Decimal {
        createPayments()
        
        let a: Decimal = amount.toDecimal()
        let c: Decimal = getEndingTotalPV()
        let b: Decimal = getEndingFactor()
        let balanceEnding: Decimal = safeDivision(aNumerator: (a - c), aDenominator: b)
        
        resetPayments()

        return balanceEnding
    }
    
    func getEndingFactor() -> Decimal {
        let indexOfLastGroup = groups.items.count - 1
        let endingFactor = groups.items[indexOfLastGroup].payments.getPaymentsEndingFactor()
    
        return endingFactor
    }
    
    func getEndingTotalPV() -> Decimal {
        var runTotalPV: Decimal = 0.00
        
        for x in 0..<groups.items.count {
                runTotalPV = runTotalPV + groups.items[x].payments.getPaymentsTotalPV()
        }
        
        return runTotalPV
    }
    
    func getNetAmount() -> Decimal {
        let decAmount = amount.toDecimal()
        return getTotalPayments() - decAmount
    }
    
    func getTotalCashflows() -> Cashflows {
        let myFees = Cashflows(aFees: self.fees!, aFeeType: .all)
        let myCashflows = Cashflows(aLease: self)
        var myNetTotal = Cashflows()
        myNetTotal = myNetTotal.netTwoCashflows(cfsOne: myFees, cfsTwo: myCashflows)
        
        return myNetTotal
    }
    
    func getTotalPayments() -> Decimal {
        createPayments()
        
        var totalPayments:Decimal = 0.0
        for x in 0..<groups.items.count {
            totalPayments = totalPayments + groups.items[x].payments.getTotalAmount()
        }
        resetPayments()
        
        return totalPayments
    }
    
    
    func getTotalRents () -> Decimal {
        var totalRents: Decimal = 0.0
        
        createPayments()
        for x in 0..<groups.items.count{
            for y in 0..<groups.items[x].payments.items.count {
                if groups.items[x].payments.items[y].type != .residual {
                    totalRents = totalRents + groups.items[x].payments.items[y].amount
                }
            }
        }
        resetPayments()
        
        return totalRents
    }
    
    func getTotalResidual () -> Decimal {
        return groups.getTotalResidual()
    }
    
    func getTotalInterest() -> Decimal {
        setAmortizationsFromLease()
        let decTotalInterest = self.amortizations.getTotalInterest()
        self.amortizations.items.removeAll()
        
        return decTotalInterest
    
    }
    
    func getTotalPrincipal() -> Decimal {
        setAmortizationsFromLease()
        let decTotalPrincipal = self.amortizations.getTotalPrincipal()
        self.amortizations.items.removeAll()
        
        return decTotalPrincipal
    }
    
    func eboExists() -> Bool {
        if isTrueLease() == false {
            return false
        }
        let eboAmount:Decimal = earlyBuyOut!.amount.toDecimal()
        if eboAmount == 0.0 {
            return false
        }
        let parValue: Decimal = getParValue(askDate: earlyBuyOut!.exerciseDate, rentDueIsPaid: earlyBuyOut!.rentDueIsPaid)
        let margin: Decimal = parValue * 1.0001
        if eboAmount < margin {
            return false
        }
        return true
    }
    
    func interimGroupExists() -> Bool {
        var bolInterimExists: Bool = false
        if baseTermCommenceDate != fundingDate {
            bolInterimExists = true
        }
        
        return bolInterimExists
    }
    
    func terminationsExist() -> Bool {
        let testRentRate: Bool = amountsAreEqual(aAmt1: interestRate.toDecimal(), aAmt2: terminations!.discountRate_Rent, aLamda: 0.0005)
        let testResidualRate: Bool = amountsAreEqual(aAmt1: interestRate.toDecimal(), aAmt2: terminations!.discountRate_Residual, aLamda: 0.0005)
        let testAddedResidual: Bool = amountsAreEqual(aAmt1: 0.00, aAmt2: terminations!.additionalResidual, aLamda: 0.0005)
        
        if testRentRate == true && testResidualRate == true && testAddedResidual == true {
            return false
        } else {
            return true
        }
    }
    
    func paymentsExist() -> Bool {
        var bolPaymentsExist = true
        
        for x in 0..<groups.items.count {
            if groups.items[x].payments.items.count == 0 {
                bolPaymentsExist = false
            } else {
                bolPaymentsExist = true
            }
        }
        
        return bolPaymentsExist
    }
    
    func frequencyToNoOfPmts(number: Int, oldFreq: Frequency, newFreq: Frequency) -> Int {
        let newNumber: Int = (number / oldFreq.rawValue) * newFreq.rawValue
        return newNumber
    }
    
    func setFirstPeriodEndDate() -> Date{
        var returnDate: Date
        if baseTermCommenceDate == fundingDate {
            returnDate = addOnePeriodToDate(dateStart: fundingDate, payperYear: paymentsPerYear, dateRefer: fundingDate, bolEOMRule: endOfMonthRule)
        } else {
            returnDate = baseTermCommenceDate
        }
        return returnDate
    }
    
    func setFirstAnniversaryDate () -> Date {
        var calcFirstAnnivDate: Date?
        var startDate = fundingDate
        if baseTermCommenceDate != startDate {
            startDate = baseTermCommenceDate
        }
        
        switch paymentsPerYear {
        case .annual:
            calcFirstAnnivDate = addPeriodsToDate(dateStart: startDate, payPerYear: Frequency.annual, noOfPeriods: 1, referDate: startDate, bolEOMRule: endOfMonthRule)
        case .semiannual:
            calcFirstAnnivDate =  addPeriodsToDate(dateStart: startDate, payPerYear: Frequency.semiannual, noOfPeriods: 2, referDate: startDate, bolEOMRule: endOfMonthRule)
        case .quarterly:
            calcFirstAnnivDate = addPeriodsToDate(dateStart: startDate, payPerYear: Frequency.quarterly, noOfPeriods: 4, referDate: startDate, bolEOMRule: endOfMonthRule)
        case .monthly:
             calcFirstAnnivDate = addPeriodsToDate(dateStart: startDate, payPerYear: Frequency.monthly, noOfPeriods: 12, referDate: startDate, bolEOMRule: endOfMonthRule)
        }
        
        return calcFirstAnnivDate!
    }
    
    
    
    
}
