//
//  Integer.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

extension Int {
    func toString () -> String {
        return String(self)
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}


extension Int {
    func toDouble() -> Double {
        return Double(self)
    }
}
