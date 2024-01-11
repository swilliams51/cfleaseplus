//
//  OneGroupView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct OneGroupView: View {
    @State var myGroup: Group
    @State var myGroups: Groups
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @State private var index = 0
    @State private var count = 0
    
    @State private var isInterimGroup: Bool = false
    @State private var isResidualGroup: Bool = false
    @State private var isCalculatedPayment: Bool = false
    
    @State private var editStarted: Bool = false
    @State private var noOfPayments: Double = 1.0
    @State private var startingNoOfPayments: Double = 120.0
    @State private var startingTotalPayments: Double = 120.0
    @State private var pmtTextFieldIsLocked: Bool = false
    @State private var paymentOnEntry: String = "0.0"
    @State private var sliderIsLocked: Bool = false
    @State private var rangeOfPayments: ClosedRange<Double> = 1.0...120.0
    @State private var timingIsLocked: Bool = false
    @State private var maximumAmount: Decimal = 1.0
   
    @State var showPopover: Bool = false
    @State var payHelp = paymentAmountHelp
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
   
    @FocusState private var amountIsFocused: Bool
    private let pasteBoard = UIPasteboard.general
   
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details").font(.footnote)) {
                    paymentTypeItem
                    noOfPaymentsItem
                    paymentTimingItem
                    paymentAmountItem
                    paymentLockedItem
                }
                Section(header: Text("Submit Form").font(.footnote)){
                    textButtonsForCancelAndDoneRow
                }
            }
            .navigationTitle("Payment Group")
            .navigationViewStyle(.stack)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard){
                    decimalPadButtonItems
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            viewOnAppear()
            maximumAmount = myLease.amount.toDecimal()
        }
        .alert(isPresented: $showAlert, content: getAlert)
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
    
    // Functions
    func updateForPaymentAmount() {
        if myGroup.amount == "" {
            self.myGroup.amount = "0.00"
        }
        
        if myGroup.type == .balloon  || myGroup.type == .residual {
            maximumAmount = myLease.amount.toDecimal() * 2.0
        }
        
        if self.myGroup.amount.toDecimal() > 0.00 && self.myGroup.amount.toDecimal() < 1.0 {
            self.myGroup.amount = percentToAmount(percent:  myGroup.amount)
        }
        
        if isAmountValid(strAmount: myGroup.amount, decLow: 0.0, decHigh: maximumAmount, inclusiveLow: true, inclusiveHigh: true) == false {
            self.myGroup.amount = self.paymentOnEntry
            alertTitle = alertPaymentAmount
            showAlert.toggle()
        }
        
        if myGroup.amount.toDecimal() == 0.00 {
            myGroup.locked = true
        }
            
        self.editStarted = false
    }
    
    
    var paymentTypeItem: some View {
        Picker(selection: $myGroup.type, label: Text("type:").font(.subheadline)) {
            ForEach(getPaymentTypes(), id: \.self) { paymentType in
                Text(paymentType.toString())
            }
            .onChange(of: myGroup.type, perform: { value in
                self.resetForPaymentTypeChange()
            })
            .font(myFormResultsFont)
        }
    }
    
    var noOfPaymentsItem: some View {
        VStack {
            HStack {
                Text("no. of payments:")
                    .font(.subheadline)
                Spacer()
                Text("\(myGroup.noOfPayments.toString())")
                    .font(myFormResultsFont)
            }
            Slider(value: $noOfPayments, in: rangeOfPayments, step: 1) {

            }
            .disabled(sliderIsLocked)
            .onChange(of: noOfPayments) { newNumber in
                self.myGroup.noOfPayments = newNumber.toInteger()
            }
            HStack {
                Spacer()
                Stepper("", value: $noOfPayments, in: rangeOfPayments, step: 1, onEditingChanged: { _ in
                   
                }).labelsHidden()
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
            .disabled(sliderIsLocked)
            }
        }
            
    }
    
    var paymentTimingItem: some View {
        Picker(selection: $myGroup.timing, label: Text("timing:").font(myFormLabelFont)) {
            ForEach(getTimingTypes(), id: \.self) { PaymentTiming in
                Text(PaymentTiming.toString())
                    .font(myFormResultsFont)
            }
            .onChange(of: myGroup.timing, perform: { value in
            })
        }.disabled(timingIsLocked)
    }
    
    var paymentAmountItem: some View {
        HStack{
            Text(isCalculatedPayment ? "amount:" : "amount: \(Image(systemName: "return"))")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                  text: $myGroup.amount,
                  onEditingChanged: { (editing) in
                    if editing == true {
                        self.editStarted = true
                }})
                    .disabled(pmtTextFieldIsLocked)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($amountIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(paymentFormatted(editStarted: editStarted))")
                    .font(myFormResultsFont)
            }
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $payHelp, isDark: $isDark)
        }
    }
    
    var paymentLockedItem: some View {
        Toggle(isOn: $myGroup.locked) {
            Text(myGroup.locked ? "locked:" : "unlocked:")
                .font(.subheadline)
        }
        .font(myFormResultsFont)
    }
    
    var textButtonsForCancelAndDoneRow: some View {
        HStack {
            Text("Delete")
                .disabled(amountIsFocused)
                .font(.subheadline)
                .foregroundColor(amountIsFocused ?  .gray : .accentColor )
                .onTapGesture {
                    if amountIsFocused == false {
                        deleteGroup2()
                    }
                }
            Spacer()
            Text("Done")
                .disabled(amountIsFocused)
                .font(.subheadline)
                .foregroundColor(amountIsFocused ?  .gray : .accentColor )
                .onTapGesture {
                    if amountIsFocused == false {
                        submitForm()
                    }
                }
        }
    }
    
}

struct OneGroupView_Previews: PreviewProvider {
    static var myLease: Lease = Lease(aDate: today(), mode: .leasing)
    
    static var previews: some View {
        OneGroupView(myGroup: myLease.groups.items[0], myGroups: myLease.groups, myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}

// Mark Private Functions
extension OneGroupView {
    func deleteGroup2 () {
        let result = isGroupDeletable()
        
        if result.condition == false {
            if result.message == 0 {
                self.alertTitle = alertInterimGroup
                self.showAlert.toggle()
            } else {
                self.alertTitle = alertFirstPaymentGroup
                self.showAlert.toggle()
            }
        } else {
            if isResidualGroup == true {
                self.myLease.groups.items.remove(at: index)
                self.presentationMode.wrappedValue.dismiss()
            } else {
                self.myLease.groups.items.remove(at: index)
                self.myLease.resetFirstGroup(isInterim: self.myLease.interimGroupExists())
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func isGroupDeletable() -> (condition:Bool, message: Int) {
        if self.myGroup.isInterim == true {
            return (false, 0)
        }
        
        if self.myGroup.isDefaultPaymentType() && self.myLease.groups.noOfDefaultPaymentGroups() == 1 {
            return (false, 1)
        }
         
        return (true, -1)
    }
    
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func getPaymentTypes() -> [PaymentType] {
        if self.isInterimGroup {
            if myLease.operatingMode == .lending {
                return PaymentType.interimLendingTypes
            } else {
                if myLease.groups.hasPrincipalPayments(){
                    return PaymentType.defaultTypes
                } else {
                    return PaymentType.interimTypes
                }
            }
        } else if self.isResidualGroup {
            return PaymentType.residualTypes
        } else {
            return PaymentType.defaultTypes
        }
    }
    
    func getTimingTypes() -> [PaymentTiming] {
        if myGroup.type == .residual || myGroup.type == .balloon {
            return PaymentTiming.residualCases
        } else if myGroup.type == .interest {
            return PaymentTiming.interestCases
        } else {
            return PaymentTiming.paymentCases
        }
    }
    
    func getDefaultPaymentAmount() -> String {
        var defaultAmount: String = (self.myLease.amount.toDecimal() * 0.015).toString(decPlaces: 3)
        
        if self.myLease.groups.items.count > 1 {
            for x in 0..<self.myLease.groups.items.count {
                if self.myLease.groups.items[x].amount != "CALCULATED" {
                    defaultAmount = self.myLease.groups.items[x].amount.toDecimal().toString(decPlaces: 3)
                    break
                }
            }
        }
        
        return defaultAmount
    }
    
    func percentToAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * myLease.amount.toDecimal()
        return decAmount.toString(decPlaces: 2)
    }
    
    func paymentFormatted(editStarted: Bool) -> String {
        if isCalculatedPayment == true {
            return myGroup.amount
        } else {
            if editStarted == true {
                return myGroup.amount
            }
            return myGroup.amount.toDecimal().toCurrency(false)
        }
    }
    
    func rangeNumberOfPayments () -> ClosedRange<Double> {
        let starting: Double = 1.0
        let maxNumber: Double = myLease.getMaxRemainNumberPayments(maxBaseTerm: maxBaseTerm, freq: myLease.paymentsPerYear, eom: myLease.endOfMonthRule, aRefer: myLease.firstAnniversaryDate).toDouble()
        let currentNumber:Double = myGroup.noOfPayments.toDouble()
        let ending: Double = maxNumber + currentNumber
        
        return starting...ending
    }
    
    func resetForPaymentTypeChange() {
        if myGroup.isCalculatedPaymentType() == true {
            isCalculatedPayment = true
            pmtTextFieldIsLocked = true
            myGroup.locked = true
            if myGroup.amount != "CALCULATED" {
                myGroup.amount = "CALCULATED"
            }
            if myGroup.type == .interest {
                myGroup.timing = .arrears
            }
        } else {
            isCalculatedPayment = false
            pmtTextFieldIsLocked = false
            if myGroup.amount == "CALCULATED" {
                myGroup.amount = getDefaultPaymentAmount()
                myGroup.locked = false
            }
            
            if self.isInterimGroup == true || self.isResidualGroup == true {
                self.sliderIsLocked = true
            } else {
                self.sliderIsLocked = false
            }
        }
        
    }
    
    func clearAllText() {
        if self.amountIsFocused == true {
            self.myGroup.amount = ""
        }
    }
    
    func copyToClipboard() {
        if self.amountIsFocused {
            pasteBoard.string = self.myGroup.amount
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.amountIsFocused {
                    self.myGroup.amount = string
                }
            }
        }
    }
    
    func updateForCancel() {
        if self.editStarted == true {
            self.myGroup.amount = self.paymentOnEntry
            self.editStarted = false
        }
        self.amountIsFocused = false
    }
    
    func updateForSubmit() {
        if self.editStarted == true {
            updateForPaymentAmount()
        }
        self.amountIsFocused = false
    }
    
    func submitForm() {
        self.myGroups.items[index].amount = myGroup.amount
        self.myGroups.items[index].locked = myGroup.locked
        self.myGroups.items[index].noOfPayments = myGroup.noOfPayments
        self.myGroups.items[index].timing = myGroup.timing
        self.myGroups.items[index].type = myGroup.type
        if self.myLease.interimGroupExists() == true && self.isInterimGroup == false {
            self.myLease.resetRemainderOfGroups(startGrp: 1)
        } else {
            self.myLease.resetFirstGroup(isInterim: self.isInterimGroup)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func viewOnAppear() {
        self.index = self.myGroups.items.firstIndex { $0.id == myGroup.id }!
        //self.count = self.myGroups.items.count - 1
        
        if self.myGroup.isInterim == true {
            isInterimGroup = true
        }
        
        if self.myGroup.isResidualPaymentType() == true {
            self.isResidualGroup = true
        }
        if self.isInterimGroup || self.isResidualGroup {
            self.sliderIsLocked = true
        }
        
        if self.isInterimGroup == false && self.isResidualGroup == false {
            self.rangeOfPayments = rangeNumberOfPayments()
        }
        if self.myGroup.isCalculatedPaymentType() {
            self.resetForPaymentTypeChange()
        }
        
        self.noOfPayments = self.myGroup.noOfPayments.toDouble()
        self.startingNoOfPayments = self.noOfPayments
        self.startingTotalPayments = Double(self.myGroups.getTotalNoOfPayments())
        self.paymentOnEntry = self.myGroup.amount
        if myLease.operatingMode == .lending {
            timingIsLocked = true
        }
    }
    
}

let alertInterimGroup: String = "To delete an interim payment group go to the home screen and reset the base term commencement date to equal the funding date!!"
let alertFirstPaymentGroup: String = "The last payment group in which the number of payments is greater than 1 cannot be deleted!!"
let alertPaymentAmount: String = "The amount entered exceeds the maximum allowable amount which is constrained by the Lease/Loan amount. To enter such an amount first return to the Home screen and enter a temporary amount that is greater than the payment amount that was rejected.  Then return the Payment Group screen and the desired amount."
