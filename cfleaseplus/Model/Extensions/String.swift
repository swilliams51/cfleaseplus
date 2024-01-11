//
//  String.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

extension String {
    func toDecimal() -> Decimal {
        return Decimal(string: self) ?? 0.0
    }
}


extension String {
    func toDouble() -> Double {
        return Double(self) ?? 0.00
    }
}

extension String {
    func isDecimal() -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.locale = Locale.current
        return formatter.number (from: self) != nil
    }
}

extension String {
    func isInteger () -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.locale = Locale.current
        return formatter.number (from: self) != nil
    }
}

extension String {
    func toDate () -> Date {
        return stringToDate(strAskDate: self)
    }
}

extension String {
    func toInteger () -> Int {
        return Int(self)!
    }
}


extension String {
    func toBool () -> Bool {
        if self == "True" {
            return true
        } else {
            return false
        }
    }
}


extension String {
    func toTruncDecimalString(decPlaces: Int) -> String {
        var strReturn: String = self
        if self.contains(".") {
            let strParts = self.components(separatedBy: ".")
            var strRight = ""
            var counter = 0
            if strParts[1].count > 0 {
                for char in strParts[1] {
                    strRight = strRight + String(char)
                    counter = counter + 1
                    if counter == decPlaces {
                        break
                    }
                }
            }
            strReturn = strParts[0] + "." + strRight
        }
        
       return strReturn
    }
}

extension String {
    func truncateAmount (decPlaces: Int) -> String {
        var decimalLocation: Int = 0
    
        for char in self {
            if char == "." {
                break
            }
            decimalLocation = decimalLocation + 1
        }
        let numberOfDecimalPlaces = self.count - decimalLocation
        let lengthToReturn = max(numberOfDecimalPlaces, decimalLocation + decPlaces)
        
        return String(self.prefix(lengthToReturn))
    }
}


extension String {
    var isNumeric: Bool {
           guard self.count > 0 else { return false }
           let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
           return Set(self).isSubset(of: nums)
       }
}

extension String {
    var isAlphabetic: Bool {
        guard self.count > 0 else { return false }
        let letters: CharacterSet = CharacterSet.letters
        return (self.rangeOfCharacter(from: letters) != nil)
    }
}

extension String {
    var containsIllegalChars: Bool {
        guard self.count > 0 else { return false }
        let illegal: CharacterSet = CharacterSet.illegalCharacters
        return (self.rangeOfCharacter(from: illegal) != nil)
    }
}

extension String {
    var containsPunctuationChars: Bool {
        guard self.count > 0 else { return false }
        let illegal: CharacterSet = CharacterSet.punctuationCharacters
        return (self.rangeOfCharacter(from: illegal) != nil)
    }
}

extension String {
    func replaceFirst(of pattern: String, with replacement: String) -> String {
        if let range = self.range(of: pattern) {
            return self.replacingCharacters(in: range, with: replacement)
        } else {
            return self
        }
    }
}

extension String {
    var toCGFloat: CGFloat {
        let n = NumberFormatter().number(from: self)!
        return CGFloat(truncating: n)
    }
}

extension String {
    var toFeeIncomeType: FeeIncomeType {
        if self == "Income" {
            return .income
        } else {
            return .expense
        }
    }
}

extension String {
    var toFeeType: FeeType {
        if self == "Customer Paid" {
            return .customerPaid
        } else if self == "Purchase" {
            return .purchase
        } else if self == "All" {
            return .all
        } else {
            return .other
        }
    }
}

