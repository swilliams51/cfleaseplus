//
//  Dates.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

func addOnePeriodToDate (dateStart: Date, payperYear: Frequency, dateRefer: Date, bolEOMRule: Bool) -> Date {
    let theStartDay = getDayComponent(dateIn: dateStart)
    let theStartMonth = getMonthComponent(dateIn: dateStart)
    let theStartYear = getYearComponent(dateIn: dateStart)
    let referDay = getDayComponent(dateIn: dateRefer)
    let referMonth = getMonthComponent(dateIn: dateRefer)
    let referYear = getYearComponent(dateIn: dateRefer)
    let isReferLDM = isLastDayOfMonth(iDay: referDay, iMonth: referMonth, iYear: referYear)
    var theEndMonth = 0
    var theEndYear = 0
    
    switch payperYear {
    case .monthly:
        if theStartMonth == 12 {
            theEndMonth = 1
            theEndYear = theStartYear + 1
        } else {
            theEndMonth = theStartMonth + 1
            theEndYear = theStartYear
        }
    case .quarterly:
        if theStartMonth > 9 {
            theEndMonth = theStartMonth + 3 - 12
            theEndYear = theStartYear + 1
        } else {
            theEndMonth = theStartMonth + 3
            theEndYear = theStartYear
        }
    case .semiannual:
        if theStartMonth > 6 {
            theEndMonth = theStartMonth + 6 - 12
            theEndYear = theStartYear + 1
        } else {
            theEndMonth = theStartMonth + 6
            theEndYear = theStartYear
        }
    case .annual:
        theEndMonth = theStartMonth
        theEndYear = theStartYear + 1
    }
    let theEndDay = getTheDay(referDay: referDay, startDay: theStartDay, endMonth: theEndMonth, endYear: theEndYear, bolEOM: bolEOMRule, bolReferIsLDM: isReferLDM)
    
    var comps = DateComponents()
    comps.day = theEndDay
    comps.month = theEndMonth
    comps.year = theEndYear
    
    let dateNew = Calendar.current.date(from: comps)!
    
    return dateNew
}

//MARK: - addPeriodsToDate
func addPeriodsToDate (dateStart: Date, payPerYear: Frequency, noOfPeriods: Int, referDate: Date, bolEOMRule: Bool) -> Date {
    var iCounter = 0
    var tempDate = dateStart
    if noOfPeriods > 0 {
        while iCounter < noOfPeriods {
            tempDate = addOnePeriodToDate(dateStart: tempDate, payperYear: payPerYear, dateRefer: referDate, bolEOMRule: bolEOMRule)
            iCounter += 1
        }
    }
    return tempDate
}

func subtractOnePeriodFromDate(dateStart: Date, payperYear: Frequency, dateRefer: Date, bolEOMRule: Bool) -> Date {
    let theStartDay = getDayComponent(dateIn: dateStart)
    let theStartMonth = getMonthComponent(dateIn: dateStart)
    let theStartYear = getYearComponent(dateIn: dateStart)
    let referDay = getDayComponent(dateIn: dateRefer)
    let referMonth = getMonthComponent(dateIn: dateRefer)
    let referYear = getYearComponent(dateIn: dateRefer)
    let isReferLDM = isLastDayOfMonth(iDay: referDay, iMonth: referMonth, iYear: referYear)
    var theEndMonth = 0
    var theEndYear = 0
    
    switch payperYear {
    case .monthly:
        if theStartMonth == 1 {
            theEndMonth = 12
            theEndYear = theStartYear + 1
        } else {
            theEndMonth = theStartMonth - 1
            theEndYear = theStartYear
        }
    case .quarterly:
        if theStartMonth <= 3 {
            theEndMonth = theStartMonth - 3 + 12
            theEndYear = theStartYear - 1
        } else {
            theEndMonth = theStartMonth - 3
            theEndYear = theStartYear
        }
    case .semiannual:
        if theStartMonth <= 6 {
            theEndMonth = theStartMonth - 6 + 12
            theEndYear = theStartYear - 1
        } else {
            theEndMonth = theStartMonth - 6
            theEndYear = theStartYear
        }
    case .annual:
        theEndMonth = theStartMonth
        theEndYear = theStartYear - 1
    }
    let theEndDay = getTheDay(referDay: referDay, startDay: theStartDay, endMonth: theEndMonth, endYear: theEndYear, bolEOM: bolEOMRule, bolReferIsLDM: isReferLDM)
    
    var comps = DateComponents()
    comps.day = theEndDay
    comps.month = theEndMonth
    comps.year = theEndYear
    
    let dateNew = Calendar.current.date(from: comps)!
    
    return dateNew
}

func daysBetween(start: Date, end: Date) -> Int {
    var days: Int = 0
    
    if end > start {
        days = Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    return days
}

func monthsBetween(start: Date, end: Date) -> Int {
    let yrStart: Int = getYearComponent(dateIn: start)
    let monStart: Int = getMonthComponent(dateIn: start)
    let dayStart: Int = getDayComponent(dateIn: start)
    let yrEnd: Int = getYearComponent(dateIn: end)
    let monEnd: Int = getMonthComponent(dateIn: end)
    let dayEnd: Int = getDayComponent(dateIn: end)
    var intAdj: Int = 0
    
    let years = yrEnd - yrStart
    let months = monEnd - monStart
    let days = dayEnd - dayStart
    
    if days < 0 {
        intAdj = -1
    }

    return (years * 12) + months + intAdj
}

func stringToDate (strAskDate: String) -> Date {
    //date in mm/dd/yy or yyyy-mm-dd
    let myArray: [String] = strAskDate.components(separatedBy: "/")
    let intMonth: Int = Int(myArray[0])!
    let intDay: Int = Int(myArray[1])!
    let intYear: Int = Int(myArray[2])!
    
    var components = DateComponents()
    components.day = intDay
    components.month = intMonth
    components.year = intYear
    
    return Calendar.current.date(from: components) ?? today()
}


func getDayComponent (dateIn: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: dateIn)
    let theDay = components.day!
    
    return theDay
}

func getMonthComponent (dateIn: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: dateIn)
    let theMonth = components.month!
    
    return theMonth
}

func getYearComponent (dateIn: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.month], from: dateIn)
    let theYear = components.year!

    return theYear
}

func getTheDay (referDay: Int, startDay: Int, endMonth: Int, endYear: Int, bolEOM: Bool, bolReferIsLDM: Bool) -> Int {
    var theDay = 0
    
    if startDay < 28 {
        return startDay
    }
    
    if (bolEOM == true && bolReferIsLDM == true) {
        return lastDayOfMonth(iMonth: endMonth, iYear: endYear)
    }
    
    if (bolEOM == false && bolReferIsLDM == true) {
        return min(startDay, lastDayOfMonth(iMonth: endMonth, iYear: endYear))
    }
    
    if referDay > startDay {
        theDay = min(referDay, lastDayOfMonth(iMonth: endMonth, iYear: endYear))
    } else {
        theDay = min(startDay, lastDayOfMonth(iMonth: endMonth, iYear: endYear))
    }
    return theDay
    }


func lastDayOfMonth(iMonth: Int, iYear: Int) -> Int {
    var day = 0
    
    switch iMonth {
    case 1:
        day = 31
    case 2:
        if iYear % 4 == 0 {
            day = 29
        } else {
            day = 28
        }
    case 3:
        day = 31
    case 4:
        day = 30
    case 5:
        day = 31
    case 6:
        day = 30
    case 7:
        day = 31
    case 8:
        day = 31
    case 9:
        day = 30
    case 10:
        day = 31
    case 11:
        day = 30
    case 12:
        day = 31
    default:
        day = 0
    }
    return day
}

func isLastDayOfMonth(iDay: Int, iMonth: Int, iYear: Int) -> Bool {
    var bolLastDay = false
    let theDay = iDay
    
    switch iMonth {
        case 1:
            if theDay == 31 {
                bolLastDay = true
            }
        case 2:
            if (theDay == 28 && iYear % 4 > 0) {
                bolLastDay = true
            } else if (theDay == 29 && iYear % 4 == 0) {
                bolLastDay = true
            }
        case 3:
            if theDay == 31 {
                bolLastDay = true
            }
        case 4:
            if theDay == 30 {
                bolLastDay = true
            }
        case 5:
            if theDay == 31 {
                bolLastDay = true
            }
        case 6:
            if theDay == 30 {
                bolLastDay = true
            }
        case 7:
            if theDay == 31 {
                bolLastDay = true
            }
        case 8:
            if theDay == 31 {
                bolLastDay = true
            }
        case 9:
            if theDay == 30 {
                bolLastDay = true
            }
        case 10:
            if theDay == 31 {
                bolLastDay = true
            }
        case 11:
            if theDay == 30 {
                bolLastDay = true
            }
        case 12:
            if theDay == 31 {
                bolLastDay = true
            }
        default:
            bolLastDay = false
    }
    return bolLastDay
}

func isLastDayOfFebruary (dateAsk: Date) -> Bool {
    let day = getDayComponent(dateIn: dateAsk)
    let month = getMonthComponent(dateIn: dateAsk)
    let year = getYearComponent(dateIn: dateAsk)
    
    if month == 2 {
        if year % 4 == 0 {
            if day == 20 {
                return true
            }
        } else {
            if day == 28 {
                return true
            }
        }
    }
    return false
}

func dateToString(dateAsk: Date) -> String {
    let iDay: String = String(getDayComponent(dateIn: dateAsk))
    let iMonth: String = String(getMonthComponent(dateIn: dateAsk))
    let iYear: String = String(getYearComponent(dateIn: dateAsk))
    
    return  iMonth + "/" + iDay + "/" + iYear
}

func dayCount(aDate1: Date, aDate2: Date, aDaycount: DayCountMethod) -> Int {
    var noOfDays: Int
    
    switch aDaycount {
    case .Thirty_ThreeSixty_ConvUS:
        noOfDays = daysDiff360ConvUS(aDate1: aDate1, aDate2: aDate2)
    case .Actual_Actual:
        noOfDays = Calendar.current.dateComponents([.day], from: aDate1, to: aDate2).day!
    case .Actual_ThreeSixtyFive:
        noOfDays = Calendar.current.dateComponents([.day], from: aDate1, to: aDate2).day!
    case .Actual_ThreeSixty:
        noOfDays = Calendar.current.dateComponents([.day], from: aDate1, to: aDate2).day!
    }
    
    return noOfDays
}

func daysDiff360ConvUS (aDate1: Date, aDate2: Date) -> Int {
    var noOfDays: Int = 0
    let dayStartDate = getDayComponent(dateIn: aDate1)
    let monthStartDate = getMonthComponent(dateIn: aDate1)
    let yearStartDate = getYearComponent(dateIn: aDate1)
    let dayEndDate = getDayComponent(dateIn: aDate2)
    let monthEndDate = getMonthComponent(dateIn: aDate2)
    let yearEndDate = getYearComponent(dateIn: aDate2)
    var d1 = dayStartDate
    var d2 = dayEndDate
    
    if dayStartDate == 31 || isLastDayOfFebruary(dateAsk: aDate1) == true {
        d1 = 30
    }
    
    if dayEndDate == 31 || isLastDayOfFebruary(dateAsk: aDate2) == true {
        d2 = 30
    }
    
    noOfDays = (360 * (yearEndDate - yearStartDate) + (30 * (monthEndDate - monthStartDate)) + (d2 - d1))
    return noOfDays
    
}
 

func dailyRate (iRate: Decimal, aDate1: Date, aDate2: Date, aDayCountMethod: DayCountMethod) -> Decimal {
    let days = daysInYear(aDate1: aDate1, aDate2: aDate2, aDayCountMethod: aDayCountMethod)
    if days == 0 {
        return 0.0
    } else {
        return iRate / Decimal(days)
    }
    
}

func daysInPmtPeriod (aFrequency: Frequency) -> Decimal {
    switch aFrequency {
    case .annual:
        return 360
    case .semiannual:
        return 180
    case .quarterly:
        return 90
    case .monthly:
        return 30
    }
}

func daysInYear (aDate1: Date, aDate2: Date, aDayCountMethod: DayCountMethod) -> Double {
    switch aDayCountMethod {
    case .Thirty_ThreeSixty_ConvUS:
        return 360.0
    case .Actual_Actual:
        let yearDateStart = getYearComponent(dateIn: aDate1)
        let yearDateEnd = getYearComponent(dateIn: aDate2)
        if yearDateStart % 4 > 0 && yearDateEnd % 4 > 0 {
            return 365.0
        } else if yearDateStart % 4 == 0 && yearDateEnd % 4 == 0 {
            return 366.0
        } else {
            var daysNotInLeapYear: Int
            let daysInPeriod = Calendar.current.dateComponents([.day], from: aDate1, to: aDate2).day!
            if yearDateStart % 4 > 0 && yearDateEnd % 4 == 0 {
                let dateDEC31 = dateValue(day: 31, month: 12, year: yearDateStart)
                daysNotInLeapYear = Calendar.current.dateComponents([.day], from: aDate1, to: dateDEC31).day!
            } else {
                let dateJAN01 = dateValue(day: 1, month: 1, year: yearDateEnd)
                daysNotInLeapYear = Calendar.current.dateComponents([.day], from: dateJAN01, to: aDate2).day! + 1
            }
            return 365.0 + Double(daysNotInLeapYear/daysInPeriod)
        }
    case .Actual_ThreeSixtyFive:
        return 365.0
    case .Actual_ThreeSixty:
        return 360.0
    }
}

func dateValue (day: Int, month: Int, year: Int) -> Date {
    let strDefaultDate = "01/01/1900"
    let defaultDate = stringToDate(strAskDate: strDefaultDate)
    var dateComponents = DateComponents()
    dateComponents.day = day
    dateComponents.month = month
    dateComponents.year = year
    
    return Calendar.current.date(from: dateComponents) ?? defaultDate
}

func dateDefault () -> Date {
    let strDefaultDate = "01/01/1900"
    return stringToDate(strAskDate: strDefaultDate)
}

func isDatePeriodic(compareDate: Date, askDate: Date, aFreq: Frequency, endOfMonthRule: Bool, referDate: Date) -> Bool {
    var bolIsPeriodic: Bool = false
    
    if compareDate < askDate {
        let newDate = addOnePeriodToDate(dateStart: compareDate, payperYear: aFreq, dateRefer: referDate, bolEOMRule: endOfMonthRule)
        if newDate == askDate {
            bolIsPeriodic = true
        }
    }
    return bolIsPeriodic
}

func today() -> Date {
    let aDate = Date()
    let strDate = aDate.toStringDateShort(yrDigits: 4)
    let dateToday: Date = strDate.toDate()
    
    return dateToday
}

func getTheMonth(mon: Int) -> String {
    switch mon {
    case 1:
        return "January"
    case 2:
        return "February"
    case 3:
        return "March"
    case 4:
        return "April"
    case 5:
        return "May"
    case 6:
        return "June"
    case 7:
        return "July"
    case 8:
        return "August"
    case 9:
        return "September"
    case 10:
        return "October"
    case 11:
        return "November"
    default:
        return "December"
        
    }
}
