//
//  Date.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

extension Date {
    func toStringDateShort(yrDigits: Int) -> String {
        let iDay: String = String(getDayComponent(dateIn: self))
        let iMonth: String = String(getMonthComponent(dateIn: self))
        let iYear: String = String(getYearComponent(dateIn: self))
        let strYear:String = String(iYear.suffix(yrDigits))
        
        return  iMonth + "/" + iDay + "/" + strYear
    }
}

extension Date {
    func toStringDateLong() -> String {
        let iDay: String = String(getDayComponent(dateIn: self))
        let iMonth: Int = getMonthComponent(dateIn: self)
        let iYear: String = String(getYearComponent(dateIn: self))
        let strMonth: String = getTheMonth(mon: iMonth)
        
        return strMonth + " " + iDay + ", " + iYear
    }
}
