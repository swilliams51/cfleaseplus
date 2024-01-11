//
//  Math.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

func mxbFactor(factor1: Decimal, value1: Decimal, factor2: Decimal, value2: Decimal) -> Decimal {
    let dbM = slope(y2: value2, y1: value1, x2: factor2, x1: factor1)
    let dbB = yInterecept(mSlope: dbM, x: factor2, y: value2)
    let mxb = safeDivision(aNumerator: dbB, aDenominator: dbM)
    
    return  mxb * -1.0
}

func slope(y2: Decimal, y1: Decimal, x2: Decimal, x1: Decimal) -> Decimal {
    let dbSlope: Decimal = (y2 - y1) / (x2 - x1)
    return dbSlope
}

func yInterecept(mSlope: Decimal, x: Decimal, y: Decimal) -> Decimal {
    return y - (mSlope * x)
}

func safeDivision (aNumerator: Decimal, aDenominator: Decimal) -> Decimal {
    var quotient: Decimal = 0.0
    
    if aDenominator != 0.0 || aNumerator != 0.0 {
        quotient = aNumerator / aDenominator
    }
    return quotient
}

func amountIsEqualToZero (askAmount: Decimal, aLambda: Decimal) -> Bool {
    var isEqualToZero: Bool = false
    
    let diff = abs(askAmount - aLambda)
    if diff <= aLambda {
        isEqualToZero = true
    }
    return isEqualToZero
}

func amountsAreEqual(aAmt1: Decimal, aAmt2: Decimal, aLamda: Decimal) -> Bool {
    var bolAmtsAreEqual: Bool = false
    
    if abs(aAmt1 - aAmt2) <= aLamda {
        bolAmtsAreEqual = true
    }
    
    return bolAmtsAreEqual
}

func amountsAboutEqual(aAmt1: Decimal, aAmt2: Decimal, pctDiff: Decimal) -> Bool {
    var amountsAreEqual: Bool = false
    let diff = abs(aAmt1 - aAmt2)
    let percentage: Decimal = diff / aAmt1
    
    if percentage < pctDiff {
        amountsAreEqual = true
    }
    
    return amountsAreEqual
}


func pv (annualRate: Decimal, noOfPayments: Int, pmtAmount: Decimal, freq: Frequency, timing: PaymentTiming) -> Decimal {
    let periodicRate: Decimal = annualRate / Decimal(freq.rawValue)
    var runTotalPV: Decimal = 0.0
    var start: Int = 1
    
    if timing == .advance {
        runTotalPV = pmtAmount
        start = 2
    }
    
    for x in start...noOfPayments {
        let pv: Decimal = pmtAmount / pow((1 + periodicRate), x)
        runTotalPV = runTotalPV + pv
    }
    
    return runTotalPV
    
}

func factors(numberIn: Int) -> [Int] {
    var myFactors = [Int]()
    
    for i in 1...numberIn {
        if  numberIn %  i == 0 {
            myFactors.append(i)
        }
    }

    myFactors.remove(at: myFactors.count - 1)
    
    return myFactors
}

func power(base: Decimal, exp: Int) -> Decimal {
    var counter: Int = 1
    
    var pow: Decimal = 1.0
    while exp >= counter {
        pow = pow * base
        counter += 1
    }
    
     return pow
}
