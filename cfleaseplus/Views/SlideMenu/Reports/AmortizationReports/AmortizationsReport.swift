//
//  AmortizationsReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct AmortizationsReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var reportTitle: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var leaseCashflows: Cashflows = Cashflows()
    @State private var leaseAmortizations: Amortizations = Amortizations()
    @State private var discountRate: Decimal = 0.10
    @State private var dayCountMethod: DayCountMethod = .Actual_Actual

    @State private var combineDates: Bool = false
    @State private var combineDatesLabel: String = "Combine Dates Off"
    @State private var combineDatesImage: String = "square"
    
    @State private var buyerPaidFeeCashflows: Cashflows = Cashflows()
    @State private var buyerPaidFee: Bool = false
    @State private var buyerPaidFeeAdded: Bool = false
    @State private var includeBuyerPaidFee: Bool = false
    @State private var includeBuyerPaidFeeLabel: String = "Incl Buyer Paid Fee"
    @State private var includeBuyerPaidFeeImage: String = "square"
    
    @State private var exportAmortLabel: String = "Export as CSV"
    @State private var exportAmortImage: String = "square.and.arrow.up"
    
    @State private var lesseePaidFeeCashflows: Cashflows = Cashflows()
    @State private var lesseePaidFee: Bool = false
    @State private var lesseePaidFeeAdded: Bool = false
    @State private var includeLesseeFee: Bool = false
    @State private var includeLesseeFeeLabel: String = "Incl Customer Paid Fee"
    @State private var includeLesseeFeeImage: String = "square"
    
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var exportCounter: Int = 0
    
    @State private var myFont: Font = reportFontSmall
    @State private var maxChars: Int = reportWidthSmall
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    Text("\(orientation.isLandscape.toString())")
                        .foregroundColor(.clear)
                    Text(textForOneAmortizations(aAmount: myLease.amount.toDecimal(), aAmortizations: leaseAmortizations, interestRate: discountRate.toString(decPlaces: 6), dayCountMethod: dayCountMethod, currentFile: currentFile, isPad: isPad, isLandscape: orientation.isLandscape))
                        .font(self.myFont)
                        .foregroundColor(isDark ? .white : .black)
                        .textSelection(.enabled)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
                .navigationTitle(reportTitle)
                .toolbar {
                    Menu("options") {
                        combineDatesButtonItem
                        buyerPaidFeeButtonItem
                            .disabled(buyerPaidFeeButtonDisabled() ? true : false)
                        lesseePaidFeeButtonItem
                            .disabled(lesseePaidFeeButtonDisabled() ? true : false)
                        exportAmortButtonItem
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
            .environment(\.colorScheme, isDark ? .dark : .light)
            .alert(isPresented: $showAlert, content: getAlert)
            .onAppear{
                
                if (myLease.fees?.totalCustomerPaidFees() ?? 0.0) > 0.0 {
                    lesseePaidFeeCashflows = Cashflows(aFees: myLease.fees!, aFeeType: .customerPaid)
                    self.lesseePaidFee = true
                }
                
                if (myLease.fees?.totalPurchaseFees() ?? 0.0) > 0.0 {
                    buyerPaidFeeCashflows = Cashflows(aFees: myLease.fees!, aFeeType: .purchase)
                    self.buyerPaidFee = true
                }
                
                self.dayCountMethod = myLease.interestCalcMethod
                self.leaseCashflows = Cashflows(aLease: self.myLease)
                self.discountRate = self.leaseCashflows.XIRR2(guessRate: 0.10, _DayCountMethod: self.dayCountMethod)
                self.leaseAmortizations = getAmortizationsFromCashflow(aCashflows: self.leaseCashflows, decAnnualRate: self.discountRate, aDayCount: self.dayCountMethod)
                
                if self.isPad == true {
                    self.myFont = reportFontTiny
                    self.maxChars = reportWidthTiny
                }
            }
            .onDisappear {
                self.myLease.amortizations.items.removeAll()
            }
            .onRotate { newOrientation in
                self.orientation = newOrientation
            }
        }
    }
    var combineDatesButtonItem: some View {
        Button(action: {
            if self.combineDates == false {
                self.combineDates = true
                self.combineDatesLabel = "Combine Dates On"
                self.combineDatesImage = "checkmark.square"
                self.consolidateLeaseCashflow()
            } else {
                self.combineDates = false
                self.combineDatesLabel = "Combine Dates Off"
                self.combineDatesImage = "square"
                self.resetLeaseCashflows()
            }
        }) {
            HStack {
                Text(combineDatesLabel)
                Image(systemName: combineDatesImage)
            }
        }
    }
    
    var buyerPaidFeeButtonItem: some View {
        Button(action: {
          if self.includeBuyerPaidFee == false {
              self.includeBuyerPaidFee = true
              self.includeBuyerPaidFeeImage = "checkmark.square"
              self.addBuyerPaidFee()
          } else {
              self.includeBuyerPaidFee = false
              self.includeBuyerPaidFeeImage = "square"
              self.removeBuyerPaidFee()
          }
      }) {
          HStack {
              Text(includeBuyerPaidFeeLabel)
              Image(systemName: includeBuyerPaidFeeImage)
          }
          }
    }
    
    var lesseePaidFeeButtonItem: some View {
      Button(action: {
        if self.includeLesseeFee == false {
            self.includeLesseeFee = true
            self.includeLesseeFeeImage = "checkmark.square"
            self.addLesseeFee()
        } else {
            self.includeLesseeFee = false
            self.includeLesseeFeeImage = "square"
            self.removeLesseeFee()
        }
    }) {
        HStack {
            Text(includeLesseeFeeLabel)
            Image(systemName: includeLesseeFeeImage)
        }
        }
    }
    
    var exportAmortButtonItem: some View {
        Button(action: {
            exportCounter += 1
            let csvFile: String = csvForOneAmortization(aAmount: myLease.amount.toDecimal(), aAmortizations: leaseAmortizations, interestRate: discountRate.toString(decPlaces: 6), daycountMethod: dayCountMethod, reportTitle: reportTitle)
            let fileName: String = currentFile + exportCounter.toString() + ".csv"
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
     
            do {
                    try csvFile.write(to: url, atomically: true, encoding: .utf8)
                    self.alertTitle = csvAmortizationSuccess(strFileName: fileName)
                    self.showAlert.toggle()
                } catch {
                    print(error.localizedDescription)
                }
      }) {
          HStack {
              Text(exportAmortLabel)
              Image(systemName: exportAmortImage)
          }
          }
    }
    
    func addBuyerPaidFee() {
        self.leaseCashflows = self.leaseCashflows.addCashflow(aCFs: buyerPaidFeeCashflows)
        self.leaseCashflows.consolidateCashflows()
        self.calculateLeaseAmortizations()
        self.buyerPaidFeeAdded = true
    }
    
    func removeBuyerPaidFee() {
        self.leaseCashflows = self.leaseCashflows.subtractCashflow(aCFs: buyerPaidFeeCashflows)
        self.leaseCashflows.consolidateCashflows()
        self.calculateLeaseAmortizations()
        self.buyerPaidFeeAdded = false
    }
    
    func addLesseeFee() {
        self.leaseCashflows = self.leaseCashflows.addCashflow(aCFs: lesseePaidFeeCashflows)
        self.leaseCashflows.consolidateCashflows()
        self.calculateLeaseAmortizations()
        self.lesseePaidFeeAdded = true
    }
    
    func removeLesseeFee() {
        self.leaseCashflows = self.leaseCashflows.subtractCashflow(aCFs: lesseePaidFeeCashflows)
        self.leaseCashflows.consolidateCashflows()
        self.calculateLeaseAmortizations()
        self.lesseePaidFeeAdded = false
    }
    
    func indexOfRemoved(lesseeFeeIsAsking: Bool) -> Int {
        if lesseePaidFeeAdded == true && buyerPaidFeeAdded == false {
            return 1
        }
        if lesseePaidFeeAdded == false && buyerPaidFeeAdded == true {
            return 1
        }
        if lesseePaidFeeAdded == true && buyerPaidFeeAdded == true {
            if lesseeFeeIsAsking == true {
                if leaseCashflows.items[1].amount > 0.0 {
                    return 1
                } else {
                    return 2
                }
            } else {
                if leaseCashflows.items[1].amount < 0.0 {
                    return 1
                } else {
                    return 2
                }
            }
        }
        return 0
    }
   
    func consolidateLeaseCashflow() {
        self.leaseCashflows.consolidateCashflows()
        calculateLeaseAmortizations()
    }
    
    func resetLeaseCashflows() {
        self.leaseAmortizations.items.removeAll()
        self.leaseCashflows = Cashflows(aLease: self.myLease)
        self.discountRate = self.leaseCashflows.XIRR2(guessRate: 0.10, _DayCountMethod: self.dayCountMethod)
        self.leaseAmortizations = getAmortizationsFromCashflow(aCashflows: self.leaseCashflows, decAnnualRate: self.discountRate, aDayCount: self.dayCountMethod)
        
        if self.includeBuyerPaidFee == true {
            addBuyerPaidFee()
        }
        if self.lesseePaidFeeAdded == true {
            addLesseeFee()
        }
    }
    
    func buyerPaidFeeButtonDisabled() -> Bool {
        if self.buyerPaidFee == false {
            return true
        }
        
        if reportTitle.contains("Balance") == true {
            return true
        }
        return false
    }
    
    func lesseePaidFeeButtonDisabled() -> Bool {
        if self.lesseePaidFee == false {
            return true
        }
        if reportTitle.contains("Balance") {
            return true
        }
        return false
    }
    
    func calculateLeaseAmortizations() {
        self.leaseAmortizations.items.removeAll()
        self.discountRate = leaseCashflows.XIRR2(guessRate: 0.10, _DayCountMethod: self.dayCountMethod)
        self.leaseAmortizations = getAmortizationsFromCashflow(aCashflows: self.leaseCashflows, decAnnualRate: self.discountRate, aDayCount: self.dayCountMethod)
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func csvAmortizationSuccess(strFileName: String) -> String {
        let alert: String = "The current amortization report for the file \(strFileName) was successfully exported to the user's Documents folder as a csv file. To locate file select Browse/On My iPhone/CFLease. It can be opened in Numbers or Excel."
        
        return alert
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
}

struct AmortizationsView_Previews: PreviewProvider {
    
    static var previews: some View {
        AmortizationsReport(myLease: Lease(aDate: today(), mode: .leasing),currentFile: .constant("file is new"), reportTitle: .constant("Amortization"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}
