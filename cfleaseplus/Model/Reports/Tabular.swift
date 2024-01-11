//
//  Tabular.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

// Mark: Amortization
func textForOneAmortizations(aAmount: Decimal, aAmortizations: Amortizations, interestRate: String, dayCountMethod: DayCountMethod, currentFile: String, isPad: Bool, isLandscape: Bool) -> String {
    var arry = [String]()
    
    if isPad == true {
        arry = getTextForAmortizationInPortrait(aAmount: aAmount, aAmortizations: aAmortizations, interestRate: interestRate, dayCountMethod: dayCountMethod, currentFile: currentFile, isPad: isPad)
    } else if isLandscape == true {
        arry = getTextForAmortizationInLandscape(aAmount: aAmount, aAmortizations: aAmortizations, interestRate: interestRate, dayCountMethod: dayCountMethod, currentFile: currentFile, isPad: isPad)
    } else {
        arry = getTextForAmortizationInPortrait(aAmount: aAmount, aAmortizations: aAmortizations, interestRate: interestRate, dayCountMethod: dayCountMethod, currentFile: currentFile, isPad: isPad)
    }
    
    var amortizationReport: String = ""
    for i in 0...arry.count - 1 {
        amortizationReport = amortizationReport + arry[i] + "\n"
    }
    return amortizationReport
}

func getTextForAmortizationInPortrait(aAmount: Decimal, aAmortizations: Amortizations, interestRate: String, dayCountMethod: DayCountMethod, currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let fiveColumns: [Int] = [4, 10, 9, 9, 10]
    let indentSmall: Int = 0
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: false)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }

    let strInterestRate: String = interestRate.toDecimal().toPercent(3)
    let str_Line_InterestRate: String = justifyText(strA: "Interest Rate:", strB: strInterestRate, maxLength: maxChars)
    arry.append(str_Line_InterestRate)
    
    let strDayCount: String = dayCountMethod.toString()
    let str_Line_DayCount: String = justifyText(strA: "Day Count Method", strB: strDayCount, maxLength: maxChars)
    arry.append(str_Line_DayCount)
    
    let strBasis: String = aAmount.toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)

    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strPayment: String = justifyColumn(cellData: "Payment", leftJustify: false, cellWidth: fiveColumns[2])
    var strInterest: String = justifyColumn(cellData: "Interest", leftJustify: false, cellWidth: fiveColumns[3])
    var strEndBalance: String = justifyColumn(cellData: "Balance", leftJustify: false, cellWidth: fiveColumns[4])
    let line_Header = strNo + strDate + strPayment + strInterest + strEndBalance
    arry.append(line_Header)

    let decAmount: Decimal = aAmount
    for x in 0..<aAmortizations.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: true, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: aAmortizations.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fiveColumns[1])
        let decPayment: Decimal = aAmortizations.items[x].payment / decAmount * 100.0
        strPayment = justifyColumn(cellData: decPayment.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
        let decInterest: Decimal = aAmortizations.items[x].interest / decAmount * 100.0
        strInterest = justifyColumn(cellData: decInterest.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
        let decBalance: Decimal = aAmortizations.items[x].endBalance / decAmount * 100.0
        strEndBalance = justifyColumn(cellData: decBalance.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
        let line_BodyRow = strNo + strDate + strPayment + strInterest  + strEndBalance
        arry.append(line_BodyRow)
    }
    arry.append(emptyLine)

    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    let decTotalPayments: Decimal = aAmortizations.getTotalPayments() / decAmount * 100.0
    let strTotalPayments: String = justifyColumn(cellData: decTotalPayments.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
    let decTotalInterest: Decimal = aAmortizations.getTotalInterest() / decAmount * 100.0
    let strTotalInterest: String = justifyColumn(cellData: decTotalInterest.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
    strEndBalance = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[4])
    
    let line_TotalsRow = strNo + strDate + strTotalPayments + strTotalInterest + strEndBalance
    arry.append(line_TotalsRow)
    
    return arry
}

func getTextForAmortizationInLandscape(aAmount: Decimal, aAmortizations: Amortizations, interestRate: String, dayCountMethod: DayCountMethod, currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = ""
    let fiveColumns: [Int] = [6,14,18,18,18]
    let indentSmall: Int = 0
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: true)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    
    let strInterestRate: String = interestRate.toDecimal().toPercent(3)
    let str_Line_InterestRate: String = justifyText(strA: "Interest Rate:", strB: strInterestRate, maxLength: maxChars)
    arry.append(str_Line_InterestRate)
    
    let strDayCount: String = dayCountMethod.toString()
    let str_Line_DayCount: String = justifyText(strA: "Day Count Method", strB: strDayCount, maxLength: maxChars)
    arry.append(str_Line_DayCount)
    arry.append(emptyLine)

    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strPayment: String = justifyColumn(cellData: "Payment", leftJustify: false, cellWidth: fiveColumns[2])
    var strInterest: String = justifyColumn(cellData: "Interest", leftJustify: false, cellWidth: fiveColumns[3])
    var strEndBalance: String = justifyColumn(cellData: "Balance", leftJustify: false, cellWidth: fiveColumns[4])
    let line_Header = strNo + strDate + strPayment + strInterest + strEndBalance
    arry.append(line_Header)
    
    for x in 0..<aAmortizations.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: true, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: aAmortizations.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fiveColumns[1])
        let decPayment: Decimal = aAmortizations.items[x].payment
        strPayment = justifyColumn(cellData: decPayment.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[2])
        let decInterest: Decimal = aAmortizations.items[x].interest
        strInterest = justifyColumn(cellData: decInterest.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[3])
        let decBalance: Decimal = aAmortizations.items[x].endBalance
        strEndBalance = justifyColumn(cellData: decBalance.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[4])
        let line_BodyRow = strNo + strDate + strPayment + strInterest  + strEndBalance
        arry.append(line_BodyRow)
    }
    arry.append(emptyLine)

    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    let decTotalPayments: Decimal = aAmortizations.getTotalPayments()
    let strTotalPayments: String = justifyColumn(cellData: decTotalPayments.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[2])
    let decTotalInterest: Decimal = aAmortizations.getTotalInterest()
    let strTotalInterest: String = justifyColumn(cellData: decTotalInterest.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[3])
    strEndBalance = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[4])
    
    let line_TotalsRow = strNo + strDate + strTotalPayments + strTotalInterest + strEndBalance
    arry.append(line_TotalsRow)
    
    return arry
}

func csvForOneAmortization(aAmount: Decimal, aAmortizations: Amortizations, interestRate: String, daycountMethod: DayCountMethod, reportTitle: String) -> String {
    //Title Row
    let strHeaderRow: String = csvAmortRow(colOne: "", colTwo: "", colThree: reportTitle, colFour: "", colFive: "", colSix: "")
    let strInterestRate: String = csvAmortRow(colOne: "Annual Rate:", colTwo: aAmortizations.items[0].annualRate.toString(decPlaces: 6), colThree: "", colFour: "", colFive: "", colSix: "")
    let strDayCount: String = csvAmortRow(colOne: "Day Count:", colTwo: daycountMethod.toString(), colThree: "", colFour: "", colFive: "", colSix: "")
    let strTitleBlock: String = strHeaderRow + strInterestRate + strDayCount
    
    //Table Header Row
    var strNo = "No."
    var strDate = "Date"
    var strInterest = "Interest Expense"
    var strPayment = "Payment"
    var strPrincipal = "Principal Paid"
    var strEnd = "Ending Balance"
    
    let strTableHeaderRow = csvAmortRow(colOne: strNo, colTwo: strDate, colThree: strInterest, colFour: strPayment, colFive: strPrincipal, colSix: strEnd)
    
    //Amort Table Rows
    var strData: String = ""
    for x in 0..<aAmortizations.items.count {
        strNo = (x + 1).toString()
        strDate = aAmortizations.items[x].dueDate.toStringDateShort(yrDigits: 2)
        strInterest = aAmortizations.items[x].interest.toString(decPlaces: 2)
        strPayment = aAmortizations.items[x].payment.toString(decPlaces: 2)
        strPrincipal = aAmortizations.items[x].principal.toString(decPlaces: 2)
        strEnd = aAmortizations.items[x].endBalance.toString(decPlaces: 2)
        strData = strData + csvAmortRow(colOne: strNo, colTwo: strDate, colThree: strInterest, colFour: strPayment, colFive: strPrincipal, colSix: strEnd)
    }
    
    //Totals Row
    let strTotals: String = csvAmortRow(colOne: "", colTwo: "Totals" , colThree: aAmortizations.getTotalInterest().toString(decPlaces: 2) , colFour:aAmortizations.getTotalPayments().toString(decPlaces: 2), colFive: aAmortizations.getTotalPrincipal().toString(decPlaces: 2), colSix: "")
    
    return csvEmptyRow() + strTitleBlock + csvEmptyRow() +  strTableHeaderRow +  strData + csvEmptyRow() + strTotals
}

func csvAmortRow(colOne: String, colTwo: String, colThree: String, colFour: String, colFive: String, colSix: String) -> String {
    let strRow: String = colOne + "," + colTwo + "," + colThree + "," + colFour + "," + colFive + "," + colSix + "\n"

    return strRow
}

func csvEmptyRow() -> String {
    return csvAmortRow(colOne: "", colTwo: "", colThree: "", colFour: "", colFive: "", colSix: "")
}


// Mark: Cashlow
func textForOneCashflow(aAmount: Decimal, aCFs: Cashflows,  currentFile: String, isPad: Bool, isLandscape: Bool) -> String {
    var arry = [String]()
    
    if isPad == true {
        arry = getTextForCashflowInPortrait(aAmount: aAmount, aCFs: aCFs, currentFile: currentFile, isPad: isPad)
    } else if isLandscape == true {
        arry = getTextForCashflowInLandscape(aAmount: aAmount, aCFs: aCFs, currentFile: currentFile, isPad: isPad)
    } else {
        arry = getTextForCashflowInPortrait(aAmount: aAmount, aCFs: aCFs, currentFile: currentFile, isPad: isPad)
    }

    var myCashflowRpt: String = ""
    for i in 0...arry.count - 1 {
        myCashflowRpt = myCashflowRpt + arry[i] + "\n"
    }
    return myCashflowRpt
}

func getTextForCashflowInPortrait(aAmount: Decimal, aCFs: Cashflows,  currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let myCFs: Cashflows = aCFs
    let indent = 0
    let emptyLine: String = "\n"
    let fourColumns: [Int] = [4, 10, 14, 14]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: false)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    let strBasis: String = aAmount.toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: buffer(spaces: indent) + "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)

    let strNo: String = justifyColumn(cellData: buffer(spaces: indent) + "No.", leftJustify: false, cellWidth: fourColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fourColumns[1])
    var strAmount: String = justifyColumn(cellData: "Amount", leftJustify: false, cellWidth: fourColumns[2])
    var strRunTotal : String = justifyColumn(cellData: "Run Total", leftJustify: false, cellWidth: fourColumns[3])

    let line_Headers: String =  strNo + strDate + strAmount + strRunTotal
    arry.append(line_Headers)

    let decAmount: Decimal = aAmount
    var decRunTotal: Decimal = 0.0
    for x in 0..<myCFs.items.count {
        let strRow: String = justifyColumn(cellData: buffer(spaces: indent) + (x + 1).toString(), leftJustify: false, cellWidth: fourColumns[0])
        strDate = justifyColumn(cellData: myCFs.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fourColumns[1])
        let decCF = myCFs.items[x].amount / decAmount * 100.0
        strAmount = justifyColumn(cellData: decCF.toString(decPlaces: 4), leftJustify: false, cellWidth: fourColumns[2])
        decRunTotal = decRunTotal + decCF
        strRunTotal = justifyColumn(cellData: decRunTotal.toString(decPlaces: 4), leftJustify: false, cellWidth: fourColumns[3])
        let rowData = strRow + strDate + strAmount + strRunTotal
        arry.append(rowData)
    }
    
    return arry
}


func getTextForCashflowInLandscape(aAmount: Decimal, aCFs: Cashflows,  currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let myCFs: Cashflows = aCFs
    let indent = 0
    let emptyLine: String = "\n"
    let fourColumns: [Int] = [8, 16, 22, 22]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: true)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    let strBasis: String = aAmount.toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: buffer(spaces: indent) + "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)

    let strNo: String = justifyColumn(cellData: buffer(spaces: indent) + "No.", leftJustify: false, cellWidth: fourColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fourColumns[1])
    var strAmount: String = justifyColumn(cellData: "Amount", leftJustify: false, cellWidth: fourColumns[2])
    var strRunTotal : String = justifyColumn(cellData: "Run Total", leftJustify: false, cellWidth: fourColumns[3])

    let line_Headers: String =  strNo + strDate + strAmount + strRunTotal
    arry.append(line_Headers)


    var decRunTotal: Decimal = 0.0
    for x in 0..<myCFs.items.count {
        let strRow: String = justifyColumn(cellData: buffer(spaces: indent) + (x + 1).toString(), leftJustify: false, cellWidth: fourColumns[0])
        strDate = justifyColumn(cellData: myCFs.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fourColumns[1])
        let decCF = myCFs.items[x].amount
        strAmount = justifyColumn(cellData: decCF.toCurrency(false), leftJustify: false, cellWidth: fourColumns[2])
        decRunTotal = decRunTotal + decCF
        strRunTotal = justifyColumn(cellData: decRunTotal.toCurrency(false), leftJustify: false, cellWidth: fourColumns[3])
        let rowData = strRow + strDate + strAmount + strRunTotal
        arry.append(rowData)
    }
    
    return arry
}

func textForDayCount(aLease: Lease, currentFile: String, isPad: Bool, isLandscape: Bool) -> String {
    var arry = [String]()
    let emptyLine: String = "\n"
    
    if isPad == true {
        arry = getTextForDayCountinPortrait(aLease: aLease, currentFile: currentFile, isPad: isPad)
    } else if isLandscape == true {
        arry = getTextForDayCountInLandscape(aLease: aLease, currentFile: currentFile, isPad: isPad)
    } else {
        arry = getTextForDayCountinPortrait(aLease: aLease, currentFile: currentFile, isPad: isPad)
    }
    
    var dayCountReport: String = ""
    for i in 0...arry.count - 1 {
        dayCountReport = dayCountReport + arry[i] + emptyLine
    }
    return dayCountReport
}

func getTextForDayCountInLandscape (aLease: Lease, currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [6, 18, 16, 16, 18]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: true)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    
    let strDayCount: String = aLease.interestCalcMethod.toString()
    let str_Line_DayCount: String = justifyText(strA: buffer(spaces: indentSmall) + "Day Count Method", strB: strDayCount, maxLength: maxChars)
    arry.append(str_Line_DayCount)
    
    let strEOM: String = aLease.endOfMonthRule.toString()
    let str_Line_EOMRule: String = justifyText(strA: buffer(spaces: indentSmall) + "End of Month Rule", strB: strEOM, maxLength: maxChars)
    arry.append(str_Line_EOMRule)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strActual: String = justifyColumn(cellData: "Actual", leftJustify: false, cellWidth: fiveColumns[2])
    var strCounted: String = justifyColumn(cellData: "Counted", leftJustify: false, cellWidth: fiveColumns[3])
    var strInYear: String = justifyColumn(cellData: "In Year", leftJustify: false, cellWidth: fiveColumns[4])
    var row_Data: String = strNo + strDate + strActual + strCounted + strInYear
    arry.append(row_Data)
    
    var runTotalActual: Int = 0
    var runTotalCounted: Int = 0
    let rentCFs: Cashflows = Cashflows(aLease: aLease, returnType: .payment)
    for x in 0..<rentCFs.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: rentCFs.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fiveColumns[1])
        var actualDays: Int = 0
        var countedDays: Int = 0
        var yearDays: Double = 0.0
        if x > 0 {
            actualDays = daysBetween(start: rentCFs.items[x - 1].dueDate, end: rentCFs.items[x].dueDate)
            countedDays = dayCount(aDate1: rentCFs.items[x - 1].dueDate, aDate2: rentCFs.items[x].dueDate, aDaycount: aLease.interestCalcMethod)
            yearDays = daysInYear(aDate1: rentCFs.items[x - 1].dueDate, aDate2: rentCFs.items[x].dueDate, aDayCountMethod: aLease.interestCalcMethod)
        }
        strActual = justifyColumn(cellData: actualDays.toString(), leftJustify: false, cellWidth: fiveColumns[2])
        strCounted = justifyColumn(cellData: countedDays.toString(), leftJustify: false, cellWidth: fiveColumns[3])
        strInYear = justifyColumn(cellData: Decimal(yearDays).toString(decPlaces: 2), leftJustify: false, cellWidth: fiveColumns[4])
        runTotalActual = runTotalActual + actualDays
        runTotalCounted = runTotalCounted + countedDays
        row_Data = strNo + strDate + strActual + strCounted + strInYear
        arry.append(row_Data)
    }
    
    arry.append(emptyLine)
    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    strActual = justifyColumn(cellData: runTotalActual.withCommas(), leftJustify: false, cellWidth: fiveColumns[2])
    strCounted = justifyColumn(cellData: runTotalCounted.withCommas(), leftJustify: false, cellWidth: fiveColumns[3])
    strInYear = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[4])
    row_Data = strNo + strDate + strActual + strCounted + strInYear
    arry.append(row_Data)
    
    
    
    return arry
}

func getTextForDayCountinPortrait(aLease: Lease, currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [4, 10, 9, 9, 10]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: false)
    
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    
    let strDayCount: String = aLease.interestCalcMethod.toString()
    let str_Line_DayCount: String = justifyText(strA: buffer(spaces: indentSmall) + "Day Count Method", strB: strDayCount, maxLength: maxChars)
    arry.append(str_Line_DayCount)
    
    let strEOM: String = aLease.endOfMonthRule.toString()
    let str_Line_EOMRule: String = justifyText(strA: buffer(spaces: indentSmall) + "End of Month Rule", strB: strEOM, maxLength: maxChars)
    arry.append(str_Line_EOMRule)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strActual: String = justifyColumn(cellData: "Actual", leftJustify: false, cellWidth: fiveColumns[2])
    var strCounted: String = justifyColumn(cellData: "Counted", leftJustify: false, cellWidth: fiveColumns[3])
    var strInYear: String = justifyColumn(cellData: "In Year", leftJustify: false, cellWidth: fiveColumns[4])
    var row_Data: String = strNo + strDate + strActual + strCounted + strInYear
    arry.append(row_Data)
    
    var runTotalActual: Int = 0
    var runTotalCounted: Int = 0
    let rentCFs: Cashflows = Cashflows(aLease: aLease, returnType: .payment)
    for x in 0..<rentCFs.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: rentCFs.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fiveColumns[1])
        var actualDays: Int = 0
        var countedDays: Int = 0
        var yearDays: Double = 0.0
        if x > 0 {
            actualDays = daysBetween(start: rentCFs.items[x - 1].dueDate, end: rentCFs.items[x].dueDate)
            countedDays = dayCount(aDate1: rentCFs.items[x - 1].dueDate, aDate2: rentCFs.items[x].dueDate, aDaycount: aLease.interestCalcMethod)
            yearDays = daysInYear(aDate1: rentCFs.items[x - 1].dueDate, aDate2: rentCFs.items[x].dueDate, aDayCountMethod: aLease.interestCalcMethod)
        }
        strActual = justifyColumn(cellData: actualDays.toString(), leftJustify: false, cellWidth: fiveColumns[2])
        strCounted = justifyColumn(cellData: countedDays.toString(), leftJustify: false, cellWidth: fiveColumns[3])
        strInYear = justifyColumn(cellData: Decimal(yearDays).toString(decPlaces: 2), leftJustify: false, cellWidth: fiveColumns[4])
        runTotalActual = runTotalActual + actualDays
        runTotalCounted = runTotalCounted + countedDays
        row_Data = strNo + strDate + strActual + strCounted + strInYear
        arry.append(row_Data)
    }
    
    arry.append(emptyLine)
    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    strActual = justifyColumn(cellData: runTotalActual.withCommas(), leftJustify: false, cellWidth: fiveColumns[2])
    strCounted = justifyColumn(cellData: runTotalCounted.withCommas(), leftJustify: false, cellWidth: fiveColumns[3])
    strInYear = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[4])
    row_Data = strNo + strDate + strActual + strCounted + strInYear
    arry.append(row_Data)
    
    
    return arry
}

func textForOneGroups (aGroups: [Group], columns: Int = 7, tblWidth: Int = 74) -> String {
    var arry = [String]()
    let myGroups: [Group] = aGroups

    var strRow: String = justifyColumn(cellData: "Row", leftJustify: false, cellWidth: 4)
    var strNo: String = justifyColumn(cellData: "Num", leftJustify: false, cellWidth: 4)
    var strType: String = justifyColumn(cellData: "Type", leftJustify: false, cellWidth: 10)
    var strFrom: String = justifyColumn(cellData: "From", leftJustify: false, cellWidth: 14)
    var strTo: String = justifyColumn(cellData: "To", leftJustify: false, cellWidth: 14)
    var strTiming: String = justifyColumn(cellData: "Timing", leftJustify: false, cellWidth: 14)
    var strAmount: String = justifyColumn(cellData: "Amount", leftJustify: false, cellWidth: 14)
    let line_Headers: String = strRow + strNo + strType + strFrom + strTo + strTiming + strAmount
    arry.append(line_Headers)

    for x in myGroups.indices {
        strRow = justifyColumn(cellData: (x + 1).toString(), leftJustify: false, cellWidth: 4)
        strNo = justifyColumn(cellData: myGroups[x].noOfPayments.toString(), leftJustify: false, cellWidth: 4)
        strType = justifyColumn(cellData: myGroups[x].type.toString(), leftJustify: false, cellWidth: 10)
        strFrom = justifyColumn(cellData: myGroups[x].startDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: 14)
        strTo = justifyColumn(cellData: myGroups[x].endDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: 14)
        strTiming = justifyColumn(cellData: myGroups[x].timing.toString(), leftJustify: false, cellWidth: 14)
        strAmount = justifyColumn(cellData: myGroups[x].amount.toDecimal().toCurrency(false), leftJustify: false, cellWidth: 14)
        let rowData: String = strRow + strNo + strType + strFrom + strTo + strTiming + strAmount
        arry.append(rowData)
    }

    var strReport: String = ""
    for i in 0...arry.count - 1 {
        strReport = strReport + arry[i] + "\n"
    }

    return strReport
}


func textForPVOfRentProof(aLease: Lease, currentFile: String, isLessor: Bool, isPad: Bool, isLandscape: Bool) -> String {
    var arry = [String]()
    let emptyLine: String = "\n"
    
    if isPad == true {
        arry = getTextForPVOfRentProofInPortrait(aLease: aLease, currentFile: currentFile, isLessor: isLessor, isPad: isPad)
    } else if isLandscape == true {
        arry = getTextForPVOfRentProofInLandscape(aLease: aLease, currentFile: currentFile, isLessor: isLessor, isPad: isPad)
    } else {
        arry = getTextForPVOfRentProofInPortrait(aLease: aLease, currentFile: currentFile, isLessor: isLessor, isPad: isPad)
    }
    
    var pvProofReport: String = ""
    for i in 0..<arry.count {
        pvProofReport = pvProofReport + arry[i] + emptyLine
    }
    arry.removeAll()
    
    return pvProofReport
}


func getTextForPVOfRentProofInLandscape(aLease: Lease, currentFile: String, isLessor: Bool, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [6,14,18,18,18]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: true)
    let minRents: Cashflows = getLesseeMinimumRents(aLease: aLease)
    
    arry.append(getLineForAcctg(isLessor: isLessor, maxChars: maxChars))
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }

    var discountRate: String = aLease.leaseObligations!.discountRate
    var strDiscountRate: String = "Discount Rate"
    if isLessor == true {
        discountRate = aLease.implicitRate().toString(decPlaces: 6)
        strDiscountRate = "Implicit Rate"
    }
    let line_DiscountRate = justifyText(strA: strDiscountRate, strB: discountRate.toDecimal().toPercent(4), maxLength: maxChars)
    arry.append(line_DiscountRate)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strMinRents: String = justifyColumn(cellData: "MinRent", leftJustify: false, cellWidth: fiveColumns[2])
    var strPVOf1: String = justifyColumn(cellData: "PVFactor", leftJustify: false, cellWidth: fiveColumns[3])
    var strPVMinRents: String = justifyColumn(cellData: "RentPV", leftJustify: false, cellWidth: fiveColumns[4])
    var line_Data = strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
    arry.append(line_Data)
    
    var decPrevFactor: Decimal = 1.0
    var decDailyInterestRate: Decimal = 0.0
    var intDaysInPeriod: Int = 0
    var decRunTotalMinRents: Decimal = 0.0
    var decRunTotalPV: Decimal = 0.0
    for x in 0..<minRents.items.count {
        let decMinRents: Decimal = minRents.items[x].amount
        decRunTotalMinRents = decRunTotalMinRents + decMinRents
        if x > 0 {
            decDailyInterestRate = dailyRate(iRate: discountRate.toDecimal(), aDate1: minRents.items[x - 1].dueDate, aDate2: minRents.items[x].dueDate, aDayCountMethod: aLease.interestCalcMethod)
            intDaysInPeriod = dayCount(aDate1: minRents.items[x - 1].dueDate, aDate2: minRents.items[x].dueDate, aDaycount: aLease.interestCalcMethod)
        }
        let currFactor: Decimal = decPrevFactor / (1 + decDailyInterestRate * Decimal(intDaysInPeriod))
        let adjMinRents: Decimal = decMinRents * currFactor
        decRunTotalPV = decRunTotalPV + adjMinRents
        decPrevFactor = currFactor
        
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: minRents.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fiveColumns[1])
        strMinRents = justifyColumn(cellData: decMinRents.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[2])
        strPVOf1 = justifyColumn(cellData: currFactor.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
        strPVMinRents = justifyColumn(cellData: adjMinRents.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[4])
        line_Data = strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
        arry.append(line_Data)
    }
    arry.append(emptyLine)
    
    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    strMinRents = justifyColumn(cellData: decRunTotalMinRents.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[2])
    strPVOf1 = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[3])
    strPVMinRents = justifyColumn(cellData: decRunTotalPV.toCurrency(false), leftJustify: false, cellWidth: fiveColumns[4])
    line_Data =  strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
    arry.append(line_Data)
    
    return arry
}

func getLineForAcctg(isLessor: Bool, maxChars: Int) -> String {
    var rptType:String = "Lessee"
    if isLessor == true {
        rptType = "Lessor"
    }
    let line_Acctg: String = justifyText(strA: "PV Test For", strB: rptType, maxLength: maxChars)
    
    return line_Acctg
}

func getLesseeMinimumRents(aLease: Lease) -> Cashflows {
    let lesseePaidFeesCFs: Cashflows = Cashflows(aFees: aLease.fees!, aFeeType: .customerPaid)
    var rentCFs: Cashflows = Cashflows(aLease: aLease, returnType: .payment)
    rentCFs = rentCFs.addCashflow(aCFs: lesseePaidFeesCFs)
    let residualCFS: Cashflows = Cashflows(aLease: aLease, returnType: .residual)
    residualCFS.items[residualCFS.items.count - 1].amount = aLease.leaseObligations!.residualGuarantyAmount.toDecimal()

    rentCFs.consolidateCashflows()
    let myMinimumRents: Cashflows = Cashflows().netTwoCashflows(cfsOne: rentCFs, cfsTwo: residualCFS)
    
    return myMinimumRents
}

func getTextForPVOfRentProofInPortrait(aLease: Lease, currentFile: String, isLessor: Bool, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [4, 10, 9, 9, 10]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: false)
    let minRents: Cashflows = getLesseeMinimumRents(aLease: aLease)
    
    arry.append(getLineForAcctg(isLessor: isLessor, maxChars: maxChars))
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    
    let strBasis: String = aLease.amount.toDecimal().toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    
    var discountRate: String = aLease.leaseObligations!.discountRate
    var strDiscountRate: String = "Discount Rate"
    if isLessor == true {
        discountRate = aLease.implicitRate().toString(decPlaces: 6)
        strDiscountRate = "Implicit Rate"
    }
    let line_DiscountRate = justifyText(strA: strDiscountRate, strB: discountRate.toDecimal().toPercent(4), maxLength: maxChars)
    arry.append(line_DiscountRate)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strMinRents: String = justifyColumn(cellData: "MinRent", leftJustify: false, cellWidth: fiveColumns[2])
    var strPVOf1: String = justifyColumn(cellData: "PVFactor", leftJustify: false, cellWidth: fiveColumns[3])
    var strPVMinRents: String = justifyColumn(cellData: "RentPV", leftJustify: false, cellWidth: fiveColumns[4])
    var line_Data = strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
    arry.append(line_Data)
    
    let decAmount: Decimal = aLease.amount.toDecimal()
    var decPrevFactor: Decimal = 1.0
    var decDailyInterestRate: Decimal = 0.0
    var intDaysInPeriod: Int = 0
    var decRunTotalMinRents: Decimal = 0.0
    var decRunTotalPV: Decimal = 0.0
    for x in 0..<minRents.items.count {
        let decMinRents: Decimal = minRents.items[x].amount / decAmount * 100.0
        decRunTotalMinRents = decRunTotalMinRents + decMinRents
        if x > 0 {
            decDailyInterestRate = dailyRate(iRate: discountRate.toDecimal(), aDate1: minRents.items[x - 1].dueDate, aDate2: minRents.items[x].dueDate, aDayCountMethod: aLease.interestCalcMethod)
            intDaysInPeriod = dayCount(aDate1: minRents.items[x - 1].dueDate, aDate2: minRents.items[x].dueDate, aDaycount: aLease.interestCalcMethod)
        }
        let currFactor: Decimal = decPrevFactor / (1 + decDailyInterestRate * Decimal(intDaysInPeriod))
        let adjMinRents: Decimal = decMinRents * currFactor
        decRunTotalPV = decRunTotalPV + adjMinRents
        decPrevFactor = currFactor
        
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: minRents.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fiveColumns[1])
        strMinRents = justifyColumn(cellData: decMinRents.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
        strPVOf1 = justifyColumn(cellData: currFactor.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
        strPVMinRents = justifyColumn(cellData: adjMinRents.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
        line_Data = strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
        arry.append(line_Data)
    }
    arry.append(emptyLine)
    
    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    strMinRents = justifyColumn(cellData: decRunTotalMinRents.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
    strPVOf1 = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[3])
    strPVMinRents = justifyColumn(cellData: decRunTotalPV.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
    line_Data =  strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
    arry.append(line_Data)
    
    return arry
}

func textForTerminationValues (aLease: Lease, inLieuRent: Bool, includeParValues: Bool, currentFile: String, isPad: Bool, isLandscape: Bool) -> String {
    var arry = [String]()
    
    if isPad == true {
        arry = getTextForTerminationValuesInPortrait(aLease: aLease, inLieuRent: inLieuRent, includeParValues: includeParValues, currentFile: currentFile, isPad: isPad, isLandscape: isLandscape)
    } else if isLandscape == true {
        arry = getTextForTerminationValuesInLandscape(aLease: aLease, inLieuRent: inLieuRent, includeParValues: includeParValues, currentFile: currentFile, isPad: isPad, isLandscape: isLandscape)
    } else {
        arry = getTextForTerminationValuesInPortrait(aLease: aLease, inLieuRent: inLieuRent, includeParValues: includeParValues, currentFile: currentFile, isPad: isPad, isLandscape: isLandscape)
    }
   
    var terminationValuesReport: String = ""
    for i in 0..<arry.count {
        terminationValuesReport = terminationValuesReport + arry[i] + "\n"
    }
    arry.removeAll()
    
    return terminationValuesReport
}

func getTextForTerminationValuesInLandscape (aLease: Lease, inLieuRent: Bool, includeParValues: Bool, currentFile: String, isPad: Bool, isLandscape: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [6, 16, 16, 16, 18]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: isLandscape)
    
    let rentDR = aLease.terminations?.discountRate_Rent ?? aLease.interestRate.toDecimal()
    let residualDR = aLease.terminations?.discountRate_Residual ?? aLease.interestRate.toDecimal()
    let additional = aLease.terminations?.additionalResidual ?? 0.00
    
    let myTValues:Cashflows = aLease.terminationValues(rateForRent: rentDR, rateForResidual: residualDR, adder: additional, inLieuOfRent: inLieuRent)
    let myParValues = aLease.parValues2(inLieuOfRent: inLieuRent)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    let strBasis: String = aLease.amount.toDecimal().toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strTValue: String = justifyColumn(cellData: "TValue", leftJustify: false, cellWidth: fiveColumns[2])
    var parValueLead = "Par Value"
    var coverageLead = "Difference"
    if includeParValues == false {
        parValueLead = ""
        coverageLead = ""
    }
    var strParValue: String = justifyColumn(cellData: parValueLead, leftJustify: false, cellWidth: fiveColumns[3])
    var strCoverage: String = justifyColumn(cellData: coverageLead, leftJustify: false, cellWidth: fiveColumns[4])
    let line_Header = strNo + strDate + strTValue + strParValue + strCoverage
    arry.append(line_Header)

    for x in 0..<myTValues.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: myTValues.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fiveColumns[1])
        let decTValue = myTValues.items[x].amount * 100.0
        strTValue = justifyColumn(cellData: decTValue.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
        let decParValue = myParValues.items[x].amount * 100.0
        strParValue = justifyColumn(cellData: decParValue.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
        let decCoverage = decTValue - decParValue
        strCoverage = justifyColumn(cellData: decCoverage.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
        if includeParValues == false {
            strParValue = ""
            strCoverage = ""
        }
        let line_BodyRow = strNo + strDate + strTValue + strParValue  + strCoverage
        arry.append(line_BodyRow)
    }
    arry.append(emptyLine)
    
    return arry
}

func getTextForTerminationValuesInPortrait(aLease: Lease, inLieuRent: Bool, includeParValues: Bool, currentFile: String, isPad: Bool, isLandscape: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [4, 9, 10, 10, 9]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: isLandscape)
    
    let rentDR = aLease.terminations?.discountRate_Rent ?? aLease.interestRate.toDecimal()
    let residualDR = aLease.terminations?.discountRate_Residual ?? aLease.interestRate.toDecimal()
    let additional = aLease.terminations?.additionalResidual ?? 0.00
    
    let myTValues:Cashflows = aLease.terminationValues(rateForRent: rentDR, rateForResidual: residualDR, adder: additional, inLieuOfRent: inLieuRent)
    let myParValues = aLease.parValues2(inLieuOfRent: inLieuRent)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    let strBasis: String = aLease.amount.toDecimal().toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strTValue: String = justifyColumn(cellData: "TValue", leftJustify: false, cellWidth: fiveColumns[2])
    var parValueLead = "PValue"
    var coverageLead = "Delta"
    if includeParValues == false {
        parValueLead = ""
        coverageLead = ""
    }
    var strParValue: String = justifyColumn(cellData: parValueLead, leftJustify: false, cellWidth: fiveColumns[3])
    var strCoverage: String = justifyColumn(cellData: coverageLead, leftJustify: false, cellWidth: fiveColumns[4])
    let line_Header = strNo + strDate + strTValue + strParValue + strCoverage
    arry.append(line_Header)

    for x in 0..<myTValues.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: myTValues.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fiveColumns[1])
        let decTValue = myTValues.items[x].amount * 100.0
        strTValue = justifyColumn(cellData: decTValue.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
        let decParValue = myParValues.items[x].amount * 100.0
        strParValue = justifyColumn(cellData: decParValue.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
        let decCoverage = decTValue - decParValue
        strCoverage = justifyColumn(cellData: decCoverage.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
        if includeParValues == false {
            strParValue = ""
            strCoverage = ""
        }
        let line_BodyRow = strNo + strDate + strTValue + strParValue  + strCoverage
        arry.append(line_BodyRow)
    }
    arry.append(emptyLine)
    
    return arry
}

func csvForTerminationValues(aLease: Lease, inLieuRent: Bool, includeParValues: Bool) -> String {
    //Title Row
    let strReportTitle: String = csvAmortRow(colOne: "", colTwo: "", colThree: "TValues", colFour: "", colFive: "", colSix: "")
    let strInLieu: String = csvAmortRow(colOne: "In Lieu of Rent:", colTwo: inLieuRent.toString(), colThree: "", colFour: "", colFive: "", colSix: "")
    let strAmount: String = csvAmortRow(colOne: "As a % of:", colTwo: aLease.amount.toDecimal().toString(decPlaces: 2), colThree: "", colFour: "", colFive: "", colSix: "")
    let strTitleBlock: String = strReportTitle + csvEmptyRow() + strInLieu + strAmount + csvEmptyRow()
    
    //Column Headers
    var headerRow: String = csvAmortRow(colOne: "Pmt No", colTwo: "Date", colThree: "TValue", colFour: "", colFive: "", colSix: "")
    if includeParValues == true {
        headerRow = csvAmortRow(colOne: "Pmt No", colTwo: "Date", colThree: "TValue", colFour: "ParValue", colFive: "Delta", colSix: "")
    }
    
    let rentDR = aLease.terminations?.discountRate_Rent ?? aLease.interestRate.toDecimal()
    let residualDR = aLease.terminations?.discountRate_Residual ?? aLease.interestRate.toDecimal()
    let additional = aLease.terminations?.additionalResidual ?? 0.00
    
    let myTValues:Cashflows = aLease.terminationValues(rateForRent: rentDR, rateForResidual: residualDR, adder: additional, inLieuOfRent: inLieuRent)
    let myParValues = aLease.parValues2(inLieuOfRent: inLieuRent)
    
    var strTVRow: String = ""
    for x in 0..<myTValues.items.count {
        let strNo: String = (x + 1).toString()
        let strDate: String = myTValues.items[x].dueDate.toStringDateShort(yrDigits: 2)
        let strTV: String = myTValues.items[x].amount.toString(decPlaces: 6)
        var strPV: String = ""
        var strDelta: String = ""
        let strFiller: String = ""
        if includeParValues == true {
            strPV = myParValues.items[x].amount.toString(decPlaces: 6)
            let decDiff: Decimal = myTValues.items[x].amount - myParValues.items[x].amount
            strDelta = decDiff.toString(decPlaces: 6)
        }
        strTVRow = strTVRow + csvAmortRow(colOne: strNo, colTwo: strDate, colThree: strTV, colFour: strPV, colFive: strDelta, colSix: strFiller)
    }
    
    return strTitleBlock + headerRow + strTVRow
}

func textForAverageLife(aLease: Lease, currentFile: String, isPad: Bool, isLandscape: Bool) -> String {
    var arry = [String]()
    let emptyLine: String = "\n"
    
    if isPad == true {
        arry = getTextTextForAverageLifeInPortrait(aLease: aLease, currentFile: currentFile, isPad: isPad)
    } else if isLandscape == true {
        arry = getTextForAverageLifeInLandscape(aLease: aLease, currentFile: currentFile, isPad: isPad)
    } else {
        arry = getTextTextForAverageLifeInPortrait(aLease: aLease, currentFile: currentFile, isPad: isPad)
    }
 
    var averageLifeReport: String = ""
    for x in 0..<arry.count {
        averageLifeReport = averageLifeReport + arry[x] + emptyLine
    }
    arry.removeAll()
            
    return averageLifeReport
}

func getTextForAverageLifeInLandscape (aLease: Lease, currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let sixColumns: [Int] = [4, 14, 14, 14, 14, 14]
    let avgLives: AverageLives = AverageLives(aLease: aLease)
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: true)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    arry.append(emptyLine)
    
    let strBasis: String = aLease.amount.toDecimal().toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: "Pmt", leftJustify: false, cellWidth: sixColumns[0])
    var strDate: String = justifyColumn(cellData: "Due", leftJustify: false, cellWidth: sixColumns[1])
    var strCumDays: String = justifyColumn(cellData: "Cumulative", leftJustify: false, cellWidth: sixColumns[2])
    var strCumYears: String = justifyColumn(cellData: "Cumulative", leftJustify: false, cellWidth: sixColumns[3])
    var strPrincPaid: String = justifyColumn(cellData: "Principal", leftJustify: false, cellWidth: sixColumns[4])
    var strPrincOut: String = justifyColumn(cellData: "Principal", leftJustify: false, cellWidth: sixColumns[5])
    var line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
    
    strNo = justifyColumn(cellData: "No.", leftJustify: false, cellWidth: sixColumns[0])
    strDate = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: sixColumns[1])
    strCumDays = justifyColumn(cellData: "Days", leftJustify: false, cellWidth: sixColumns[2])
    strCumYears = justifyColumn(cellData: "Years", leftJustify: false, cellWidth: sixColumns[3])
    strPrincPaid = justifyColumn(cellData: "Repaid", leftJustify: false, cellWidth: sixColumns[4])
    strPrincOut = justifyColumn(cellData: "Out Yrs", leftJustify: false, cellWidth: sixColumns[5])
    line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
    
    for x in 0..<avgLives.items.count {
        strNo = justifyColumn(cellData: (x + 1).toString(), leftJustify: false, cellWidth: sixColumns[0])
        strDate = justifyColumn(cellData: avgLives.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: sixColumns[1])
        strCumDays = justifyColumn(cellData: avgLives.items[x].cumulativeDays.toString(), leftJustify: false, cellWidth: sixColumns[2])
        strCumYears = justifyColumn(cellData: avgLives.items[x].yearsOutstanding.toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[3])
        strPrincPaid = justifyColumn(cellData: avgLives.items[x].principalPaid.toPercent(4), leftJustify: false, cellWidth: sixColumns[4])
        strPrincOut = justifyColumn(cellData: avgLives.items[x].principalOutstanding.toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[5])
        line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
        arry.append(line_Data)
    }
    arry.append(emptyLine)
    
    strNo = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: sixColumns[1])
    strCumDays = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[2])
    strCumYears = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[3])
    strPrincPaid = justifyColumn(cellData: avgLives.getTotalPrincipalPaid().toPercent(2), leftJustify: false, cellWidth: sixColumns[4])
    strPrincOut = justifyColumn(cellData: avgLives.getWeightedAverageLife().toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[5])
    line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
    
    return arry
    
}

func getTextTextForAverageLifeInPortrait(aLease: Lease, currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let sixColumns: [Int] = [3, 9, 6, 7, 9, 8]
    let avgLives: AverageLives = AverageLives(aLease: aLease)
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: false)
    
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    let strBasis: String = aLease.amount.toDecimal().toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[0])
    var strDate: String = justifyColumn(cellData: "Due", leftJustify: false, cellWidth: sixColumns[1])
    var strCumDays: String = justifyColumn(cellData: "Cum", leftJustify: false, cellWidth: sixColumns[2])
    var strCumYears: String = justifyColumn(cellData: "Cum", leftJustify: false, cellWidth: sixColumns[3])
    var strPrincPaid: String = justifyColumn(cellData: "Princ", leftJustify: false, cellWidth: sixColumns[4])
    var strPrincOut: String = justifyColumn(cellData: "Princ", leftJustify: false, cellWidth: sixColumns[5])
    var line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
    
    strNo = justifyColumn(cellData: "No.", leftJustify: false, cellWidth: sixColumns[0])
    strDate = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: sixColumns[1])
    strCumDays = justifyColumn(cellData: "Days", leftJustify: false, cellWidth: sixColumns[2])
    strCumYears = justifyColumn(cellData: "Years", leftJustify: false, cellWidth: sixColumns[3])
    strPrincPaid = justifyColumn(cellData: "Repaid", leftJustify: false, cellWidth: sixColumns[4])
    strPrincOut = justifyColumn(cellData: "Out Yrs", leftJustify: false, cellWidth: sixColumns[5])
    line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
   
    for x in 0..<avgLives.items.count {
        strNo = justifyColumn(cellData: (x + 1).toString(), leftJustify: false, cellWidth: sixColumns[0])
        strDate = justifyColumn(cellData: avgLives.items[x].dueDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: sixColumns[1])
        strCumDays = justifyColumn(cellData: avgLives.items[x].cumulativeDays.toString(), leftJustify: false, cellWidth: sixColumns[2])
        strCumYears = justifyColumn(cellData: avgLives.items[x].yearsOutstanding.toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[3])
        strPrincPaid = justifyColumn(cellData: avgLives.items[x].principalPaid.toPercent(4), leftJustify: false, cellWidth: sixColumns[4])
        strPrincOut = justifyColumn(cellData: avgLives.items[x].principalOutstanding.toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[5])
        line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
        arry.append(line_Data)
    }
    arry.append(emptyLine)
    strNo = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: sixColumns[1])
    strCumDays = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[2])
    strCumYears = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[3])
    strPrincPaid = justifyColumn(cellData: avgLives.getTotalPrincipalPaid().toPercent(2), leftJustify: false, cellWidth: sixColumns[4])
    strPrincOut = justifyColumn(cellData: avgLives.getWeightedAverageLife().toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[5])
    line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
    
    return arry
}
    
func textForAnnualInterestExpense(aLease: Lease, currentFile: String, isPad: Bool, isLandscape: Bool) -> String {
    var arry = [String]()
    let emptyLine: String = "\n"

    if isPad == true {
        arry = getTextForAnnualInterestExpenseInPortrait(aLease: aLease, currentFile: currentFile, isPad: isPad)
    } else if isLandscape == true {
        arry = getTextForAnnualInterestExpenseInLandscape(aLease: aLease, currentFile: currentFile, isPad: isPad)
    } else {
        arry = getTextForAnnualInterestExpenseInPortrait(aLease: aLease, currentFile: currentFile, isPad: isPad)
    }
 
    var annualInterestReport: String = ""
    for x in 0..<arry.count {
        annualInterestReport = annualInterestReport + arry[x] + emptyLine
    }
    arry.removeAll()
    
    return annualInterestReport
}


func getTextForAnnualInterestExpenseInLandscape(aLease: Lease, currentFile: String, isPad: Bool) ->  [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let fourColumns: [Int] = [8, 18, 18, 22]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: true)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    
    var strYear: String = justifyColumn(cellData: "Year", leftJustify: false, cellWidth: fourColumns[0])
    var strStartDate: String = justifyColumn(cellData: "From Date", leftJustify: false, cellWidth: fourColumns[1])
    var strEndDate: String = justifyColumn(cellData: "To Date", leftJustify: false, cellWidth: fourColumns[2])
    var strInterest: String = justifyColumn(cellData: "Interest", leftJustify: false, cellWidth: fourColumns[3])
    var line_Data = strYear + strStartDate + strEndDate + strInterest
    arry.append(line_Data)
    
    let myInterestTable: [AnnualInterestExpense] = aLease.getAnnualInterestExpense()
    var totalInterest: Decimal = 0.0
    for x in 0..<myInterestTable.count{
        strYear = justifyColumn(cellData: (x + 1).toString(), leftJustify: false, cellWidth: fourColumns[0])
        strStartDate = justifyColumn(cellData: myInterestTable[x].startDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fourColumns[1])
        strEndDate = justifyColumn(cellData: myInterestTable[x].endDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fourColumns[2])
        strInterest = justifyColumn(cellData: myInterestTable[x].interestExpense.toCurrency(false), leftJustify: false, cellWidth: fourColumns[3])
        totalInterest = totalInterest + myInterestTable[x].interestExpense
        line_Data = strYear + strStartDate + strEndDate + strInterest
        arry.append(line_Data)
    }
    arry.append(emptyLine)
    
    strYear = justifyColumn(cellData: "", leftJustify: false, cellWidth: fourColumns[0])
    strStartDate = justifyColumn(cellData: "", leftJustify: false, cellWidth: fourColumns[1])
    strEndDate = justifyColumn(cellData: "Total", leftJustify: false, cellWidth: fourColumns[2])
    strInterest = justifyColumn(cellData: totalInterest.toCurrency(false), leftJustify: false, cellWidth: fourColumns[3])
    line_Data = strYear + strStartDate + strEndDate + strInterest
    arry.append(line_Data)
    
    
    return arry
}

func getTextForAnnualInterestExpenseInPortrait(aLease: Lease, currentFile: String, isPad: Bool) -> [String] {
    var arry = [String]()
    let emptyLine: String = "\n"
    let fourColumns: [Int] = [5, 11, 11, 15]
    let maxChars = getMaxCharsInLine(isPad: isPad, isLandscape: false)
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    
    var strYear: String = justifyColumn(cellData: "Year", leftJustify: false, cellWidth: fourColumns[0])
    var strStartDate: String = justifyColumn(cellData: "From Date", leftJustify: false, cellWidth: fourColumns[1])
    var strEndDate: String = justifyColumn(cellData: "To Date", leftJustify: false, cellWidth: fourColumns[2])
    var strInterest: String = justifyColumn(cellData: "Interest", leftJustify: false, cellWidth: fourColumns[3])
    var line_Data = strYear + strStartDate + strEndDate + strInterest
    arry.append(line_Data)
    
    let myInterestTable: [AnnualInterestExpense] = aLease.getAnnualInterestExpense()
    var totalInterest: Decimal = 0.0
    for x in 0..<myInterestTable.count{
        strYear = justifyColumn(cellData: (x + 1).toString(), leftJustify: false, cellWidth: fourColumns[0])
        strStartDate = justifyColumn(cellData: myInterestTable[x].startDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fourColumns[1])
        strEndDate = justifyColumn(cellData: myInterestTable[x].endDate.toStringDateShort(yrDigits: 2), leftJustify: false, cellWidth: fourColumns[2])
        strInterest = justifyColumn(cellData: myInterestTable[x].interestExpense.toCurrency(false), leftJustify: false, cellWidth: fourColumns[3])
        totalInterest = totalInterest + myInterestTable[x].interestExpense
        line_Data = strYear + strStartDate + strEndDate + strInterest
        arry.append(line_Data)
    }
    arry.append(emptyLine)
    
    strYear = justifyColumn(cellData: "", leftJustify: false, cellWidth: fourColumns[0])
    strStartDate = justifyColumn(cellData: "", leftJustify: false, cellWidth: fourColumns[1])
    strEndDate = justifyColumn(cellData: "Total", leftJustify: false, cellWidth: fourColumns[2])
    strInterest = justifyColumn(cellData: totalInterest.toCurrency(false), leftJustify: false, cellWidth: fourColumns[3])
    line_Data = strYear + strStartDate + strEndDate + strInterest
    arry.append(line_Data)
    
    
    return arry
}
