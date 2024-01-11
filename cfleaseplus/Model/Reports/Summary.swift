//
//  Summary.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

func textForInvestorReport(aLease: Lease, currentFile: String, isLandscape: Bool) -> String {
    var maxChars = 42
    if isLandscape == true {
        maxChars = 50
    }
    
    let myLeaseReport: [[String]] = getInvestorSummary(aLease: aLease, currentFile: currentFile, maxCharsInLine: maxChars)

    var strLeaseSummaryText: String = ""
    for i in 0..<myLeaseReport.count {
        for j in 0..<myLeaseReport[i].count {
                strLeaseSummaryText = strLeaseSummaryText + myLeaseReport[i][j] + "\n"
        }
    }

    return strLeaseSummaryText
}

func textForCustomerReport(aLease: Lease, currentFile: String, includeRate: Bool, isLandscape: Bool) -> String {
    var maxChars = 42
    if isLandscape == true {
        maxChars = 50
    }
    
    let myLeaseReport: [[String]] = getCustomerSummary(aLease: aLease, currentFile: currentFile, includeRate: includeRate, isCustomerReport: true, maxCharsInLine: maxChars)

    var strLeaseSummaryText: String = ""
    for i in 0..<myLeaseReport.count {
        for j in 0..<myLeaseReport[i].count {
                strLeaseSummaryText = strLeaseSummaryText + myLeaseReport[i][j] + "\n"
        }
    }

    return strLeaseSummaryText
}

func textForLeaseStatistics(aLease: Lease, maxChars: Int) -> String {
    let myLeaseStats: [String] = getLeaseStats(aLease: aLease, maxChars: maxChars)
    
    var strLeaseStatsText: String = ""
    for i in 0..<myLeaseStats.count {
        strLeaseStatsText = strLeaseStatsText + myLeaseStats[i] + "\n"
    }
    
    return strLeaseStatsText
}


func textForCashflow(aLease: Lease, maxChars: Int) -> String {
    let myLeaseCashflow: [String] = getLeaseCashflows(aLease: aLease, maxCharsInLine: maxChars)

    var strLeaseCashflowText: String = ""
    for i in 0..<myLeaseCashflow.count {
        strLeaseCashflowText = strLeaseCashflowText + myLeaseCashflow[i] + "\n"
    }
    return strLeaseCashflowText
}

func textForPVOfRents(aLease: Lease, maxChars: Int) -> String {
    let myLeaseObligations: [String] = getLesseeObligations(aLease: aLease, maxChars: maxChars)

    var strLeaseObligationsText: String = ""
    for i in 0..<myLeaseObligations.count {
        strLeaseObligationsText = strLeaseObligationsText + myLeaseObligations[i] + "\n"
    }
    return strLeaseObligationsText

}

func textForEarlyBuyOut (aLease: Lease, isCustomerReport: Bool, maxChars: Int) -> String {
    let myEarlyBuyout: [String] = getEarlyBuyOut(aLease: aLease, isCustomerReport: isCustomerReport, maxCharsInLine: maxChars)

    var strEarlyBuyoutText: String = ""
    for i in 0..<myEarlyBuyout.count {
        strEarlyBuyoutText = strEarlyBuyoutText + myEarlyBuyout[i] + "\n"
    }
    return strEarlyBuyoutText
}

func textForBuySell (aLease: Lease, maxChars: Int) -> String {
    let myBuySell: [String] = getPurchaseDetails(aLease: aLease, maxChars: maxChars)

    var strBuySellText: String = ""
    for i in 0..<myBuySell.count {
        strBuySellText = strBuySellText + myBuySell[i] + "\n"
    }
    return strBuySellText
}

func textForTValueInputs (aLease: Lease, maxChars: Int) -> String {
    let myTValueInputs: [String] = getTerminationInputs(aLease: aLease, maxCharsInLine: maxChars)
    
    var strTValueInputsText: String = ""
    for i in 0..<myTValueInputs.count {
        strTValueInputsText = strTValueInputsText + myTValueInputs[i] + "\n"
    }
    return strTValueInputsText
}

func textForLeaseBalance(aLease: Lease, currentFile: String, isPad: Bool, isLandscape: Bool) -> String {
    var mySummary = [String]()
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: isLandscape)
    
    let title: [String] = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        mySummary.append(title[x])
    }
    
    let str_ln_Title = sectionTitle(strTitle: "Outstanding Balance Quote", aLeadFollow: "_", maxChars: maxChars)
    mySummary.append(str_ln_Title)
    mySummary.append("")
    
    let modDate: Date = stringToDate(strAskDate: modificationDate)
    let str_ln_ModDate = justifyText(strA: "Modification Date", strB: modificationDate, maxLength: maxChars)
    mySummary.append(str_ln_ModDate)
    
    let decBalance: Decimal = getPrincipalBalance(aLease: aLease, askDate: modDate)
    let strBalance: String = decBalance.toCurrency(false)
    let str_ln_Balance: String = justifyText(strA: "Outstanding Principal", strB: strBalance, maxLength: maxChars)
    mySummary.append(str_ln_Balance)
    
    let lastPaymentDate: Date = getLastPaymentDateBeforeMod(aLease: aLease, modDate: modDate)
    let strPaymentDate = dateToString(dateAsk: lastPaymentDate)
    let str_ln_LastPaymentDate = justifyText(strA: "Last Payment Date", strB: strPaymentDate, maxLength: maxChars)
    mySummary.append(str_ln_LastPaymentDate)
    
    let days: Int = dayCount(aDate1: lastPaymentDate, aDate2: modDate, aDaycount: aLease.interestCalcMethod)
    let str_ln_Days = justifyText(strA: "No. of Days", strB: days.toString(), maxLength: maxChars)
    mySummary.append(str_ln_Days)
    
    let dailyInterest: Decimal = getPerDiem(aLease: aLease, askDate: modDate)
    let str_ln_PerDiem = justifyText(strA: "Daily Interest", strB: dailyInterest.toCurrency(false), maxLength: maxChars)
    mySummary.append(str_ln_PerDiem)
    
    let decAccruedInterest: Decimal = Decimal(days) * dailyInterest
    let str_ln_Interest: String = justifyText(strA: "Accrued Interest", strB: decAccruedInterest.toCurrency(false), maxLength: maxChars)
    mySummary.append(str_ln_Interest)
    
    let decTotalOutStanding = decBalance + decAccruedInterest
    let str_ln_TotalOut = justifyText(strA: "Total Outstanding", strB: decTotalOutStanding.toCurrency(false), maxLength: maxChars)
    mySummary.append(str_ln_TotalOut)
    
    var strSummary: String = ""
    for x in 0..<mySummary.count {
        strSummary = strSummary + mySummary[x] + "\n"
    }
    
    return strSummary
}
