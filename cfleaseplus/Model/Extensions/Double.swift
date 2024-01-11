//
//  Double.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

extension Double {
    func toString () -> String {
        let decValue = Decimal(self)
        return decValue.toString()
    }
}

extension Double {
    func toInteger() -> Int {
        return Int(self)
    }
}
