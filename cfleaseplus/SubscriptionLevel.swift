//
//  SubscriptionLevel.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/6/23.
//

import Foundation

enum Level: String {
    
    //ApiKey cbd1423433c14a5f9c352efd42d57684

    case basic, premium
    
    static let allCases: [Level] = [.basic, .premium]
    
    func toString() -> String {
        if self == .basic {
            return "Basic"
        } else {
            return "Premium"
        }
    }
}
