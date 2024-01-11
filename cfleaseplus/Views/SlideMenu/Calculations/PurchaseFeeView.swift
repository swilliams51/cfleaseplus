//
//  PurchaseFeeView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct PurchaseView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var solveForBuyRate: Bool = false
    @State private var buyRate: String = "0.035"
    @State private var feePaid: String = "20000.00"
    @State private var editFeeStarted: Bool = false
    @State private var editRateStarted: Bool = false
    @State private var buyRateOnEntry: String = "0.00"
    @State private var feePaidOnEntry: String = "0.00"
    @State private var decPlaces: Int = 2
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @State var showPopover: Bool = false
    @State var myPurchaseHelp = purchaseHelp
    
    @FocusState private var amountIsFocused: Bool
    @FocusState private var rateIsFocused: Bool
    private let pasteBoard = UIPasteboard.general

    var calculatedColor: Color = Color.theme.calculated
    var defaultActive: Color = Color.theme.active
    var defaultInactive: Color = Color.theme.inActive
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("BuyRate/Fee Paid").font(.footnote),
                        footer: (Text("Interest Rate: \(myLease.interestRate.toDecimal().toPercent(3))"))) {
                    solveForRow
                    buyRateRow
                    feePaidRow
                }
               
                Section(header: Text("Submit Form").font(.footnote)) {
                    textButtonsForCancelAndDoneRow
                }
                
            }
            .navigationTitle("Buy/Sell Parameters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItemGroup (placement: .keyboard) {
                    decimalPadButtonItems
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            viewOnAppear()
        }
        .alert(isPresented: $showAlert, content: getAlert)
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $myPurchaseHelp, isDark: $isDark)
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
            Text(solveForBuyRate ? "solve for buy rate:" : "solve for fee:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            Toggle("", isOn: $solveForBuyRate)
        }
    }
    
    var feePaidRow: some View {
        HStack{
            Text(solveForBuyRate ? "enter fee paid: \(Image(systemName: "return"))" : "calculated fee:")
                .font(.subheadline)
                .foregroundColor(solveForBuyRate ? defaultActive : calculatedColor)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                  text: $feePaid,
                  onEditingChanged: { (editing) in
                    if editing == true {
                        self.editFeeStarted = true
                        self.decPlaces = 4
                }})
                    .disabled(solveForBuyRate ? false : true)
                    .focused($amountIsFocused)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(feePaidFormatted(editStarted: editFeeStarted))")
                    .font(.subheadline)
                    .foregroundColor(solveForBuyRate ? defaultActive : calculatedColor)
            }
        }
        
    }
    
    var buyRateRow: some View {
        HStack{
            Text(solveForBuyRate ? "calculated buy rate:" : " enter buy rate: \(Image(systemName: "return"))")
                .font(.subheadline)
                .foregroundColor(solveForBuyRate ? calculatedColor : defaultActive)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                  text: $buyRate,
                  onEditingChanged: { (editing) in
                    if editing == true {
                        self.editRateStarted = true
                }})
                    .disabled(solveForBuyRate ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($rateIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\((buyRateFormatted(editStarted: editRateStarted)))")
                    .font(.subheadline)
                    .foregroundColor(solveForBuyRate ? calculatedColor : defaultActive)
            }
        }
    }
    
    var textButtonsForCancelAndDoneRow: some View {
        HStack {
            Text("Cancel")
                .disabled(decimalpadIsActive())
                .font(.subheadline)
                .foregroundColor(decimalpadIsActive() ? .gray : .accentColor)
                .onTapGesture {
                    if decimalpadIsActive() == false {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            Spacer()
            Text("Done")
                .disabled(decimalpadIsActive())
                .font(.subheadline)
                .foregroundColor(decimalpadIsActive() ? .gray : .accentColor)
                .onTapGesture {
                    if decimalpadIsActive() == false {
                        self.myLease.purchaseFee = self.feePaid
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        }
        
    }

    func getAlert() -> Alert{
        return Alert(title: Text(self.alertTitle))
    }
    
    func getMaxPremium () -> Decimal {
        return self.myLease.getNetAmount()
    }
    func getMaxBuyRate() -> Decimal {
        let decPremium: Decimal = 0.05
        return self.myLease.interestRate.toDecimal() + decPremium
    }
    
    func decimalpadIsActive() -> Bool {
        var padIsActive: Bool = false
        if amountIsFocused == true || rateIsFocused == true {
            padIsActive = true
        }
        
        return padIsActive
    }
    
    func feePaidFormatted (editStarted: Bool) -> String {
        var strReturn: String = ""
        if editStarted == true {
            strReturn = self.feePaid.toTruncDecimalString(decPlaces: 7)
        } else {
            strReturn = self.feePaid.toDecimal().toCurrency(false)
        }
        
        return strReturn
    }
    func buyRateFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return self.buyRate.toTruncDecimalString(decPlaces: 6)
        } else {
            return self.buyRate.toDecimal().toPercent(3)
        }
    }
    
    func percentToPremiumAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * self.myLease.amount.toDecimal()
        return decAmount.toString(decPlaces: 2)
    }
    
    func clearAllText() {
        if self.amountIsFocused == true {
            self.feePaid = ""
        } else {
            self.buyRate = ""
        }
    }
    
    func copyToClipboard() {
        if self.amountIsFocused {
            pasteBoard.string = self.feePaid
        } else {
            pasteBoard.string = self.buyRate
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.amountIsFocused {
                    self.feePaid = string
                } else {
                    self.buyRate = string
                }
            }
        }
    }
    
    func updateForCancel() {
        if editFeeStarted == true {
            self.feePaid = self.feePaidOnEntry
            self.editFeeStarted = false
            updateForNewFee()
        }
        if editRateStarted == true {
            self.buyRate = self.buyRateOnEntry
            self.editRateStarted = false
            updateForNewBuyRate()
        }
        amountIsFocused = false
        rateIsFocused = false
    }
    
    func updateForSubmit() {
        if editFeeStarted == true {
            updateForNewFee()
        }
        if editRateStarted == true {
           updateForNewBuyRate()
        }
        amountIsFocused = false
        rateIsFocused = false
    }
    
    
    func updateForNewFee() {
        self.editFeeStarted = false
        
        if self.feePaid.toDecimal() < 1.0 {
            self.feePaid = percentToPremiumAmount(percent: self.feePaid)
        }
        
        if isAmountValid(strAmount: feePaid, decLow: 0.0, decHigh: getMaxPremium(), inclusiveLow: true, inclusiveHigh: true) == false {
            alertTitle = alertValidFeeAmount
            showAlert.toggle()
            self.feePaid = self.feePaidOnEntry
        }
        self.buyRate = self.myLease.getBuyRate(aPremiumPaid: feePaid, afterLesseeFee: false)
    }
    
    func updateForNewBuyRate() {
        self.editRateStarted = false
        if isInterestRateValid(strRate: buyRate, decLow: 0.0, decHigh: getMaxBuyRate(), inclusiveLow: true, inclusiveHigh: true) == false {
            alertTitle = alertValidBuyRate
            showAlert.toggle()
            self.buyRate = self.buyRateOnEntry
        } else {
            self.feePaid = self.myLease.getPremiumPaid(aBuyRate: buyRate)
        }
    }
    
    private func viewOnAppear() {
        if self.myLease.purchaseFee.toDecimal() != 0.0 {
            self.feePaid = self.myLease.purchaseFee
            self.buyRate = self.myLease.getBuyRate(aPremiumPaid: feePaid, afterLesseeFee: false)
            
        } else {
            let decFeePaid: Decimal = self.myLease.amount.toDecimal() * 0.0
            self.feePaid = decFeePaid.toString().toTruncDecimalString(decPlaces: decPlaces)
            self.buyRate = self.myLease.getBuyRate(aPremiumPaid: feePaid, afterLesseeFee: false)
        }
        self.feePaidOnEntry = self.feePaid
        self.buyRateOnEntry = self.buyRate
    }
        
}

struct Purchase_Previews: PreviewProvider {

    static var previews: some View {
       
        PurchaseView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
                .preferredColorScheme(.dark)
       
    }
}


let alertValidBuyFeeAmount: String = "The fee must be equal to or greater than zero and less than the total amount of interest!!"
let alertValidBuyRate: String = "The buy rate must be equal to or greater than zero and less than or equal to the Lease interest rate!!"
