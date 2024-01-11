//
//  FeeView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/15/23.
//

import SwiftUI

struct FeeView: View {
    @State var myFee: Fee
    @State var myFees: Fees
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState private var nameIsFocused: Bool
    @FocusState private var amountIsFocused: Bool
    
    @State private var editNameStarted: Bool = false
    @State private var editAmountStarted: Bool = false
    
    @State private var nameOnEntry: String = "Name"
    @State private var amountOnEntry: String = "2000.00"
    
    private let pasteBoard = UIPasteboard.general
    @State var showPopover: Bool = false
    @State private var showPopover1: Bool = false
    @State private var showPopover2: Bool = false
    @State var helpFeeName = feeNameHelp
    
    @State var feeAmountOnEntry: String = "0.00"
    @State var typeIsCustomerPaid: Bool = false
    @State private var maximumAmount: Decimal = 1.0
    @State var index = 0
    @State var count = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    feeNameItemRow
                    feeEffectiveDatePicker
                    feeTypeItem
                    feeIncomeTypeItem
                    paymentAmountItem
                    feeLockedItem
                }
                
                Section(header: Text("Submit Form")) {
                    textButtonsForCancelAndDoneRow
                }
            }
            .navigationTitle("Fee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard){
                    decimalPadButtonItems
                }
            }
        }
        .onAppear {
            self.maximumAmount = myLease.amount.toDecimal()
            
            if self.myFees.items.count == 0 {
                self.index = 0
            } else {
                self.index = self.myFees.items.firstIndex { $0.id == myFee.id }!
            }
            self.nameOnEntry = self.myFee.name
            self.amountOnEntry = self.myFee.amount
        }
    }
    
    var feeNameItemRow: some View {
        HStack {
            Text("name:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover1.toggle()
                }
            Spacer()
            TextField("name", text: $myFee.name,
                      onEditingChanged: { (editing) in
                if editing == true {
                    editNameStarted = true
                }})
                .font(.body)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($nameIsFocused)
                .disabled(amountIsFocused)
                .keyboardType(.default)
                .disableAutocorrection(true)
        }
        .popover(isPresented: $showPopover1) {
            PopoverView(myHelp: $helpFeeName, isDark: $isDark)
        }
    }
    
    var feeEffectiveDatePicker: some View {
        HStack {
            Text("effective date:")
                .font(.subheadline)
            Spacer()
            DatePicker("", selection: $myLease.fundingDate, displayedComponents: [.date])
                .id(myLease.fundingDate)
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
                .onChange(of: myLease.fundingDate, perform: { value in
                   
                })
                .disabled(true)
                .font(.body)
        }
    }
    
    var feeTypeItem: some View {
        Picker(selection: $myFee.type, label: Text("type:").font(.subheadline)) {
            ForEach(FeeType.allCases, id: \.self) { feeType in
                Text(feeType.toString())
                    .font(.body)
            }
            .onChange(of: myFee.type, perform: { value in
                if value == .customerPaid {
                    typeIsCustomerPaid = true
                    myFee.incomeType = .income
                } else {
                    typeIsCustomerPaid = false
                }
            })
        }
    }
    
    
    var feeIncomeTypeItem: some View {
        Picker(selection: $myFee.incomeType, label: Text("income type:").font(.subheadline)) {
            ForEach(getFeeIncomeTypes(), id: \.self) { feeIncomeType in
                Text(feeIncomeType.toString())
                    .font(.body)
            }
            .onChange(of: myFee.incomeType, perform: { value in
                if typeIsCustomerPaid == true {
                    myFee.incomeType = .income
                }
            })
        }
    }
    
    var paymentAmountItem: some View {
        HStack{
            Text("amount:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                    text: $myFee.amount,
                  onEditingChanged: { (editing) in
                    if editing == true {
                        self.editAmountStarted = true
                }})
                    //.disabled(nameIsFocused)
                    .keyboardType(.numberPad)
                    .foregroundColor(.clear)
                    .focused($amountIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(feeAmountFormatted(editStarted: editAmountStarted))")
                    .font(.body)
            }
        }
        .popover(isPresented: $showPopover) {
           // PopoverView(myHelp: $payHelp, isDark: $isDark)
        }
    }
    
    var feeLockedItem: some View {
        HStack{
           Toggle(isOn: $myFee.locked) {
               Text(myFee.locked ? "locked:" : "unlocked:")
                   .font(.subheadline)
           }
           .font(.subheadline)
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
    
   

    var textButtonsForCancelAndDoneRow: some View {
        HStack {
            Text("Delete")
                .disabled(amountIsFocused)
                .font(.subheadline)
                .foregroundColor(amountIsFocused ?  .gray : .accentColor )
                .onTapGesture {
                    if amountIsFocused == false {
                        deleteFee()
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
    

struct FeeView_Previews: PreviewProvider {
    static var previews: some View {
        FeeView(myFee: Fee(title: "Legal Closing Fee", effectDate: today(), acctgType: .expense, strAmount: "20000.00", feeType: .other, feeLocked: false),myFees: Fees(), myLease: Lease(aDate: today(), mode: .leasing),isDark: .constant(false))
    }
}


extension FeeView {
    func getFeeIncomeTypes() -> [FeeIncomeType] {
        if typeIsCustomerPaid == true {
            return [.income]
        } else {
            return [.expense, .income]
        }
    }
    
    func isNameValid(strName: String) -> Bool {
        //is string empty
        if strName.count == 0 {
            return false
        }
        //is its length longer the limit
        if strName.count > maxFileNameLength {
            return false
        }
        if strName.contains("file is new") {
            return false
        }
        
        //contains illegal chars or punctuation chars
        let myIllegalChars = "!@#$%^&()<>?,|[]{}:;/+=*~"
        let charSet = CharacterSet(charactersIn: myIllegalChars)
        if (strName.rangeOfCharacter(from: charSet) != nil) {
            return false
        }
    
        return true
        
    }
    
    func percentToAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * myLease.amount.toDecimal()
        return decAmount.toString(decPlaces: 2)
    }
    
    func deleteFee() {
        self.myLease.fees?.removeFee(index: index)
        self.presentationMode.wrappedValue.dismiss()
        
    }
    
    func submitForm() {
        self.myLease.fees!.items[index].name = self.myFee.name
        self.myLease.fees!.items[index].effectiveDate = self.myFee.effectiveDate
        self.myLease.fees!.items[index].type = self.myFee.type
        self.myLease.fees!.items[index].incomeType = self.myFee.incomeType
        self.myLease.fees!.items[index].amount = self.myFee.amount
        self.myLease.fees!.items[index].locked = self.myFee.locked
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func feeAmountFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myFee.amount
        }
        return myFee.amount.toDecimal().toCurrency(false)
    }
}

// Decimal pad functions
extension FeeView {
    func clearAllText() {
        if self.nameIsFocused == true {
            self.myFee.name = ""
        } else {
            self.myFee.amount = ""
        }
    }
    
    func copyToClipboard() {
        if self.amountIsFocused {
            pasteBoard.string = self.myFee.amount
        } else {
            pasteBoard.string = self.myFee.name
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.amountIsFocused {
                    self.myFee.amount = string
                }else {
                    self.myFee.name = string
                }
            }
        }
    }
    
    func updateForCancel() {
        if self.editAmountStarted == true {
            self.myFee.amount = self.amountOnEntry
            self.editAmountStarted = false
        } else {
            self.myFee.name = self.nameOnEntry
            self.editNameStarted = false
        }
        self.amountIsFocused = false
        self.nameIsFocused = false
    }
    
    func updateForSubmit() {
        if self.editAmountStarted == true {
            updateForFeeAmount()
        } else {
            updateForName()
        }
        
        self.nameIsFocused = false
        self.amountIsFocused = false
    }

    func updateForName() {
        if isNameValid(strName: myFee.name) == false {
            self.myFee.name = nameOnEntry
        }
    }
    
    func updateForFeeAmount() {
        if myFee.amount == "" {
            self.myFee.amount = "0.00"
        }
        
        if self.myFee.amount.toDecimal() > 0.00 && self.myFee.amount.toDecimal() < 1.0 {
            self.myFee.amount = percentToAmount(percent:  myFee.amount)
        }
        
        if isAmountValid(strAmount: myFee.amount, decLow: 0.0, decHigh: maximumAmount, inclusiveLow: true, inclusiveHigh: true) == false {
            self.myFee.amount = self.feeAmountOnEntry
//            alertTitle = alertPaymentAmount
//            showAlert.toggle()
        }
        self.editAmountStarted = false
    }
    
}
