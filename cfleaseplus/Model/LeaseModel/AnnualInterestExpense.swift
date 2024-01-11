//
//  AnnualInterestExpense.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

struct AnnualInterestExpense {
    var startDate: Date
    var endDate: Date
    var interestExpense: Decimal
}

extension Lease {
    func getAnnualInterestExpense() -> [AnnualInterestExpense] {
        var myTableOfInterest = getYearEndDates(leaseStartDate: fundingDate, leaseEndDate: getMaturityDate())
        //create amortization object
        self.setAmortizationsFromLease()
        let myLeaseCFs: Cashflows = Cashflows(aAmortizations: self.amortizations)
        myLeaseCFs.consolidateCashflows()

        var y: Int = 0
        var x: Int = 0
        var subTotal: Decimal = 0.0
        while x < myTableOfInterest.count {
            while myLeaseCFs.items[y].dueDate <= myTableOfInterest[x].endDate  {
                subTotal = subTotal + myLeaseCFs.items[y].amount
                if y == myLeaseCFs.items.count - 1 {
                    break
                }
                y = y + 1
            }
            if y == myLeaseCFs.items.count - 1 && x == myTableOfInterest.count - 1 {
                myTableOfInterest[x].interestExpense = subTotal
                break
            } else if y == myLeaseCFs.items.count - 1 && x < myTableOfInterest.count - 1 {
                let nextInterestAmount: Decimal = myLeaseCFs.items[y].amount
                let perDiem = dailyInterest(interestAmount: nextInterestAmount, daysInPeriod: daysBetween(start: myLeaseCFs.items[y - 1].dueDate, end: myLeaseCFs.items[y].dueDate))
                let noOfDaysInStub = daysBetween(start: myLeaseCFs.items[y - 1].dueDate, end: myTableOfInterest[x].endDate)
                let stubInterest = perDiem * Decimal(noOfDaysInStub)
                subTotal = subTotal + stubInterest
                myTableOfInterest[x].interestExpense = subTotal
                let remainder = nextInterestAmount - stubInterest
                x+=1
                myTableOfInterest[x].interestExpense = remainder
                break
            } else {
                let nextInterestAmount: Decimal = myLeaseCFs.items[y].amount
                let perDiem = dailyInterest(interestAmount: nextInterestAmount, daysInPeriod: daysBetween(start: myLeaseCFs.items[y - 1].dueDate, end: myLeaseCFs.items[y].dueDate))
                let noOfDaysInStub = daysBetween(start: myLeaseCFs.items[y - 1].dueDate, end: myTableOfInterest[x].endDate)
                let stubInterest = perDiem * Decimal(noOfDaysInStub)
                subTotal = subTotal + stubInterest
                myTableOfInterest[x].interestExpense = subTotal
                subTotal = nextInterestAmount - stubInterest
                y+=1
                x+=1
            }
        }
        self.amortizations.items.removeAll()

        return myTableOfInterest
    }
}

func dailyInterest(interestAmount: Decimal, daysInPeriod: Int) -> Decimal {
    return interestAmount / Decimal(daysInPeriod)
}

func getYearEndDates(leaseStartDate: Date, leaseEndDate: Date) -> [AnnualInterestExpense] {
    var myStartDate: Date = leaseStartDate
    var myEndDate: Date = dateValue(day: 31, month: 12, year: getYearComponent(dateIn: myStartDate))
    var myAnnualDates: [AnnualInterestExpense] = [AnnualInterestExpense(startDate: myStartDate, endDate: myEndDate, interestExpense: 0.00)]

    while myEndDate < leaseEndDate {
        myStartDate = Calendar.current.date(byAdding: .day, value: 1, to: myEndDate)!
        myEndDate = dateValue(day: 31, month: 12, year: getYearComponent(dateIn: myStartDate))
        let myDates = AnnualInterestExpense(startDate: myStartDate, endDate: myEndDate, interestExpense: 0.00)
        myAnnualDates.append(myDates)
    }

    return myAnnualDates
}
