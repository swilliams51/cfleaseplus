//
//  ArrayFx.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

func getInvestorSummary(aLease: Lease, currentFile: String, maxCharsInLine: Int) -> [[String]] {
    let txtLease: Lease = aLease.deepClone()
    
    var mySummary = [[String]]()
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxCharsInLine, spaces: 0)
    mySummary.append(title)
    
    let stats: [String]
    stats = getLeaseStats(aLease: txtLease, maxChars: maxCharsInLine)
    mySummary.append(stats)
    
    let cashFlows: [String]
    cashFlows = getLeaseCashflows(aLease: txtLease, maxCharsInLine: maxCharsInLine)
    mySummary.append(cashFlows)
    
    let params: [String]
    params = getLeaseParameters(aLease: txtLease, includeRate: true, maxChars: maxCharsInLine)
    mySummary.append(params)
    
    let paySchedule: [String]
    paySchedule = getPaymentSchedule(aLease: txtLease, isCustomerReport: false, maxChars: maxCharsInLine)
    mySummary.append(paySchedule)
    
    let lessorAcctg: [String]
    if aLease.isTrueLease() == true {
        lessorAcctg = getLessorAcctg(aLease: aLease, maxChars: maxCharsInLine)
        mySummary.append(lessorAcctg)
    }
    
    let purchaseDetails: [String]
    if txtLease.fees?.totalPurchaseFees() ?? 0.0 > 0.0 {
        purchaseDetails = getPurchaseDetails(aLease: txtLease, maxChars: maxCharsInLine)
        mySummary.append(purchaseDetails)
    }
    
    let earlyBuyOut: [String]
    if txtLease.isTrueLease() {
        if txtLease.eboExists() == true {
            earlyBuyOut = getEarlyBuyOut(aLease: txtLease, isCustomerReport: false, maxCharsInLine: maxCharsInLine)
            mySummary.append(earlyBuyOut)
        }
    }
    
    let tvalues: [String]
    if txtLease.terminationsExist() {
        tvalues = getTerminationInputs(aLease: txtLease, maxCharsInLine: maxCharsInLine)
        mySummary.append(tvalues)
    }
    
    return mySummary
}

func getCustomerSummary(aLease: Lease, currentFile: String, includeRate: Bool, isCustomerReport: Bool, maxCharsInLine: Int) -> [[String]] {
    let txtLease: Lease = aLease.deepClone()
    
    var mySummary = [[String]]()
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxCharsInLine, spaces: 0)
    mySummary.append(title)
    
    let params: [String]
    params = getLeaseParameters(aLease: txtLease, includeRate: includeRate, maxChars: maxCharsInLine)
    mySummary.append(params)
    
    let paySchedule: [String]
    paySchedule = getPaymentSchedule(aLease: txtLease, isCustomerReport: isCustomerReport, maxChars: maxCharsInLine)
    mySummary.append(paySchedule)
    
    let obligations: [String]
    if txtLease.isTrueLease() {
        obligations = getLesseeObligations(aLease: txtLease, maxChars: maxCharsInLine)
        mySummary.append(obligations)
    }
    
    let earlyBuyOut: [String]
    if txtLease.isTrueLease() {
        if txtLease.eboExists() == true {
            earlyBuyOut = getEarlyBuyOut(aLease: txtLease, isCustomerReport: isCustomerReport, maxCharsInLine: maxCharsInLine)
            mySummary.append(earlyBuyOut)
        }
    }
    return mySummary
}

func getLeaseStats (aLease: Lease, maxChars: Int) -> [String] {
    var arry = [String]()
    var mode: Mode = .leasing
    
    let str_ln_Title = sectionTitle(strTitle: "Statistics", aLeadFollow: "_", maxChars: maxChars)
    arry.append(str_ln_Title)
    
    if aLease.operatingMode == .lending {
        mode = .lending
    }
    
    var structureMode: String = "Leasing"
    if mode == .lending {
        structureMode = "Lending"
    }
    let line_Mode: String = justifyText(strA: "Mode", strB: structureMode, maxLength: maxChars)
    arry.append(line_Mode)
    
    if mode == .leasing{
        if aLease.groups.areAdvArrSwitchesValid() == false {
            let warning_ln_Timing = justifyText(strA: "Warning", strB: "Timing Switches > 1", maxLength: maxChars)
            arry.append(warning_ln_Timing)
        }
        
        let strTrueLease: String = aLease.isTrueLease().toString()
        let line_TrueLease: String = justifyText(strA: "Is True Lease", strB: strTrueLease, maxLength: maxChars)
        arry.append(line_TrueLease)
    }
    
    let decFullTerm: Decimal = aLease.getFullTerm()
    let strFullTerm: String = decFullTerm.toString(decPlaces: 2) + " yrs"
    let line_FullTerm: String = justifyText(strA: "Full Term", strB: strFullTerm, maxLength: maxChars)
    arry.append(line_FullTerm)
    
    //let intBaseTerm: Int = aLease.getBaseTermInMons()
    let months: Int = monthsBetween(start: aLease.baseTermCommenceDate, end: aLease.getMaturityDate())
    let dblBaseTerm: Decimal = Decimal(months) / 12.00
    let strBaseTerm: String = dblBaseTerm.toString(decPlaces: 2) + " yrs"
    let line_BaseTerm: String = justifyText(strA: "Base Term", strB: strBaseTerm, maxLength: maxChars)
    arry.append(line_BaseTerm)
   
    let decAverageLife = aLease.averageLife()
    let strAverageLife = decAverageLife.toString(decPlaces: 2) + " yrs"
    let line_AverageLife = justifyText(strA: "Average Life", strB: strAverageLife, maxLength: maxChars)
    arry.append(line_AverageLife)
    
    //Interest Rate
    let strInterestRate: String = aLease.interestRate.toDecimal().toPercent(3)
    let line_InterestRate: String = justifyText(strA: "Interest Rate", strB: strInterestRate, maxLength: maxChars)
    arry.append(line_InterestRate)
    
    //Implicit Rate
    var strImplicitRateText: String = "Implicit Rate"
    if mode == .lending{
        strImplicitRateText = "APR"
    }
    let strImplicitRate: String = aLease.implicitRate().toPercent(3)
    let line_ImplicitRate: String = justifyText(strA: strImplicitRateText, strB: strImplicitRate, maxLength: maxChars)
    arry.append(line_ImplicitRate)

    //EBO Rate
    if aLease.eboExists() {
        let strEBOYield: String =  aLease.eboYield(aLease: aLease, rentDueIsPaid: aLease.earlyBuyOut!.rentDueIsPaid, withLesseeFee: false).toPercent(3)
        let line_EBOYield: String = justifyText(strA: "EBO Yield", strB: strEBOYield, maxLength: maxChars)
        arry.append(line_EBOYield)
        
        if aLease.fees?.totalCustomerPaidFees() ?? 0.0 != 0.0 {
            let strEBOYieldAfterLesseeFee: String =  aLease.eboYield(aLease: aLease, rentDueIsPaid: aLease.earlyBuyOut!.rentDueIsPaid, withLesseeFee: true).toPercent(3)
            let line_EBOYieldAfterLesseeFee: String = justifyText(strA: "EBO Yield w/Lessee Fee", strB: strEBOYieldAfterLesseeFee, maxLength: maxChars)
            arry.append(line_EBOYieldAfterLesseeFee)
        }
    }
    arry.append("")
    
    //Interest Rate, Implicit Rate, EBO Rate after Buyer Paid Fee
    if aLease.fees?.totalPurchaseFees() ?? 0.0 != 0.00 {
        let str_ln_Title = sectionTitle(strTitle: "Buyer Yields", aLeadFollow: "_", maxChars: maxChars)
        arry.append(str_ln_Title)
        let strBuyerYield: String = "Yield"
        let strBuyerEBOYield: String = "EBO Yield"
        
        if aLease.fees?.totalPurchaseFees() ?? 0.0 != 0.0 {
            //Provide Yield and EBO Yield w/lessee Paid Fee
            //Yield
            let tempLease: Lease = aLease.deepClone()
            let strBuyRateAfterLesseeFee = tempLease.getBuyRate(afterLesseeFee: true)
            let str_BuyRateAfterLesseeFee = strBuyRateAfterLesseeFee.toDecimal().toPercent(3)
            let line_BuyRateAfterLesseeFee: String = justifyText(strA: strBuyerYield, strB: str_BuyRateAfterLesseeFee, maxLength: maxChars)
            arry.append(line_BuyRateAfterLesseeFee)
            
            if tempLease.eboExists() == true {
                //Yield to EBO
                let strEBOYieldAfterLesseeFee: String =  tempLease.eboBuyerYield(aLease: aLease, rentDueIsPaid: tempLease.earlyBuyOut!.rentDueIsPaid, withLesseeFee: true).toPercent(3)
                let line_EBOYieldAfterLesseeFee: String = justifyText(strA: strBuyerEBOYield, strB: strEBOYieldAfterLesseeFee, maxLength: maxChars)
                arry.append(line_EBOYieldAfterLesseeFee)
            }
           
        } else {
            // provide Yield and EBO Yield w/o lessee Paid Fee
            //Yield
            let tempLease: Lease = aLease.deepClone()
            let strBuyRateAfterLesseeFee = tempLease.getBuyRate(afterLesseeFee: false)
            let str_BuyRateAfterLesseeFee = strBuyRateAfterLesseeFee.toDecimal().toPercent(3)
            let line_BuyRateAfterLesseeFee: String = justifyText(strA: strBuyerYield, strB: str_BuyRateAfterLesseeFee, maxLength: maxChars)
            arry.append(line_BuyRateAfterLesseeFee)
            
            //Yield to EBO
            if tempLease.eboExists() == true {
                let strEBOYieldAfterLesseeFee: String =  tempLease.eboBuyerYield(aLease: aLease, rentDueIsPaid: tempLease.earlyBuyOut!.rentDueIsPaid, withLesseeFee: false).toPercent(3)
                let line_EBOYieldAfterLesseeFee: String = justifyText(strA: strBuyerEBOYield, strB: strEBOYieldAfterLesseeFee, maxLength: maxChars)
                arry.append(line_EBOYieldAfterLesseeFee)
            }
        }
        arry.append("")
    }

    return arry
}


func getLeaseCashflows(aLease: Lease, maxCharsInLine: Int) -> [String] {
    var arry_Cashflow = [[String]]()
    
    // Total Cash Out
    var arry_CashOut = [String]()
    let str_ln_Title = sectionTitle(strTitle: "Cashflow", aLeadFollow: "_", maxChars: maxCharsInLine)
    arry_CashOut.append(str_ln_Title)
    
    let decLeaseAmount: Decimal = aLease.amount.toDecimal()
    let strForTotalsLine: String = decLeaseAmount.toCurrency(false)
    let intTotalsLine = strForTotalsLine.count
    let strLeaseAmount: String = formatAsTotal(decAmount: decLeaseAmount, deNominator: decLeaseAmount)
    let line_LeaseAmount: String = justifyText(strA: "Amount", strB: strLeaseAmount, maxLength: maxCharsInLine)
    arry_CashOut.append(line_LeaseAmount)
    
    var decFeesPaid: Decimal = 0.0
    if aLease.fees?.totalFeesPaid() ?? 0.0 != 0.00 {
        decFeesPaid = aLease.fees?.totalFeesPaid() ?? 0.0
    }
    
    let strFeesPaid: String = formatAsTotal(decAmount: decFeesPaid, deNominator: decLeaseAmount)
    let line_PurchaseFees: String = justifyText(strA: "Fees Paid", strB: strFeesPaid, maxLength: maxCharsInLine)
    arry_CashOut.append(line_PurchaseFees)
    arry_CashOut.append(totalsLine(maxChars: maxCharsInLine, lenOfTotalsLine: intTotalsLine, lenOfPctLine: 7))
    
    let decTotalCashOut: Decimal = decLeaseAmount + decFeesPaid
    let strTotalCashOut: String = formatAsTotal(decAmount: decTotalCashOut, deNominator: decLeaseAmount)
    let line_TotalCashOut: String = justifyText(strA: "Cash Out", strB: strTotalCashOut, maxLength: maxCharsInLine)
    arry_CashOut.append(line_TotalCashOut)
    arry_CashOut.append("")
    
    arry_Cashflow.append(arry_CashOut)
    
    // Total Cash In
    var arry_CashIn = [String]()
    var decTotalCashIn: Decimal = 0.0
    if aLease.isTrueLease() == true {
        arry_CashIn = getTrueLeaseCashflows(aLease: aLease, maxChars: maxCharsInLine).0
        decTotalCashIn = getTrueLeaseCashflows(aLease: aLease, maxChars: maxCharsInLine).1
    } else {
        arry_CashIn = getCapitalLeaseCashflows(aLease: aLease, maxChars: maxCharsInLine).0
        decTotalCashIn = getCapitalLeaseCashflows(aLease: aLease, maxChars: maxCharsInLine).1
    }
    arry_Cashflow.append(arry_CashIn)
    
    // Net Cashflow
    var arry_NetCash = [String]()
    let decNetCash: Decimal = decTotalCashIn - decTotalCashOut
    let strNetCash: String = formatAsTotal(decAmount: decNetCash, deNominator: decLeaseAmount)
    let line_NetCash: String = justifyText(strA: "Net Cash", strB: strNetCash, maxLength: maxCharsInLine)
    arry_NetCash.append(line_NetCash)
    arry_NetCash.append("")
    arry_Cashflow.append(arry_NetCash)
    
    var arry_CFReport = [String]()
    for x in 0..<arry_Cashflow.count {
        for y in 0..<arry_Cashflow[x].count {
            let strLine: String = arry_Cashflow[x][y]
            arry_CFReport.append(strLine)
        }
    }
    
    return arry_CFReport
}

func getTrueLeaseCashflows(aLease: Lease, maxChars: Int) -> ([String], Decimal) {
    let myLease: Lease = aLease.deepClone()
    
    var arry = [String]()
    let decAmount = myLease.amount.toDecimal()
    let intTotalsLine = decAmount.toCurrency(false).count
    
    let decFeesReceived = myLease.fees?.totalFeesReceived() ?? 0.0
    let strFeesReceived = formatAsTotal(decAmount: decFeesReceived, deNominator: decAmount)
    let str_ln_FeesReceived = justifyText(strA: "Fees Rec'd", strB: strFeesReceived, maxLength: maxChars)
    arry.append(str_ln_FeesReceived)
    
    let decTotalRents = myLease.getTotalRents()
    let strTotalRents = formatAsTotal(decAmount: decTotalRents, deNominator: decAmount)
    let str_ln_TotalRents = justifyText(strA: "Rents", strB: strTotalRents, maxLength: maxChars)
    arry.append(str_ln_TotalRents)
    
    let decTotalResidual = myLease.getTotalResidual()
    let strTotalResidual = formatAsTotal(decAmount: decTotalResidual, deNominator: decAmount)
    let str_ln_TotalResidual = justifyText(strA: "Residual", strB: strTotalResidual, maxLength: maxChars)
    arry.append(str_ln_TotalResidual)
    arry.append(totalsLine(maxChars: maxChars, lenOfTotalsLine: intTotalsLine, lenOfPctLine: 7))
    
    let decTotalIn: Decimal = decFeesReceived + decTotalRents + decTotalResidual
    let strTotalIn: String = formatAsTotal(decAmount: decTotalIn, deNominator: decAmount)
    let str_ln_TotalIn: String = justifyText(strA: "Cash In", strB: strTotalIn, maxLength: maxChars)
    arry.append(str_ln_TotalIn)
    arry.append("")
    
    return (arry, decTotalIn)
}

func getCapitalLeaseCashflows(aLease:Lease, maxChars: Int) -> ([String], Decimal) {
    let myLease = aLease.deepClone()
    
    var arry = [String]()
    let decAmount = myLease.amount.toDecimal()
    let intTotalsLine = decAmount.toCurrency(false).count
    
    let decFeesReceived = myLease.fees?.totalFeesReceived() ?? 0.0
    let strFeesReceived = formatAsTotal(decAmount: decFeesReceived, deNominator: decAmount)
    let str_ln_FeesReceived = justifyText(strA: "Fees", strB: strFeesReceived, maxLength: maxChars)
    arry.append(str_ln_FeesReceived)
    
    let decTotalInterest = myLease.getTotalInterest()
    let strTotalInterest = formatAsTotal(decAmount: decTotalInterest, deNominator: decAmount)
    let str_ln_TotalInterest = justifyText(strA: "Interest", strB: strTotalInterest, maxLength: maxChars)
    arry.append(str_ln_TotalInterest)
    
    let decTotalPrincipal = myLease.amount.toDecimal()
    let strTotalPrincipal = formatAsTotal(decAmount: decTotalPrincipal, deNominator: decAmount)
    let str_ln_TotalPrincipal = justifyText(strA: "Principal", strB: strTotalPrincipal, maxLength: maxChars)
    arry.append(str_ln_TotalPrincipal)
    arry.append(totalsLine(maxChars: maxChars, lenOfTotalsLine: intTotalsLine, lenOfPctLine: 7))
    
    let decTotalIn: Decimal = decFeesReceived + decTotalInterest + decTotalPrincipal
    let strTotalIn: String = formatAsTotal(decAmount: decTotalIn, deNominator: decAmount)
    let str_ln_TotalIn: String = justifyText(strA: "Cash In", strB: strTotalIn, maxLength: maxChars)
    arry.append(str_ln_TotalIn)
    arry.append("")
    
    return (arry, decTotalIn)
}


func getLeaseParameters(aLease: Lease, includeRate: Bool, maxChars: Int) -> [String] {
    var arry = [String]()
    
    let str_ln_Title = sectionTitle(strTitle: "Parameters", aLeadFollow: "_", maxChars: maxChars)
    arry.append(str_ln_Title)
    
    var structureMode: String = "Leasing"
    if aLease.operatingMode == .lending {
        structureMode = "Lending"
    }
    let line_Mode: String = justifyText(strA: "Mode", strB: structureMode, maxLength: maxChars)
    arry.append(line_Mode)
    
    let strAmount: String = aLease.amount.toDecimal().toCurrency(false)
    let line_Amount = justifyText(strA: "Amount", strB: strAmount, maxLength: maxChars)
    arry.append(line_Amount)
    
    let strFunding: String = aLease.fundingDate.toStringDateShort(yrDigits: 2)
    let line_Funding: String = justifyText(strA: "Funding Date", strB: strFunding, maxLength: maxChars)
    arry.append(line_Funding)
    
    if aLease.fees?.totalCustomerPaidFees() ?? 0.0 > 0.0 {
        let strLesseeFee: String = (aLease.fees?.totalCustomerPaidFees() ?? 0.0).toCurrency(false)
        let line_LesseeFee: String = justifyText(strA: "Customer Fee at Funding", strB: strLesseeFee, maxLength: maxChars)
        arry.append(line_LesseeFee)
    }
    
    let strBaseCommence: String = aLease.baseTermCommenceDate.toStringDateShort(yrDigits: 2)
    let line_BaseCommence: String = justifyText(strA: "Base Commence", strB: strBaseCommence, maxLength: maxChars)
    arry.append(line_BaseCommence)
    
    let strMaturityDate: String = aLease.getMaturityDate().toStringDateShort(yrDigits: 2)
    let line_MaturityDate: String = justifyText(strA: "Maturity Date", strB: strMaturityDate, maxLength: maxChars)
    arry.append(line_MaturityDate)
    
    if includeRate == true {
        let strRate : String = aLease.interestRate.toDecimal().toPercent(3)
        let line_Rate: String = justifyText(strA: "Interest Rate", strB: strRate, maxLength: maxChars)
        arry.append(line_Rate)
    }
    
    if includeRate == true {
        if aLease.eboExists() == true {
            let strEBOYield: String =  aLease.eboYield(aLease: aLease, rentDueIsPaid: aLease.earlyBuyOut!.rentDueIsPaid, withLesseeFee: true).toPercent(3)
            let line_EBOYield: String = justifyText(strA: "IRR to EBO", strB: strEBOYield, maxLength: maxChars)
            arry.append(line_EBOYield)
        }
    }
    
    let strFrequency: String = aLease.paymentsPerYear.toString()
    let line_Frequency: String = justifyText(strA: "Frequency", strB: strFrequency, maxLength: maxChars)
    arry.append(line_Frequency)
    
    let strBaseTerm = aLease.getBaseTermInMons().toString() + " mons"
    let line_BaseTerm: String = justifyText(strA: "Base Term", strB: strBaseTerm, maxLength: maxChars)
    arry.append(line_BaseTerm)
    
    let strDayCount: String = aLease.interestCalcMethod.toString()
    let line_DayCount: String = justifyText(strA: "Day Count Method", strB: strDayCount, maxLength: maxChars)
    arry.append(line_DayCount)
    
    let strEOM: String = aLease.endOfMonthRule.toString()
    let line_EOM: String = justifyText(strA: "EOM Rule On", strB: strEOM, maxLength: maxChars)
    arry.append(line_EOM)
    arry.append("")
    
    return arry
}

func getPaymentSchedule(aLease: Lease, isCustomerReport: Bool, maxChars: Int) -> [String] {
    var arry = [String]()
    let tab = 3
    let str_ln_Break: String = String()
    
    let str_ln_Title = sectionTitle(strTitle: "Payment Schedule", aLeadFollow: "-", maxChars: maxChars)
    arry.append(str_ln_Title)
    
    aLease.createPayments()
    for x in 0..<aLease.groups.items.count {
        let strTiming = aLease.groups.items[x].timing.toString()
        let strGrpTitle = "Group " + (x + 1).toString() + " - Timing: " + strTiming
        let intLen = strGrpTitle.count
        let str_ln_Group = strGrpTitle + buffer(spaces: maxChars - intLen)
        arry.append(str_ln_Group)
        
        let strType = aLease.groups.items[x].type.toString()
        let strNoOfPmts = aLease.groups.items[x].noOfPayments.toString()
        let strFromDate = aLease.groups.items[x].startDate.toStringDateShort(yrDigits: 2)
        let strToDate = aLease.groups.items[x].endDate.toStringDateShort(yrDigits: 2)
        let strLocked = aLease.groups.items[x].locked.toString()
        var decAmount: Decimal
        if aLease.groups.items[x].amount == "CALCULATED" {
            decAmount = aLease.groups.items[x].payments.items[0].amount
        } else {
            decAmount = aLease.groups.items[x].amount.toDecimal()
        }
        let decLRF: Decimal = decAmount / aLease.amount.toDecimal()
        let strLRF: String = decLRF.toPercent(5)
        let strAmount = decAmount.toCurrency(false)
        
        let str_ln_Type = justifyText(strA: buffer(spaces: tab) + "Type", strB: strType, maxLength: maxChars)
        let str_ln_NoOfPmts = justifyText(strA: buffer(spaces: tab) + "Number", strB: strNoOfPmts, maxLength: maxChars)
        let str_ln_FromDate = justifyText(strA: buffer(spaces: tab) + "From", strB: strFromDate, maxLength: maxChars)
        let str_ln_ToDate = justifyText(strA: buffer(spaces: tab) + "To", strB: strToDate, maxLength: maxChars)
        let str_ln_Locked = justifyText(strA: buffer(spaces: tab) + "Locked", strB: strLocked, maxLength: maxChars)
        let str_ln_Amount = justifyText(strA: buffer(spaces: tab) + "Amount", strB: strAmount, maxLength: maxChars)
        let str_ln_LRF = justifyText(strA: buffer(spaces: tab) + "LRF", strB: strLRF, maxLength: maxChars)
        
        arry.append(str_ln_Type)
        arry.append(str_ln_NoOfPmts)
        arry.append(str_ln_FromDate)
        arry.append(str_ln_ToDate)
        arry.append(str_ln_Locked)
        arry.append(str_ln_Amount)
        arry.append(str_ln_LRF)
        arry.append(str_ln_Break)
    }
    aLease.resetPayments()
    
    return arry
}

func getLessorAcctg(aLease: Lease, maxChars: Int) -> [String] {
    var arry = [String]()
    
    let str_ln_Title = sectionTitle(strTitle: "Lessor Accounting", aLeadFollow: "*", maxChars: maxChars)
    arry.append(str_ln_Title)
    
    let strLessorAcctg: String = aLease.getLessorAccountingOfLease(residualGuaranty: aLease.leaseObligations!.residualGuarantyAmount.toDecimal())
    let line_LessorAccounting = justifyText(strA: "FAS 842 Type", strB: strLessorAcctg, maxLength: maxChars)
    arry.append(line_LessorAccounting)
    
    let decDiscountRate: Decimal = aLease.implicitRate()
    let strDiscountRate: String = decDiscountRate.toPercent(2)
    let line_DiscountRate = justifyText(strA: "Implicit Rate", strB: strDiscountRate, maxLength: maxChars)
    arry.append(line_DiscountRate)
    
    let decResidualGuaranty: Decimal = aLease.leaseObligations!.residualGuarantyAmount.toDecimal()
    let strResidualGuaranty = formatAsTotal(decAmount: decResidualGuaranty, deNominator: aLease.amount.toDecimal())
    let line_ResidualGuaranty = justifyText(strA: "Lessee Rsdl Gty", strB: strResidualGuaranty, maxLength: maxChars)
    arry.append(line_ResidualGuaranty)
    arry.append("")
    
    let decPVOfRents: Decimal = aLease.getPVOfRents(discountRate: decDiscountRate)
    let strPVRents = formatAsTotal(decAmount: decPVOfRents, deNominator: aLease.amount.toDecimal())
    let line_PVRents = justifyText(strA: "PV of Rents", strB: strPVRents, maxLength: maxChars)
    arry.append(line_PVRents)
    
    let decPVOfResidualGuaranty = aLease.getPVOfResidualGuaranty(discountRate: decDiscountRate, residualGuaranty: decResidualGuaranty)
    let strPVResidualGuaranty = formatAsTotal(decAmount: decPVOfResidualGuaranty, deNominator: aLease.amount.toDecimal())
    let line_PVResidualGuaranty = justifyText(strA: "PV of Rsdl Gty", strB: strPVResidualGuaranty, maxLength: maxChars)
    arry.append(line_PVResidualGuaranty)
    
    let decFees: Decimal = aLease.fees?.totalCustomerPaidFees() ?? 0.0
    let strFees = formatAsTotal(decAmount: decFees, deNominator: aLease.amount.toDecimal())
    let line_Fees = justifyText(strA: "Customer Paid Fees", strB: strFees, maxLength: maxChars)
    arry.append(line_Fees)
    arry.append(totalsLine(maxChars: maxChars, lenOfTotalsLine: 13, lenOfPctLine: 7))
    
    let decTotalOblig: Decimal = decPVOfRents + decPVOfResidualGuaranty + decFees
    let strTotalOblig = formatAsTotal(decAmount: decTotalOblig, deNominator: aLease.amount.toDecimal())
    let line_TotalOblig = justifyText(strA: "Total Oblig PV", strB: strTotalOblig, maxLength: maxChars)
    arry.append(line_TotalOblig)
    
    if strLessorAcctg == "Operating" {
        let decThirdPartyGuaranty: Decimal = aLease.getThirdPartyGuarantyForFinance(residualGuaranty: aLease.leaseObligations!.residualGuarantyAmount.toDecimal())
        let strThirdPartyGuaranty: String = formatAsTotal(decAmount: decThirdPartyGuaranty, deNominator: aLease.amount.toDecimal())
        let line_ThirdPartyGuaranty: String = justifyText(strA: "3rd Party Gty", strB: strThirdPartyGuaranty, maxLength: maxChars)
        arry.append(line_ThirdPartyGuaranty)
    }
    arry.append("")
    
    return arry
}

func getPurchaseDetails(aLease: Lease, maxChars: Int) -> [String] {
    var arry = [String]()
    
    let str_ln_Title = sectionTitle(strTitle: "Purchase Details", aLeadFollow: "*", maxChars: maxChars)
    arry.append(str_ln_Title)
    
    //Buy Rate
    let strBuyRate: String = aLease.getBuyRate(afterLesseeFee: false).toDecimal().toPercent(2)
    let str_ln_BuyRate: String = justifyText(strA: "Buy Rate", strB: strBuyRate, maxLength: maxChars)
    arry.append(str_ln_BuyRate)
    
    //Purchase Price
    let decPurchasePrice:Decimal = aLease.amount.toDecimal() + (aLease.fees?.totalCustomerPaidFees() ?? 0.0)
    let strPurchasePrice: String = decPurchasePrice.toCurrency(false)
    let str_ln_PurchasePrice: String =  justifyText(strA: "Purchase Price", strB: strPurchasePrice, maxLength: maxChars)
    arry.append(str_ln_PurchasePrice)
    
    //Par Value
    let decParValue: Decimal = aLease.amount.toDecimal()
    let strParValue: String = decParValue.toCurrency(false)
    let str_ln_ParValue: String = justifyText(strA: "Amount", strB: strParValue, maxLength: maxChars)
    arry.append(str_ln_ParValue)
    
    let str_ln_Totals = totalsLine(maxChars: maxChars, lenOfTotalsLine: 10)
    arry.append(str_ln_Totals)
    
    let decGain: Decimal = decPurchasePrice - decParValue
    let strGain: String = decGain.toCurrency(false)
    let str_ln_Gain: String = justifyText(strA: "Gain on Sale", strB: strGain, maxLength: maxChars)
    arry.append(str_ln_Gain)
    
    let decGainAsPercent: Decimal = decGain / decParValue
    let strGainAsPercent: String = decGainAsPercent.toPercent(3)
    let str_ln_GainAsPercent: String = justifyText(strA: "% of Amount", strB: strGainAsPercent, maxLength: maxChars)
    arry.append(str_ln_GainAsPercent)
    arry.append("")
    
    return arry
}

func getLesseeObligations (aLease: Lease, maxChars: Int) -> [String] {
    var arry = [String]()
    
    let str_ln_Title = sectionTitle(strTitle: "Lessee Accounting", aLeadFollow: "*", maxChars: maxChars)
    arry.append(str_ln_Title)
    
    let strLesseeAcctg: String = aLease.getLesseeAccountingOfLease()
    let line_LesseeAccounting = justifyText(strA: "FAS 842 Type", strB: strLesseeAcctg, maxLength: maxChars)
    arry.append(line_LesseeAccounting)
    
    let decDiscountRate: Decimal = aLease.leaseObligations!.discountRate.toDecimal()
    let strDiscountRate: String = decDiscountRate.toPercent(2)
    let line_DiscountRate = justifyText(strA: "Discount Rate", strB: strDiscountRate, maxLength: maxChars)
    arry.append(line_DiscountRate)
    
    let decResidualGuaranty: Decimal = aLease.leaseObligations!.residualGuarantyAmount.toDecimal()
    let strResidualGuaranty = formatAsTotal(decAmount: decResidualGuaranty, deNominator: aLease.amount.toDecimal())
    let line_ResidualGuaranty = justifyText(strA: "Residual Guaranty", strB: strResidualGuaranty, maxLength: maxChars)
    arry.append(line_ResidualGuaranty)
    arry.append("")
    
    let decPVOfRents: Decimal = aLease.getPVOfRents(discountRate: decDiscountRate)
    let strPVRents = formatAsTotal(decAmount: decPVOfRents, deNominator: aLease.amount.toDecimal())
    let line_PVRents = justifyText(strA: "PV of Rents", strB: strPVRents, maxLength: maxChars)
    arry.append(line_PVRents)
    
    let decPVOfResidualGuaranty = aLease.getPVOfResidualGuaranty(discountRate: decDiscountRate, residualGuaranty: decResidualGuaranty)
    let strPVResidualGuaranty = formatAsTotal(decAmount: decPVOfResidualGuaranty, deNominator: aLease.amount.toDecimal())
    let line_PVResidualGuaranty = justifyText(strA: "PV of Rsdl Gty", strB: strPVResidualGuaranty, maxLength: maxChars)
    arry.append(line_PVResidualGuaranty)
    
    let decFees: Decimal = aLease.fees?.totalCustomerPaidFees() ?? 0.0
    let strFees = formatAsTotal(decAmount: decFees, deNominator: aLease.amount.toDecimal())
    let line_Fees = justifyText(strA: "Customer Paid Fees", strB: strFees, maxLength: maxChars)
    arry.append(line_Fees)
    arry.append(totalsLine(maxChars: maxChars, lenOfTotalsLine: 13, lenOfPctLine: 7))
    
    let decTotalOblig: Decimal = decPVOfRents + decPVOfResidualGuaranty + decFees
    let strTotalOblig = formatAsTotal(decAmount: decTotalOblig, deNominator: aLease.amount.toDecimal())
    let line_TotalOblig = justifyText(strA: "Total Oblig PV", strB: strTotalOblig, maxLength: maxChars)
    arry.append(line_TotalOblig)
    arry.append("")
    
    return arry
}

func getEarlyBuyOut (aLease: Lease, isCustomerReport: Bool, maxCharsInLine: Int) -> [String] {
    var arry = [String]()

    let str_ln_Title = sectionTitle(strTitle: "Early Buy Out", aLeadFollow: "*", maxChars: maxCharsInLine)
    arry.append(str_ln_Title)

    let dateExercise: Date = aLease.earlyBuyOut!.exerciseDate
    let strExerciseDate: String = dateExercise.toStringDateShort(yrDigits: 2)
    let line_ExerciseDate = justifyText(strA: "Exercise Date", strB: strExerciseDate, maxLength: maxCharsInLine)
    arry.append(line_ExerciseDate)
    
    let intTerm: Int = aLease.getEBOTerm(exerDate: dateExercise)
    let strEBOTerm: String = intTerm.toString()
    let line_EBOTerm = justifyText(strA: "Term (mons)", strB: strEBOTerm, maxLength: maxCharsInLine)
    arry.append(line_EBOTerm)
    
    let decYield: Decimal = aLease.eboYield(aLease: aLease, rentDueIsPaid: aLease.earlyBuyOut!.rentDueIsPaid, withLesseeFee: false)
    let strYield: String = decYield.toPercent(3)
    let line_Yield: String = justifyText(strA: "EBO Yield", strB: strYield, maxLength: maxCharsInLine)
    arry.append(line_Yield)

    let decEBOAmount: Decimal = aLease.earlyBuyOut!.amount.toDecimal()
    let strEBOAmount: String = formatAsTotal(decAmount: decEBOAmount, deNominator: aLease.amount.toDecimal())
    let line_EBOAmount: String = justifyText(strA: "EBO Amount", strB: strEBOAmount, maxLength: maxCharsInLine)
    arry.append(line_EBOAmount)

    var decRentDue: Decimal = 0.00
    if aLease.earlyBuyOut!.rentDueIsPaid == true {
        decRentDue = aLease.getRentDue(exerDate: dateExercise, rentDueIsPaid: aLease.earlyBuyOut!.rentDueIsPaid).0.toDecimal()
    }
    let strTiming: String = aLease.getRentDue(exerDate: dateExercise, rentDueIsPaid: aLease.earlyBuyOut!.rentDueIsPaid).1.toString()
    let strRentDue: String = formatAsTotal(decAmount: decRentDue, deNominator: aLease.amount.toDecimal())
    let line_ArrearsRent = justifyText(strA: strTiming + " Rent Due", strB: strRentDue, maxLength: maxCharsInLine)
    arry.append(line_ArrearsRent)
    arry.append(totalsLine(maxChars: maxCharsInLine, lenOfTotalsLine: 13, lenOfPctLine: 7))

    let decTotalDue: Decimal = decEBOAmount + decRentDue
    let strTotalDue: String = formatAsTotal(decAmount: decTotalDue, deNominator: aLease.amount.toDecimal())
    let line_TotalDue: String = justifyText(strA: "Total Due", strB: strTotalDue, maxLength: maxCharsInLine)
    arry.append(line_TotalDue)
    arry.append("")

    return arry
}

func getTerminationInputs(aLease: Lease, maxCharsInLine: Int) -> [String] {
    var arry = [String]()
    
    let str_ln_Title = sectionTitle(strTitle: "Inputs For TValues", aLeadFollow: "*", maxChars: maxCharsInLine)
    arry.append(str_ln_Title)
    
    let decRateForRent = aLease.terminations?.discountRate_Rent ?? aLease.interestRate.toDecimal()
    let strRateForRent = decRateForRent.toPercent(2)
    let line_RateForRent = justifyText(strA: "Discount Rate for Rent", strB: strRateForRent, maxLength: maxCharsInLine)
    arry.append(line_RateForRent)
    
    let decRateForResidual = aLease.terminations?.discountRate_Residual ?? aLease.interestRate.toDecimal()
    let strRateForResidual = decRateForResidual.toPercent(2)
    let line_RateForResidual = justifyText(strA: "Discount Rate for Residual", strB: strRateForResidual, maxLength: maxCharsInLine)
    arry.append(line_RateForResidual)
    
    let decAddedResidual = aLease.terminations?.additionalResidual ?? 0.00
    let strAddedResidual = decAddedResidual.toPercent(2)
    let line_AddedResidual = justifyText(strA: "Additional Residual", strB: strAddedResidual, maxLength: maxCharsInLine)
    arry.append(line_AddedResidual)
    
    return arry
}

