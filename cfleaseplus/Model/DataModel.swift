//
//  DataModel.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

let str_split_Properties_Groups_Classes = "#"
let str_split_Groups = "<"
let str_split_Fees = "|"

let str_split_LesseeObligations = ">"
let str_split_Classes = "*"

let str_split_Cashflows = "#"
let str_DefaultEmpty = "No_Data"

//Writing Data

func writeLeaseOnly(aLease: Lease) -> String {
    let strPropertiesData = writeLeaseProperties(aLease: aLease)
    let strGroupsData = writeGroups(aGroups: aLease.groups)
    return strPropertiesData + str_split_Properties_Groups_Classes + strGroupsData
}

func writeLeaseAndClasses(aLease: Lease) -> String {
    let strPropertiesData:String = writeLeaseProperties(aLease: aLease)
    let strGroupsData:String = writeGroups(aGroups: aLease.groups)
    let strClassesData:String = writeClasses(aLease: aLease)
    let strLeaseData:[String] = [strPropertiesData, strGroupsData, strClassesData]
    
    return strLeaseData.joined(separator: str_split_Properties_Groups_Classes)
}

func writeLeaseProperties (aLease: Lease) -> String {
    let strAmount:String = aLease.amount
    let strBaseTermCommenceDate:String = aLease.baseTermCommenceDate.toStringDateShort(yrDigits: 4)
    let strBaseTerm = aLease.baseTerm.toString()
    let strChild:String = aLease.childOf.toString()
    let strEOM:String = aLease.endOfMonthRule.toString()
    let strFirstAnn: String  = aLease.firstAnniversaryDate.toStringDateShort(yrDigits: 4)
    let strFundingDate: String = aLease.fundingDate.toStringDateShort(yrDigits: 4)
    let strDayCountMethod: String = aLease.interestCalcMethod.toString()
    let strInterestRate: String = aLease.interestRate
    let strPayPerYear:String = aLease.paymentsPerYear.toString()
    let strMode: String = aLease.operatingMode.rawValue.toString()
    
    let strData = [strAmount, strBaseTermCommenceDate, strBaseTerm, strChild, strEOM, strFirstAnn, strFundingDate, strDayCountMethod, strInterestRate, strPayPerYear, strMode]
    return strData.joined(separator: ",")
}

func writeGroups(aGroups: Groups) -> String {
    var strGroups: String = ""
    
    for i in 0..<aGroups.items.count {
        let strOneGroup = writeGroup(aGroup: aGroups.items[i])
        strGroups = strGroups + strOneGroup + str_split_Groups
    }
    return String(strGroups.dropLast())
}

func writeGroup (aGroup: Group) -> String {
    let strAmount = aGroup.amount
    let strEndDate = aGroup.endDate.toStringDateShort(yrDigits: 4)
    let strLocked = aGroup.locked.toString()
    let strNoOfPayments = aGroup.noOfPayments.toString()
    let strStartDate = aGroup.startDate.toStringDateShort(yrDigits: 4)
    let strTiming = aGroup.timing.toString()
    let strType = aGroup.type.toString()
    let strUndeletable = aGroup.undeletable.toString()
    let strIsInterim = aGroup.isInterim.toString()
   
    let properties: Array = [strAmount, strEndDate, strLocked, strNoOfPayments, strStartDate, strTiming, strType, strUndeletable, strIsInterim]
    return properties.joined(separator: ",")
}

func writeClasses(aLease: Lease) -> String {
    let strFees = writeFees(aFees: aLease.fees!)
    let strObligations =  writeObligations(aObligations: aLease.leaseObligations!)
    let strEarlyBuyOut = writeEarlyBuyOut(aEBO: aLease.earlyBuyOut!)
    let strTerminations = writeTerminations(aTerminations: aLease.terminations!)

    return strFees + str_split_Classes + strObligations + str_split_Classes + strEarlyBuyOut + str_split_Classes + strTerminations
}

func writeFees(aFees: Fees) -> String {
    if aFees.items.count == 0 {
        return "No_Fees"
    } else {
        var strFees: String = ""
        
        for i in 0..<aFees.items.count {
            let strOneFee = writeFee(aFee: aFees.items[i])
            strFees = strFees + strOneFee + str_split_Fees
        }
        return String(strFees.dropLast())
    }
}

func writeFee (aFee: Fee) -> String {
    let strName = aFee.name
    let strDate = aFee.effectiveDate.toStringDateShort(yrDigits: 4)
    let strAcctgType = aFee.incomeType.toString()
    let strFeeType = aFee.type.toString()
    let strAmount = aFee.amount
    let strLocked = aFee.locked.toString()
    
    let properties: Array = [strName, strDate, strAcctgType, strFeeType, strAmount, strLocked]
    return properties.joined(separator: ",")
    
}

func writeObligations(aObligations: Obligations) -> String {
    let strDiscountRate: String = aObligations.discountRate
    let strResidualGty: String = aObligations.residualGuarantyAmount
    let strObligations = [strDiscountRate, strResidualGty]
    
    return strObligations.joined(separator: ",")
}

func writeEarlyBuyOut(aEBO: EarlyPurchaseOption) -> String {
    let strEBODate: String = aEBO.exerciseDate.toStringDateShort(yrDigits: 4)
    let strAmount: String = aEBO.amount
    let strRentDueIsPaid: String = aEBO.rentDueIsPaid.toString()
    let strEBO = [strEBODate, strAmount, strRentDueIsPaid]

    
    return strEBO.joined(separator: ",")
}

func writeTerminations(aTerminations: Terminations) -> String {
    let strDiscountRateForRent: String = aTerminations.discountRate_Rent.toString(decPlaces: 6)
    let strDiscountRateForResidual: String = aTerminations.discountRate_Residual.toString(decPlaces: 6)
    let strAdditionalResidual: String = aTerminations.additionalResidual.toString(decPlaces: 6)
    let strTerminations = [strDiscountRateForRent, strDiscountRateForResidual, strAdditionalResidual]
    
    return strTerminations.joined(separator: ",")
}
// end of Writing


//Reading Data


func readLeaseOnly(strLease: String) -> Lease {
    let arryLease = strLease.components(separatedBy: str_split_Properties_Groups_Classes)
    let data = arryLease[0].components(separatedBy: ",")
    let groupsData: [String] = arryLease[1].components(separatedBy: str_split_Groups)
    
    let myLease = Lease(
        amt: data[0],
        baseCommence: data[1].toDate(),
        term: data[2].toInteger(),
        child: data[3].toInteger(),
        EOM: data[4].toBool(),
        firstAnnual: data[5].toDate(),
        funding: data[6].toDate(),
        intCalcMethod: data[7].toDayCountMethod(),
        rate: data[8],
        payPerYear: data[9].toFrequency(),
        mode: data[10].toOperatingMode()
    )
    
    let myGroups = readGroups(strGroups: groupsData)
    myLease.groups = myGroups
    
    return myLease
}

func readLeaseAndClasses(strLease: String) -> Lease {
    let arryLease: [String] = strLease.components(separatedBy: str_split_Properties_Groups_Classes)
    let leaseData: [String] = arryLease[0].components(separatedBy: ",")
    let groupsData: [String] = arryLease[1].components(separatedBy: str_split_Groups)
    
    let myLease = Lease(
        amt: leaseData[0],
        baseCommence: leaseData[1].toDate(),
        term: leaseData[2].toInteger(),
        child: leaseData[3].toInteger(),
        EOM: leaseData[4].toBool(),
        firstAnnual: leaseData[5].toDate(),
        funding: leaseData[6].toDate(),
        intCalcMethod: leaseData[7].toDayCountMethod(),
        rate: leaseData[8],
        payPerYear: leaseData[9].toFrequency(),
        mode: leaseData[10].toOperatingMode()
    )
    myLease.groups = readGroups(strGroups: groupsData)
    
    let classData = arryLease[2].components(separatedBy: str_split_Classes)
    
    if classData[0] == "No_Fees" {
        myLease.fees = Fees()
    } else {
        let feesData = classData[0].components(separatedBy: ",")
        myLease.fees = readFees(strFees: feesData)
    }
    
    let obligationsData = classData[1].components(separatedBy: ",")
    myLease.leaseObligations = Obligations(aDiscountRate: obligationsData[0], aResidualGuarantyAmount: obligationsData[1])

    let earlybuyoutData = classData[2].components(separatedBy: ",")
    myLease.earlyBuyOut = EarlyPurchaseOption(aExerciseDate: earlybuyoutData[0].toDate(),aAmount: earlybuyoutData[1], rentDue: earlybuyoutData[2].toBool())
    
    let terminationsData = classData[3].components(separatedBy: ",")
    myLease.terminations = Terminations(discountRate_Rent: terminationsData[0].toDecimal(), discountRate_Residual: terminationsData[1].toDecimal(), additionalResidual: terminationsData[2].toDecimal())
   
    return myLease
}

func readGroups(strGroups: [String]) -> Groups {
    let myGroups = Groups()
    
    for i in 0..<strGroups.count {
        let myGroup = readGroup(strGroup: strGroups[i])
        myGroups.items.append(myGroup)
    }
    return myGroups
}

func readGroup (strGroup: String) -> Group {
    let properties = strGroup.components(separatedBy: ",")
    
    let myGroup = Group(aAmount: properties[0], aEndDate: properties[1].toDate(), aLocked: properties[2].toBool(), aNoOfPayments: properties[3].toInteger(), aStartDate: properties[4].toDate(), aTiming: properties[5].stringToPaymentTiming(), aType: properties[6].stringToPaymentType(), aUndeletable: properties[7].toBool(), aIsInterim: properties[8].toBool())
    
    return myGroup
}


func readFees (strFees: [String]) -> Fees {
    let myFees = Fees()
    
    for i in 0..<strFees.count {
        let myFee = readFee(strFee: strFees[i])
        myFees.items.append(myFee)
    }
    
    return myFees
}

func readFee(strFee: String) -> Fee {
    let properties = strFee.components(separatedBy: ",")
    
    let myFee = Fee(title: properties[0], effectDate: properties[1].toDate(), acctgType: properties[2].toFeeIncomeType, strAmount: properties[3], feeType: properties[4].toFeeType, feeLocked: properties[5].toBool())
    
    return myFee
}

//Cashflows
func writeCashflows (aCFs: Cashflows) -> String {
    var strCashflows: String = ""
    for i in 0..<aCFs.items.count {
        let strDueDate = aCFs.items[i].dueDate.toStringDateShort(yrDigits: 4)
        let strAmount = aCFs.items[i].amount.toString()
        let strOneCashflow = strDueDate + "," + strAmount
        strCashflows = strCashflows + strOneCashflow + str_split_Cashflows
    }
    return String(strCashflows.dropLast())
}

func readCashflows (strCFs: String) -> Cashflows {
    let strCashFlows = strCFs.components(separatedBy: str_split_Cashflows)
    let myCashflows = Cashflows()
    
    for strCF in strCashFlows {
        let arryCF = strCF.components(separatedBy: ",")
        
        let dateDue = arryCF[0].toDate()
        let amount = arryCF[1].toDecimal()
        
        let myCF = Cashflow(due: dateDue, amt: amount)
        myCashflows.items.append(myCF)
    }
    return myCashflows
}
