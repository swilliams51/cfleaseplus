//
//  LessePaidFeeView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct LesseePaidFeeView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Binding var showMenu: ShowMenu
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @State private var solveForImplicit: Bool = false
    @State var feePaid: String = "0.00"
    @State var amountOnEntry: String = "0.00"
    @State var rateOnEntry: String = "0.05"
    @State var customerRate: String = "0.05"
    @State var editAmountStarted: Bool = false
    @State var editRateStarted: Bool = false
    @State var showPopover: Bool = false
    @State var myImplicitRateHelp: Help = implicitRateHelp
    @State var strRate: String = "implicit"
    
    @FocusState private var amountIsFocused: Bool
    @FocusState private var rateIsFocused: Bool
    private let pasteBoard = UIPasteboard.general
    
    var calculatedColor: Color = Color.theme.calculated
    var defaultActive: Color = Color.theme.active
    var defaultInactive: Color = Color.theme.inActive
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Fee Paid at Funding").font(.footnote),footer: (Text("Interest Rate: \(myLease.interestRate.toDecimal().toPercent(3))"))) {
                    solveForRow
                    feePaidRow
                    implicitRateRow
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                    textButtonsForCancelAndDoneRow
                }
            }
            .navigationTitle("Customer Paid Fee")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    decimalPadButtonItems
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
           viewOnAppear()
        }
        .alert(isPresented: $showAlert, content: getAlert)
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $myImplicitRateHelp, isDark: $isDark)
        }
    }
    
    var decimalPadButtonItems: some View {
        HStack {
            cancelDecimalPadButton(cancel: {
                updateForCancel()
            }, isDark: $isDark)
            
            Spacer()
            helpDecimalPadItem(isDark: $isDark)
            
            copyDecimalPadButton(copy: {
                copyToClipboard()
            })

            pasteDecimalPadButton(paste: {
                paste()
            })
            
            clearDecimalPadButton(clear: {
                clearAllText()
            }, isDark: isDark)

            Spacer()
            enterDecimalPadButton(enter: {
                updateForSubmit()
            }, isDark: $isDark)
        }
    }
    
    var solveForRow: some View {
        HStack {
            Text(solveForImplicit ? "solve for fee:" : "solve for \(strRate):")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            Toggle("", isOn: $solveForImplicit)
        }
    }

    var feePaidRow: some View {
        HStack{
            Text(solveForImplicit ? "calculated fee:" : "fee amount: \(Image(systemName: "return"))")
                .font(.subheadline)
                .foregroundColor(solveForImplicit ? calculatedColor : defaultActive)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $feePaid,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        editAmountStarted = true
                    }})
                    .disabled(solveForImplicit ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($amountIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(amountFormatted(editStarted: editAmountStarted))")
                    .font(.subheadline)
                    .foregroundColor(solveForImplicit ? calculatedColor : defaultActive)
            }
        }
    }
    
    var implicitRateRow: some View {
        HStack{
            Text(solveForImplicit ? "\(strRate): \(Image(systemName: "return"))" : "calculated \(strRate):")
                .font(.subheadline)
                .foregroundColor(solveForImplicit ? defaultActive : calculatedColor)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $customerRate,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        editRateStarted = true
                    }})
                    .disabled(solveForImplicit ? false : true)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($rateIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(implicitFormatted(editStarted: editRateStarted))")
                    .font(.subheadline)
                    .foregroundColor(solveForImplicit ? defaultActive : calculatedColor)
            }
        }
    }
    
    var textButtonsForCancelAndDoneRow: some View {
        HStack{
            Text("Cancel")
                .disabled(keyboardActive())
                .font(.subheadline)
                .foregroundColor(keyboardActive() ? .gray : .accentColor)
                .onTapGesture {
                    if keyboardActive() == false {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            Spacer()
            Text("Done")
                .disabled(keyboardActive())
                .font(.subheadline)
                .foregroundColor(keyboardActive() ? .gray : .accentColor)
                .onTapGesture {
                    if keyboardActive() == false {
                        self.myLease.resetLesseeObligations()
                        self.showMenu = .closed
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func getMaxFee() -> Decimal {
        let tempLease = myLease.clone()
        let tempCashflow: Cashflows = Cashflows(aLease: tempLease, returnType: .principal)
        let npv = tempCashflow.XNPV(aDiscountRate: myLease.interestRate.toDecimal() * 2.0, aDayCountMethod: tempLease.interestCalcMethod)
        let maxFee: Decimal = (tempLease.amount.toDecimal() - npv)
        
        return maxFee
    }
    
    func amountFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return feePaid
        } else {
            return feePaid.toDecimal().toCurrency(false)
        }
    }
    
    func implicitFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return customerRate
        } else {
            return customerRate.toDecimal().toPercent(3)
        }
    }
    
    func percentToAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * myLease.amount.toDecimal()
        return decAmount.toString(decPlaces: 2)
    }

    func setCustomerRate() {
        let tempLease = myLease.clone()
        tempLease.lesseePaidFee = self.feePaid
        let rate: Decimal = tempLease.implicitRate()
        
        self.customerRate = rate.toString(decPlaces: 5)
    }
    
    func setLesseePaidFee() {
        let tempLease = myLease.clone()
        let tempCashflow: Cashflows = Cashflows(aLease: tempLease, returnType: .principal)
        let npv = tempCashflow.XNPV(aDiscountRate: self.customerRate.toDecimal(), aDayCountMethod: tempLease.interestCalcMethod)
        
        var newFee: Decimal = (tempLease.amount.toDecimal() - npv)
        if amountsAboutEqual(aAmt1: npv, aAmt2: tempLease.amount.toDecimal(), pctDiff: 0.005) == true {
            newFee = 0.00
        }
        self.feePaid = newFee.toString(decPlaces: 4)
    }
    
    func updateForNewFeeAmount() {
        editAmountStarted = false
        if self.feePaid.toDecimal() < 1.0 {
            self.feePaid = percentToAmount(percent: self.feePaid)
        }
        
        let maximumFee: Decimal = getMaxFee()
        if isAmountValid(strAmount: feePaid, decLow: 0.0, decHigh: maximumFee, inclusiveLow: true, inclusiveHigh: true) == false {
            feePaid = amountOnEntry
            alertTitle = alertValidFeeAmount
            showAlert.toggle()
        }
        setCustomerRate()
    }
    
    func updateForNewImplicit() {
        editRateStarted = false
        let maxImplicit: Decimal = self.myLease.interestRate.toDecimal() * 2.0
        if isInterestRateValid(strRate: self.customerRate, decLow: myLease.interestRate.toDecimal(), decHigh: maxImplicit, inclusiveLow: true, inclusiveHigh: true) == false {
            self.customerRate = self.rateOnEntry
            alertTitle = alertValidImplicit
            showAlert.toggle()
        }
        self.setLesseePaidFee()
    }
    
    func clearAllText() {
        if self.amountIsFocused == true {
            self.feePaid = ""
        } else {
            self.customerRate = ""
        }
    }
    
    func copyToClipboard() {
        if self.amountIsFocused {
            pasteBoard.string = self.feePaid
        } else {
            pasteBoard.string = self.customerRate
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.amountIsFocused {
                    self.feePaid = string
                } else {
                    self.customerRate = string
                }
            }
        }
    }
    
    func updateForCancel() {
        if self.editAmountStarted == true {
            self.feePaid = self.amountOnEntry
            self.editAmountStarted = false
            updateForNewFeeAmount()
        }
        
        if self.editRateStarted == true {
            self.customerRate = self.rateOnEntry
            self.editRateStarted = false
            updateForNewImplicit()
        }
        self.amountIsFocused = false
        self.rateIsFocused = false
    }
    
    func updateForSubmit() {
        if editAmountStarted == true {
           updateForNewFeeAmount()
        }
        if editRateStarted == true {
            updateForNewImplicit()
        }
        self.amountIsFocused = false
        self.rateIsFocused = false
    }
    
    func keyboardActive() -> Bool {
        if amountIsFocused == true || rateIsFocused == true {
            return true
        } else {
            return false
        }
    }
    
    func viewOnAppear() {
        self.amountOnEntry = self.myLease.lesseePaidFee
        self.feePaid = self.myLease.lesseePaidFee
        self.customerRate = self.myLease.implicitRate().toString(decPlaces: 5)
        self.rateOnEntry = self.customerRate
        if self.myLease.operatingMode == .lending {
            self.strRate = "APR"
        }
    }
    
}


    
struct LesseePaidFeeView_Previews: PreviewProvider {
    static var previews: some View {
        LesseePaidFeeView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false), showMenu: .constant(.closed))
            .preferredColorScheme(.dark)
    }
}

let alertValidFeeAmount: String = "The fee amount must be equal to or greater than zero and less than the lease amount!!"
let alertValidImplicit: String = "The implicit rate must equal to or greater than the lease interest but less than the maximum interest rate!!"
