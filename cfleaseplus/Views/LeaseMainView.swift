//
//  LeaseMainView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI
import StoreKit

struct LeaseMainView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var showMenu: ShowMenu
    @Binding var currentFile: String
    
    @Binding var fileExported: Bool
    @Binding var exportSuccessful: Bool
    @Binding var fileImported: Bool
    @Binding var importSuccessful: Bool
    
    @Binding var selfIsNew: Bool
    @Binding var editAmountStarted: Bool
    @Binding var editRateStarted: Bool
    @Binding var isPad: Bool
    @Binding var isDark: Bool
    @Binding var fileWasSaved: Bool
    @Binding var savedDefaultLease: String
    @Binding var useSavedAsDefault: Bool
    
    @State var paymentsViewed:Bool = false
    
    @State private var amountOnEntry: String = "0.00"
    @State private var interestRateOnEntry: String = "0.05"
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var showChangeModeAlert: Bool = false
    
    @State private var oldBaseTerm: Int = 0
    @State var showPopover: Bool = false
    @State var showPopover2: Bool = false
    @State var showPopover3: Bool = false
    
    @State var baseHelp: Help = baseTermHelp
    @State var termHelp: Help = solveForTermHelp
    @State var modeHelp: Help = operatingModeHelp
    
    @FocusState private var amountIsFocused: Bool
    @FocusState private var rateIsFocused: Bool
    private let pasteBoard = UIPasteboard.general
    @State private var pasteButtonText: String = "Copy"
    
    var body: some View {
        VStack {
            Form {
                Section (header: Text(selfIsNew ? "Inputs - Locked" : "Inputs").font(.footnote), footer: getCalculationsText()) {
                        leaseAmountItem
                        fundingDateItem
                        baseCommencementDateItem
                        interestRateItem
                        paymentFrequencyItem
                        baseTermMonthsItem
                        paymentsScheduleItem
                    }
                    
                    if balanceIsZero() != true {
                        Section (header: Text("Solve For Options")) {
                            solveForAmountAndRateRow
                            solveForPaymentsAndTermRow
                        }
                    } else {
                        Section (header: Text("Results").font(.footnote), footer: Text("file name: \(currentFile)")) {
                                endingBalanceRow
                            }
                    }
                }
                .navigationTitle("Parameters")
                .navigationBarTitleDisplayMode(.large)
                .navigationViewStyle(.stack)
                .navigationBarItems(trailing: (
                    Button(action: {
                        self.selfIsNew.toggle()
                    }) {
                        if self.selfIsNew {
                            Image(systemName: "lock")
                                .imageScale(.large)
                                .tint(.red)
                        } else {
                            Image(systemName: "lock.open")
                                .imageScale(.large)
                                .tint(.green)
                        }
                    }
                ))

                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        decimalPadButtonItems
                    }
                }
            }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .alert(isPresented: $showAlert, content: getAlert)
        
        .popover(isPresented: $showPopover2) {
            PopoverView(myHelp: $baseHelp, isDark: $isDark)
        }
        .popover(isPresented: $showPopover3) {
            PopoverView(myHelp: $modeHelp, isDark: $isDark)
        }
        .onAppear {
            showMenu = .neither
            viewOnAppear()
        }
        .onDisappear{
            if paymentsViewed == true {
                showMenu = .neither
                paymentsViewed = false
            } else {
                showMenu = .closed
            }
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
    
    var leaseAmountItem: some View {
        HStack{
            Text(selfIsNew ? "amount:" : "amount: \(Image(systemName: "return"))")
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $myLease.amount,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editAmountStarted = true
                    }})
                    .disabled(selfIsNew ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($amountIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(amountFormatted(editStarted: editAmountStarted))")
                    .font(myFormResultsFont)
            }
        }
    }
    
    var fundingDateItem: some View {
            HStack {
                Text("funding:")
                    .font(.subheadline)
                Spacer()
                DatePicker("", selection: $myLease.fundingDate, displayedComponents: [.date])
                    .id(myLease.fundingDate)
                    //.transformEffect(.init(scaleX: 1.0, y: 0.9))
                    .onChange(of: myLease.fundingDate, perform: { value in
                        if self.selfIsNew == false {
                            self.myLease.resetForFundingDateChange()
                            self.endingBalance = myLease.getEndingBalance().toString(decPlaces: 3)
                            self.myLease.resetLease()
                        }
                    })
                    .disabled(selfIsNew ? true : false )
                    .font(myFormResultsFont)
            }
    }
    
    var baseCommencementDateItem: some View {
        HStack{
            Text("base start:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover2.toggle()
                }
            Spacer()
            DatePicker("", selection: $myLease.baseTermCommenceDate, in: rangeBaseTermDates, displayedComponents:[.date])
                .id(myLease.baseTermCommenceDate)
                //.transformEffect(.init(scaleX: 1.0, y: 0.90))
                .onChange(of: myLease.baseTermCommenceDate, perform: { value in
                    if self.selfIsNew == false {
                        self.myLease.resetForBaseTermCommenceDateChange()
                        self.endingBalance = myLease.getEndingBalance().toCurrency(false)
                        self.myLease.resetLease()
                    }
                })
                .disabled(selfIsNew ? true : false)
                .font(myFormResultsFont)
        }
    }
    
    var interestRateItem: some View {
        HStack{
            Text(selfIsNew ? "interest rate:" : "interest rate: \(Image(systemName: "return"))")
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $myLease.interestRate,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editRateStarted = true
                }})
                    .disabled(selfIsNew ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($rateIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\((rateFormatted(editStarted: editRateStarted)))")
                    .font(myFormResultsFont)
            }
        }
    }
    
    var paymentFrequencyItem: some View {
            HStack {
                Text("frequency:")
                    .font(myFormLabelFont)
                Spacer()
                Picker(selection: $myLease.paymentsPerYear, label: Text("")) {
                    ForEach(getFrequencies(), id: \.self) { frequency in
                        Text(frequency.toString())
                            .font(myFormResultsFont)
                    }
                    .onChange (of: myLease.paymentsPerYear) { value in
                        if self.selfIsNew == false {
                            self.myLease.resetForFrequencyChange()
                            self.oldBaseTerm = self.myLease.baseTerm
                            self.endingBalance = myLease.getEndingBalance().toString(decPlaces: 3)
                        }
                    }
                }
                .disabled(selfIsNew ? true : false)
            }
    }
    
    var baseTermMonthsItem: some View {
            HStack {
                baseTermTextItem
                Spacer()
                baseTermResultsTextItem
           }
    }

    var baseTermTextItem: some View {
        Text("base term:")
            .font(myFormLabelFont)
    }
    
    var baseTermResultsTextItem: some View {
        Text(" \(myLease.baseTerm) mons")
            .font(myFormResultsFont)
            .onChange(of: myLease.baseTerm, perform: { value in
                setNewBaseTerm(newTerm: value)
        })
    }
    
    var paymentsScheduleItem: some View {
        NavigationLink("Payment Schedule", destination: GroupsView(myGroups: $myLease.groups, myLease: myLease, selfIsNew: $selfIsNew, isDark: $isDark, showMenu: $showMenu, paymentsViewed: $paymentsViewed))
        
//        NavigationLink(destination: GroupsView(myGroups: $myLease.groups, myLease: myLease, selfIsNew: $selfIsNew, isDark: $isDark, showMenu: $showMenu, paymentsViewed: $paymentsViewed),
//
//            label: {
//                Text("View Payment Schedule")
//                    .font(myFormResultsFont)
//                    .foregroundColor(Color("AccentColor"))
//                    .bold()
//            })
//        .disabled(keyboardActive())
        
    }
    
    var endingBalanceRow: some View {
        HStack {
            Text("ending balance:")
                .font(.subheadline)
            ZStack (alignment: .trailing){
                TextField("", text: $endingBalance)
                    .font(.subheadline)
                    .foregroundColor(.clear)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: endingBalance) { newValue in

                }
                Text("\(endingBalance.toDecimal().toString(decPlaces: 3))")
                    .font(.subheadline)
            }
        }
    }
    
    var solveForAmountAndRateRow: some View {
        HStack {
            solveForAmountButton
            Spacer()
            solveForInterestRateButton
        }
    }
    
    var solveForPaymentsAndTermRow: some View {
        HStack {
            solveForPaymentsButton
            Spacer()
            solveForTermButton
        }
    }
        
    var solveForAmountButton: some View {
        Button(action: {}) {
            Text("amount")
                .font(.subheadline)
        }
        .onTapGesture {
            self.myLease.solveForPrincipal()
            if self.myLease.amount.toDecimal() < minimumLeaseAmount.toDecimal() ||  self.myLease.amount.toDecimal() > maximumLeaseAmount.toDecimal() {
                self.alertTitle = alertMaxAmount
                self.showAlert.toggle()
                self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease, mode: myLease.operatingMode)
                self.myLease.solveForRate3()
                self.selfIsNew = true
            }
            self.endingBalance = myLease.getEndingBalance().toString(decPlaces: 3)
            self.myLease.resetLease()
        }
    }
    
    var solveForInterestRateButton: some View {
        Button(action: {}) {
            Text("interest rate")
                .font(.subheadline)
        }
        .disabled(solveForRateIsValid() ? false : true)
        .onTapGesture {
            self.myLease.solveForRate3()
            if self.myLease.interestRate.toDecimal() > 0.0 && self.myLease.interestRate.toDecimal() < maxInterestRate.toDecimal() {
                if abs(self.myLease.getEndingBalance()) > toleranceAmounts {
                    for x in 0..<self.myLease.groups.items.count {
                        if self.myLease.groups.items[x].locked == true && self.myLease.groups.items[x].noOfPayments > 1 {
                            self.myLease.groups.items[x].locked = false
                        }
                    }
                    self.myLease.solveForUnlockedPayments3()
                }
                self.endingBalance = myLease.getEndingBalance().toString(decPlaces: 3)
                self.myLease.resetLease()
            } else {
                self.alertTitle = alertSolveFor
                self.showAlert.toggle()
                self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease, mode: myLease.operatingMode)
                self.myLease.solveForUnlockedPayments3()
                self.endingBalance = myLease.getEndingBalance().toString(decPlaces: 3)
                self.selfIsNew = true
            }
        }
    }
    
    var solveForPaymentsButton: some View {
        Button(action: {}) {
            Text("unlocked payments")
                .font(.subheadline)
        }
        .disabled(solveForPaymentsIsValid() ? false : true)
        .onTapGesture {
            self.myLease.solveForUnlockedPayments3()
            if self.myLease.groups.hasNegativePayments() == true {
                self.alertTitle = alertSolveFor
                self.showAlert.toggle()
                self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease, mode: myLease.operatingMode)
                self.selfIsNew = true
            } else {
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 2)
                self.myLease.resetLease()
            }
           
        }
    }
    
    var solveForTermButton: some View {
        HStack {
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover3.toggle()
                }
            Button(action: {}) {
                Text("term")
                    .font(.subheadline)
            }
            .disabled(solveForTermIsValid() ? false : true)
            .onTapGesture {
                self.myLease.solveForTerm(maxBase: maxBaseTerm)
                if myLease.groups.hasInValidGroup() == true {
                    self.alertTitle = alertMaxAmount
                    self.showAlert.toggle()
                    self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease, mode: myLease.operatingMode)
                    self.selfIsNew = true
                }
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 3)
                self.myLease.resetLease()
        }
        }
        .popover(isPresented: $showPopover3) {
            PopoverView(myHelp: $termHelp, isDark: $isDark)
        }
    }
    
    var modeChangeButtonItem: some View {
        HStack {
            Text("\(self.myLease.operatingMode.toString()) Mode")
                .font(.subheadline)
                .foregroundColor(self.myLease.operatingMode == .leasing ? Color.theme.accent : .red)
                .bold()
                //.disabled(showMenu)
                .alert(isPresented: $showChangeModeAlert) {
                    Alert (
                        title: Text("Are you sure you want change the mode?"),
                        message: Text("There is no undo"),
                        primaryButton: .destructive(Text("Change Mode")) {
                           changeMode()
                    },
                           secondaryButton: .cancel()
                    )}
                .onTapGesture {
                    self.showChangeModeAlert.toggle()
                }
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                //.disabled(showMenu)
                .onTapGesture {
                    self.showPopover3 = true
                }
        }
    }
    
    private func changeMode() {
        if self.myLease.operatingMode == .leasing {
            self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: currentFile, mode: .lending)
        } else {
            self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: currentFile, mode: .leasing)
        }
        self.currentFile = "file is new"
    }
    
    private func amountFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return myLease.amount
        } else {
            return myLease.amount.toDecimal().toCurrency(false)
        }
    }
    
    private func balanceIsZero() -> Bool {
        var isZero: Bool = false
        
        let balance: Decimal = self.endingBalance.toDecimal()
        if abs(balance) <= toleranceAmounts {
            isZero = true
        }
        
        return isZero
    }
    
    private func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    private func showDecimalPadHelp() {
        self.showPopover2.toggle()
    }
    
    private func getCalculationsText() -> Text {
        let strLead = Text("Calculations")
        let strSpacer = Text(": ")
        
        var strPVRents = "PV/"
        var strEBO = "EBO/"
        var strTV = "TVs/"
        var strBalance = "Balance/"
    
        if myLease.isTrueLease() == false {
            strPVRents = ""
        }
        if myLease.eboExists() == false {
            strEBO = ""
        }
        
        if myLease.terminationsExist() == false {
            strTV = ""
        }
        
        if modificationDate == "01/01/1900" {
            strBalance = ""
        }
        
        var arrayCalcs: [String] = [strPVRents, strEBO, strTV, strBalance]
        var arrayFinal: [String] = [""]
        
        var strSum: String = ""
        for x in 0..<arrayCalcs.count {
            if arrayCalcs[x] != "" {
                arrayFinal.append(arrayCalcs[x])
            }
        }
        for x in 0..<arrayFinal.count {
            if x == arrayFinal.count - 1 {
                let strLast = arrayFinal[x].replaceFirst(of: "/", with: "")
                arrayFinal.remove(at: x)
                arrayFinal.append(strLast)
            }
            strSum = strSum + arrayFinal[x]
        }
        
        arrayCalcs.removeAll()
        arrayFinal.removeAll()
        
        return strLead + strSpacer + Text(strSum)
    }
    
    private func getFrequencies() -> [Frequency] {
        let freqValue1: Int = 1
        var freqValue2: Int = 0
        var freqValue3: Int = 0
        var freqValue4: Int = 0

        if isFrequencyValid(divisor: 12) == true {
            freqValue4 = 4
        }
        if isFrequencyValid(divisor: 6) == true {
            freqValue3 = 3
        }
        if isFrequencyValid(divisor: 3) == true {
            freqValue2 = 2
        }
        let highestValue = max(freqValue4, freqValue3, freqValue2, freqValue1)

        switch highestValue {
        case 4:
            return Frequency.allCases
        case 3:
            return Frequency.three
        case 2:
            return Frequency.two
        default:
            return Frequency.one
        }
    }
    
    private func getMultiplier() -> Int {
        switch myLease.paymentsPerYear {
        case .monthly:
            return 12
        case .quarterly:
            return 4
        case .semiannual:
            return 2
        default :
            return 1
        }
    }
    
    private func isFrequencyValid(divisor: Int) -> Bool {
        var isValid: Bool = true
        
        for x in 0..<self.myLease.groups.items.count {
            if self.myLease.groups.items[x].isInterim == false {
                let sDate:Date = self.myLease.groups.items[x].startDate
                let eDate: Date = self.myLease.groups.items[x].endDate
                let number: Int = monthsBetween(start: sDate, end: eDate)
                if number % divisor != 0 {
                    isValid = false
                    return isValid
                }
            }
        }

        return isValid
    }
    
    private func keyboardActive() -> Bool {
        if amountIsFocused == true || rateIsFocused == true {
            return true
        } else {
            return false
        }
    }


    private var rangeBaseTermDates: ClosedRange<Date> {
        let starting: Date = myLease.fundingDate
        var maxInterim: Int
        var dayAdder: Int = -1
        
        switch myLease.paymentsPerYear {
        case .quarterly:
            maxInterim = 3
        case .semiannual:
            maxInterim = 6
        case .annual:
            maxInterim = 12
        default:
            maxInterim = 3
        }
        
        if maxInterim == 3 {
            dayAdder = 0
        }
        
        var ending: Date = Calendar.current.date(byAdding: .month, value: maxInterim, to: starting)!
        ending = Calendar.current.date(byAdding: .day, value: dayAdder, to: ending)!
        
        return starting...ending
    }
    
    private var rangeBaseTermMonths: ClosedRange<Int> {
        let starting: Int = 24
        let ending: Int = maxBaseTerm
        return starting...ending
    }
    
    private func rateFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return myLease.interestRate.toTruncDecimalString(decPlaces: 7)
        } else {
            return myLease.interestRate.toDecimal().toPercent(3)
        }
    }
    
    private func setNewBaseTerm (newTerm: Int) {
        if self.selfIsNew == false {
            if self.myLease.getBaseTermInMons() != newTerm {
                let idx: Int = self.myLease.groups.indexOfGroupWithMoreThanOnePayment()
                if idx != -1 {
                    let changeBaseTerm = newTerm - self.oldBaseTerm
                    var step: Int = 1
                    if changeBaseTerm < 0 {
                        step = -1
                    }
                    step = step * getMultiplier()
                    
                    self.myLease.groups.items[idx].noOfPayments = self.myLease.groups.items[idx].noOfPayments + step
                    self.myLease.resetFirstGroup(isInterim: self.myLease.interimGroupExists())
                    self.endingBalance = myLease.getEndingBalance().toString(decPlaces: 3)
                    self.oldBaseTerm = self.myLease.baseTerm
                }
            }
        } else {
            self.myLease.baseTerm = myLease.getBaseTermInMons()
        }
    }
    
    private func solveForPaymentsIsValid() -> Bool {
        if myLease.groups.allGroupsAreLocked() == true {
            return false
        }
        
        var allUnlockedAreEqualToZero: Bool = true
        for x in 0..<myLease.groups.items.count {
            if myLease.groups.items[x].locked == false {
                if myLease.groups.items[x].amount.toDecimal() != 0.00 {
                    allUnlockedAreEqualToZero = false
                }
            }
        }
        if allUnlockedAreEqualToZero == true {
            return false
        }
        
        return true
    }
    
    private func solveForRateIsValid() -> Bool {
        if self.myLease.groups.hasPrincipalPayments() {
            return false
        }
        
        if myLease.groups.hasAllCalculatedPayments() == true {
            return false
        }
        
        if self.myLease.getNetAmount() < 0.00 {
            return false
        }

        return true
    }
    
    private func solveForTermIsValid() -> Bool {
        if myLease.groups.noOfGroupsWithMoreThanOnePayment() > 1 {
            return false
        }
        
        let idx = myLease.groups.indexOfGroupWithMoreThanOnePayment()
        
        if idx == -1 {
            return false
        }
        
        if myLease.groups.items[idx].type != .payment {
            return false
        }
        if idx < myLease.groups.items.count - 1 {
            return false
        }
        
        let decAmount: Decimal = myLease.groups.items[idx].amount.toDecimal()
        let minPayment: Decimal  = (myLease.amount.toDecimal() * myLease.interestRate.toDecimal()) / Decimal(myLease.paymentsPerYear.rawValue)
        let maxPayment: Decimal = (myLease.amount.toDecimal() / Decimal(myLease.paymentsPerYear.rawValue)) * 2
        
        if decAmount <= minPayment || decAmount >= maxPayment {
            return false
        }
        
        return true
    }
    
    
    
    private func viewOnAppear() {
        self.amountOnEntry = self.myLease.amount
        self.interestRateOnEntry = self.myLease.interestRate
        self.oldBaseTerm = self.myLease.getBaseTermInMons()
        self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 3)
        
        if self.fileExported == true {
            if self.exportSuccessful == true {
                self.alertTitle = alertExportSuccess
            } else {
                self.alertTitle = alertExportFailure
            }
            self.showAlert.toggle()
            self.fileExported = false
            self.exportSuccessful = false
        }
        
        if self.fileImported == true {
            if self.importSuccessful == true {
                self.alertTitle = alertImportSuccess
            } else {
                self.alertTitle = alertImportFailure
            }
            self.showAlert.toggle()
            self.fileImported = false
            self.importSuccessful = false
        }
        
        if self.balanceIsZero() == false && solveForPaymentsIsValid() == false {
            self.alertTitle = alertUnlockedPayments
            self.showAlert.toggle()
        }
        
        if self.balanceIsZero() == true && myLease.interestRate.toDecimal() > maxInterestRate.toDecimal(){
            self.alertTitle = "Interest exceeds the maximum"
            self.showAlert.toggle()
        }
        
       
    }
    
}

struct LeaseMainView_Previews: PreviewProvider {
    static var previews: some View {
       
        LeaseMainView(myLease: Lease(aDate: today(),mode: .leasing), endingBalance: .constant("0.00"), showMenu: .constant(.closed), currentFile: .constant("file is new"), fileExported: .constant(false), exportSuccessful: .constant(false), fileImported: .constant(false), importSuccessful: .constant(false), selfIsNew: .constant(false), editAmountStarted: .constant(false), editRateStarted: .constant(false), isPad: .constant(false), isDark: .constant(false), fileWasSaved: .constant(false), savedDefaultLease: .constant("Test"), useSavedAsDefault: .constant(false))
                .previewInterfaceOrientation(.portrait)
                .preferredColorScheme(.light)
    }
}

//Decimal pad buttons
extension LeaseMainView {
    private func updateForCancel() {
        if self.editAmountStarted == true {
            self.editAmountStarted = false
            self.myLease.amount = self.amountOnEntry
        }
        if self.editRateStarted == true {
            self.editRateStarted = false
            self.myLease.interestRate = self.interestRateOnEntry
        }
        self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 3)
        self.myLease.resetTerminations()
        self.amountIsFocused = false
        self.rateIsFocused = false
    }
    
    private func updateForSubmit() {
        if self.editAmountStarted == true {
            self.editAmountStarted = false
            if isAmountValid(strAmount: myLease.amount, decLow: minimumLeaseAmount.toDecimal(), decHigh: maximumLeaseAmount.toDecimal(), inclusiveLow: false, inclusiveHigh: true) == false {
                self.myLease.amount = self.amountOnEntry
                self.alertTitle = alertInvalidAmount
                self.showAlert.toggle()
            } else {
                self.myLease.resetPaymentAmountToMax()
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 3)
                self.myLease.resetTerminations()
            }
        }
        if self.editRateStarted == true {
            self.editRateStarted = false
            if isInterestRateValid(strRate: myLease.interestRate, decLow: 0.0, decHigh: maxInterestRate.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
                self.alertTitle = alertInterestRate
                self.showAlert.toggle()
                myLease.interestRate = self.interestRateOnEntry
            } else {
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 3)
                self.myLease.resetTerminations()
            }
        }
        self.amountIsFocused = false
        self.rateIsFocused = false
    }
    
    private func clearAllText() {
        if self.amountIsFocused == true {
            self.myLease.amount = ""
        } else {
            self.myLease.interestRate = ""
        }
    }
    
    private func copyToClipboard() {
        if self.amountIsFocused {
            pasteBoard.string = self.myLease.amount
        } else {
            pasteBoard.string = self.myLease.interestRate
        }
    }
    
    private func paste() {
        if var pasteboardString = pasteBoard.string {
            pasteboardString.removeAll(where: { removeCharacters.contains($0) } )
            if pasteboardString.isDecimal() {
                if self.amountIsFocused {
                    self.myLease.amount = pasteboardString
                } else {
                    self.myLease.interestRate = pasteboardString
                }
            }
        }
    }
    
}


let alertInvalidAmount: String = "A valid amount must be a decimal greater than the minimum allowable amount (\(minimumLeaseAmount.toDecimal().toCurrency(false))) or any locked payment amount but less than the maximum allowable amount (\(maximumLeaseAmount.toDecimal().toCurrency(false)))!!"
let alertStepper: String = "The base term stepper has been disabled because the number of payment groups with more than one payment is greater than one!!!"
let alertMaxAmount: String = "The calculated Lease/Loan amount exceeds the maximum allowable amount (50,000,000). As a result, the Lease/Loan will be reset to the default parameters.  It is likely that one or more of the Payment Groups has an incorrect payment amount!"
let alertInterestRate: String  = "A valid interest rate must be a decimal that is greater than 0.00 and less than maximum interest rate (see Preferences)!"
let alertUnlockedPayments: String = "Solve for unlocked payments is not available.  All payment groups are either locked or their amounts are equal to zero. To make this option available, go to the payments schedule screen and unlock at least one of the non-zero payment groups."
let alertExportSuccess: String = "The file was successfully exported to the selected folder.  If exported to iCloud the file can easily be shared with another CFLease user. To delete file from local folder, select File Open then select delete."
let alertExportFailure: String = "The file was not exported!"
let alertImportSuccess: String = "The file has been successfully imported, but has not been saved to the CFLease file folder.  To add the imported file to the local folder under the imported name select File Save or select File Save As to save file under a different name."
let alertImportFailure: String = "The file could not be imported and is likely not a valid CFLease data file!"
let alertSolveFor: String = "The solution produced value that was less than the minimum or greater than the maximum allowable and therefore is invalid. The Lease was reset to the new Lease default parameters."
