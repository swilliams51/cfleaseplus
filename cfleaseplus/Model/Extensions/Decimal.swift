//
//  Decimal.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

extension Decimal {
    func toString (decPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = decPlaces
        formatter.maximumFractionDigits = decPlaces
        return formatter.string(from: self as NSDecimalNumber) ?? "0.0"
    }
}

extension Decimal {
    func toCurrency(_ wSymbol: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        if wSymbol == false {
            formatter.currencySymbol = ""
        }
        return formatter.string(from: self as NSDecimalNumber) ?? "0.0"
    }
}

extension Decimal {
    func toPercent(_ places: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.percent
        formatter.minimumFractionDigits = places
        formatter.maximumFractionDigits = places
        return formatter.string(from: self as NSDecimalNumber) ?? "0.0"
    }
}

extension Decimal {
    func toInteger() -> Int {
        let dblOf = self.toDouble()
        return dblOf.toInteger()
    }
}

extension Decimal {
    func toRoundUp (_ places: Int) -> String {
        let exp: Double = Double(truncating: places as NSNumber)
        let factor: Double = pow(10, exp)
        let number: Double = Double(truncating: self as NSNumber)
        let roundUp: Double = ceil(number * factor) / factor
        
        return Decimal(roundUp).toString(decPlaces: places)
    }
}

extension Decimal {
    func toRoundDown (_ places: Int) -> String {
        let exp: Double = Double(truncating: places as NSNumber)
        let factor: Double = pow(10, exp)
        let number: Double = Double(truncating: self as NSNumber)
        let roundDown: Double = floor(number * factor) / factor
        
        
        return Decimal(roundDown).toString(decPlaces: places)
    }
}

extension Decimal {
    func toDouble() -> Double {
        return Double(self.description)!
    }
}

