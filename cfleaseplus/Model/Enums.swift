//
//  Enums.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

enum Mode: Int {
    case leasing, lending
    
    func toString() -> String {
        if self == .leasing {
            return "Leasing"
        } else {
            return "Lending"
        }
    }
}



enum DayCountMethod: Int {
    case Thirty_ThreeSixty_ConvUS
    case Actual_ThreeSixtyFive
    case Actual_Actual
    case Actual_ThreeSixty
    
    func toString() -> String {
        switch self {
        case .Thirty_ThreeSixty_ConvUS:
            return "30/360"
        case .Actual_ThreeSixtyFive:
            return "Actual/365"
        case .Actual_Actual:
            return "Actual/Actual"
        case .Actual_ThreeSixty:
            return "Actual/360"
        }
    }
    
    func toInt() -> Int {
        return self.rawValue
    }
    
    static let dayCountMethods: [DayCountMethod] = [.Thirty_ThreeSixty_ConvUS, .Actual_ThreeSixtyFive, .Actual_Actual, .Actual_ThreeSixty]
}

extension String {
    func toDayCountMethod() -> DayCountMethod {
        switch self {
        case "30/360":
            return .Thirty_ThreeSixty_ConvUS
        case "Actual/365":
            return .Actual_ThreeSixtyFive
        case "Actual/Actual":
            return .Actual_Actual
        case "Actual/360":
            return .Actual_ThreeSixty
        default:
            return DayCountMethod.Actual_ThreeSixty
        }
    }
}

extension String {
    func toOperatingMode() -> Mode {
        if self == "0" {
            return .leasing
        } else {
            return .lending
        }
    }
}

enum Frequency: Int, CaseIterable {
    case monthly = 12
    case quarterly = 4
    case semiannual = 2
    case annual = 1
    
    func toString () -> String {
        switch self {
        case .monthly:
            return "Monthly"
        case .quarterly:
            return "Quarterly"
        case .semiannual:
            return "Semiannual"
        case .annual:
            return "Annual"
        }
        
    }
    
    static let three: [Frequency] = [.monthly, .quarterly, .semiannual]
    static let two: [Frequency] = [.monthly, .quarterly]
    static let one: [Frequency] = [.monthly]
}

extension String {
    func toFrequency () -> Frequency {
        switch self {
        case "Monthly":
            return .monthly
        case "Quarterly":
            return .quarterly
        case "Semiannual":
            return .semiannual
        case "Annual":
            return .annual
        default:
            return .monthly
        }
    }
}

enum FeeIncomeType: Int, CaseIterable {
    case expense
    case income
    
    func toString() -> String {
        switch self {
        case .expense:
            return "Expense"
        case .income:
            return "Income"
        }
    }
    
    static let allCases: [FeeIncomeType] = [.expense, .income]
}

enum FeeType: Int, CaseIterable {
    case all
    case customerPaid
    case other
    case purchase
    
    func toString() -> String{
        switch self{
        case .customerPaid:
            return "Customer Paid"
        case .other:
            return "Other"
        case .purchase:
            return "Purchase"
        default:
            return "All"
        }
    }
    
    static let allCases: [FeeType] = [.customerPaid, .other, .purchase]
}


enum PaymentType: Int, CaseIterable {
    case balloon
    case deAll
    case deNext
    case funding
    case interest
    case payment
    case principal
    case residual
    
    func toString() -> String {
        switch self {
        case .balloon:
            return "Balloon"
        case .deAll:
            return "DeAll"
        case .deNext:
            return "DeNext"
        case .funding:
            return "Funding"
        case .interest:
            return "Interest"
        case .payment:
            return "Payment"
        case .principal:
            return "Principal"
        case .residual:
            return "Residual"
        }
    }
    
    static let allPayments: [PaymentType] = [.balloon, .deAll, .deAll, .interest, .payment, .principal, .residual]
    static let interimTypes:[PaymentType] =  [.deNext, .deAll, .interest, .payment, .principal]
    static let interimLendingTypes: [PaymentType] = [.interest, .payment, .principal]
    static let residualTypes: [PaymentType] = [.balloon, .residual]
    static let defaultTypes: [PaymentType] = [.interest, .payment, .principal]
    static let calculatedTypes: [PaymentType] = [.deAll, .deNext, .interest]
}


enum TargetType: Int, CaseIterable{
    case amount
    case feesUnlocked
    case implicitRate
    case interestRate
    case paymentsUnlocked
    case spread
    case yield
    
    func toString() -> String {
        switch self {
        case .amount:
            return "Amount"
        case .feesUnlocked:
            return "Unlocked Fees"
        case .implicitRate:
            return " Implicit Rate"
        case .interestRate:
            return "Interest Rate"
        case .paymentsUnlocked:
            return "Unlocked Payments"
        case . spread:
            return "Spread"
        case . yield:
            return "Yield"
            
        }
    }
    
    static let allCases: [TargetType] = [.amount, .feesUnlocked, .implicitRate, .interestRate, .paymentsUnlocked, .spread, .yield]
}


extension String {
    func stringToPaymentType() -> PaymentType {
        switch self {
        case "Balloon":
            return PaymentType.balloon
        case "DeAll":
            return PaymentType.deAll
        case "DeNext":
            return PaymentType.deNext
        case "Funding":
            return PaymentType.funding
        case "Interest":
            return PaymentType.interest
        case "Payment":
            return PaymentType.payment
        case "Principal":
            return PaymentType.principal
        case "Residual":
            return PaymentType.residual
        default:
            return PaymentType.payment
        }
    }
}

enum PaymentTiming: Int {
    case advance
    case arrears
    case equals
    
    static let residualCases: [PaymentTiming] = [.equals]
    static let interestCases: [PaymentTiming] = [.arrears]
    static let paymentCases: [PaymentTiming] = [.advance, .arrears]
    static let allCases: [PaymentTiming] = [.advance, .arrears, .equals]
    
    func toString () -> String {
        switch self {
        case .advance:
            return "Advance"
        case .arrears:
            return "Arrears"
        default:
            return "Equals"
        
        }
    }
}

enum ShowMenu: Int {
    case open
    case closed
    case neither

}

extension String {
    func stringToPaymentTiming() -> PaymentTiming {
        switch self {
        case "Advance":
            return .advance
        case "Arrears":
            return .arrears
        default:
            return .equals
        }
    }
}

enum eboPremiumType: Int {
    case specified
    case calculated
    
    func toString() -> String {
        switch self {
        case .specified:
            return "Specified"
        case .calculated:
            return "Calculated"
        }
    }
}

extension String {
    func toEBOPremiumType() -> eboPremiumType {
        switch self {
        case "Specified":
            return .specified
        case "Calculated" :
            return .calculated
        default:
            return .specified
        }
    }
}


