//
//  Globals.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

public let toleranceAmounts: Decimal = 0.0075
public let toleranceZero: Decimal = 0.0075
public let maxIterations: Int = 50
public let maximumLeaseAmount: String = "50000000.00"
public let minimumLeaseAmount: String = "9.99"
public let maxBaseTerm: Int = 360
public let maxInterestRate: String = "0.39"
public let maxEBOSpread: Int = 500
public var modificationDate: String = "01/01/1900"
public let maxFileNameLength: Int = 40
public let removeCharacters: Set<Character> = [",", "$","-", "+","%"]
