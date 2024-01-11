//
//  EarlyBuyoutView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct EarlyBuyoutView: View {
    @ObservedObject var myLease: Lease
    @Environment(\.presentationMode) var presentationMode
    @Binding var isDark: Bool
    
    @State private var eboDate: Date = today()
    @State private var eboAmount: String = "0.00"
    @State private var eboTerm: Int = 42
    @State private var rentDueIsPaid = true
    @State private var parValue: String = "0.00"
    @State private var basisPoints: Double = 0.00
    @State private var premiumIsSpecified = false

    @State private var stepBps: Double = 1.0
    @State private var editAmountStarted: Bool = false
    @State private var stepValue: Int = 1
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var showPopover: Bool = false
    @State private var showPopover2: Bool = false
    @State private var myEBOHelp = eboHelp
    @State private var myEBOHelp2 = eboHelp2
    
    @State private var amountColor: Int = 1
    @State private var calculatedButtonPressed: Bool = true
    @FocusState private var amountIsFocused: Bool
    private let pasteBoard = UIPasteboard.general
    
    var defaultInactive: Color = Color.theme.inActive
    var defaultCalculated: Color = Color.theme.calculated
    var activeButton: Color = Color.theme.accent
    var standard: Color = Color.theme.active
   
    var body: some View {
        NavigationView{
            Form {
                Section (header: Text("Excercise Date").font(.footnote)) {
                    eboTermInMonsRow
                    exerciseDateRow
                    includesRentDueRowItem
                    //parValueOnDateRow
                }
                
                Section (header: Text("EBO Amount").font(.footnote)) {
                    eboAmountRow
                    interestRateAdderRow
                    basisPointsStepperRow2
                    if premiumIsSpecified == false {
                        if self.calculatedButtonPressed == true {
                            self.calculatedResultItemRow
                        } else {
                            calculatedButtonItemRow
                        }
                        
                    } else {
                        specifiedItemRow
                    }
                }
                
                Section (header: Text("Submit Form").font(.footnote)) {
                    textButtonsForCancelAndDoneRow
                }
            }
            .navigationTitle("Early Buyout Parameters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar{
                ToolbarItemGroup (placement: .keyboard) {
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
            PopoverView(myHelp: $myEBOHelp, isDark: $isDark)
        }
        .popover(isPresented: $showPopover2) {
            PopoverView(myHelp: $myEBOHelp2, isDark: $isDark)
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
    
    var eboTermInMonsRow: some View {
        HStack {
            Text("term in mons: \(eboTerm)")
                .font(.subheadline)
            Stepper(value: $eboTerm, in: rangeBaseTermMonths, step: getStep()) {
    
            }.onChange(of: eboTerm) { newTerm in
                let noOfPeriods: Int = newTerm / (12 / self.myLease.paymentsPerYear.rawValue)
                self.eboDate = self.myLease.getExerciseDate(term: noOfPeriods)
                self.basisPoints = 0.0
            }
        }
        .font(.subheadline)
    }
    
    var exerciseDateRow: some View {
        HStack {
            Text("exercise date:")
                .font(.subheadline)
                .foregroundColor(defaultInactive)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            
            Spacer()
            Text(eboDate.toStringDateShort(yrDigits: 4))
                .font(.subheadline)
                .foregroundColor(defaultInactive)
                .onChange(of: eboDate) { newDate in
                    self.parValue = self.myLease.getParValue(askDate: newDate, rentDueIsPaid: rentDueIsPaid).toString()
                    self.eboAmount = self.parValue
                }
        }
    }
    
    var parValueOnDateRow: some View {
        HStack {
            Text("par value on date:")
                .font(.subheadline)
                .foregroundColor(defaultInactive)
            Spacer()
            Text(parValue.toDecimal().toCurrency(false))
                .font(.subheadline)
                .foregroundColor(defaultInactive)
        }
    }
    
    var includesRentDueRowItem: some View {
        Toggle(isOn: $rentDueIsPaid) {
            Text(rentDueIsPaid ? "rent due will also be paid:" : "rent due will not be paid:")
                .font(.subheadline)
                .onChange(of: rentDueIsPaid) { value in
                    self.parValue = self.myLease.getParValue(askDate: eboDate, rentDueIsPaid: value).toString()
                    self.eboAmount = self.parValue
                    self.basisPoints = 0.0
                }
        }
    }
    
    
    // Section EBO Amount
    // Row 1
    var eboOptionAmountRow: some View {
        Toggle(isOn: $premiumIsSpecified) {
            Text(premiumIsSpecified ? "amount is specified:" : "amount is calculated:")
                .font(.subheadline)
                .onChange(of: premiumIsSpecified) { value in
                    if value == true {
                        self.basisPoints = Double(self.myLease.getEBOPremium(aLease: self.myLease,  exerDate: self.eboDate, aEBOAmount: self.eboAmount, rentDueIsPaid: rentDueIsPaid).toString().toInteger())
                        self.amountColor = 0
                    } else {
                        self.basisPoints = 0.00
                        self.eboAmount = self.parValue
                        self.amountColor = 1
                    }
                }
        }
        
    }
    
    var eboAmountRow: some View {
        HStack {
            Text(premiumIsSpecified ? "amount is specified:" : "amount is calculated:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover2 = true
                }
            Spacer()
            Toggle("is calculated", isOn: $premiumIsSpecified)
                .labelsHidden()
                .onChange(of: premiumIsSpecified) { value in
                    if value == true {
                        self.basisPoints = Double(self.myLease.getEBOPremium(aLease: self.myLease,  exerDate: self.eboDate, aEBOAmount: self.eboAmount, rentDueIsPaid: rentDueIsPaid).toString().toInteger())
                        self.amountColor = 0
                    } else {
                        self.basisPoints = 0.00
                        self.eboAmount = self.parValue
                        self.amountColor = 1
                    }
                }
        }
    }
    
    //Row 2
    var interestRateAdderRow: some View {
        VStack {
            HStack {
                Text("interest rate adder:")
                    .font(.subheadline)
                    .foregroundColor(premiumIsSpecified ? defaultInactive : defaultCalculated)
                Spacer()
                Text("\(basisPoints, specifier: "%.0f") bps")
                    .font(.subheadline)
                    .foregroundColor(premiumIsSpecified ? defaultInactive : defaultCalculated)
            }
            
            Slider(value: $basisPoints, in: 0...maxEBOSpread.toDouble(), step: stepBps) { editing in
                self.amountColor = 1
                self.calculatedButtonPressed = false
            }

            .disabled(premiumIsSpecified ? true : false)
        }
    }
    
    var basisPointsStepperRow2: some View {
        HStack {
            Spacer()
            Stepper("", value: $basisPoints, in: 0...maxEBOSpread.toDouble(), step: 1, onEditingChanged: { _ in
                self.calculatedButtonPressed = false
            }).labelsHidden()
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
        }
    }
    
    //Row 3a
    var calculatedButtonItemRow: some View {
        HStack{
            Button(action: {
                self.eboAmount = self.myLease.getEBOAmount(aLease: myLease, bpsPremium: Int(self.basisPoints), exerDate: self.eboDate, rentDueIsPaid: rentDueIsPaid)
                self.calculatedButtonPressed = true
                self.editAmountStarted = false
            }) {
                Text("calculate")
                    .font(.subheadline)
            }
            Spacer()
            
            Text("\(eboFormatted(editStarted:editAmountStarted))")
                .font(.subheadline)
                .foregroundColor(resetAmountColor())
        }
    }
    
    var calculatedResultItemRow: some View {
        HStack {
            Text(basisPoints == 0 ? "par value:" : "calculated ebo:")
                .font(.subheadline)
            Spacer()
            Text("\(eboFormatted(editStarted:editAmountStarted))")
                .font(.subheadline)
                .foregroundColor(resetAmountColor())
            
        }
    }
    
    //Row 3b
    var specifiedItemRow: some View {
        HStack {
            Text("specified \(Image(systemName: "return"))")
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                  text: $eboAmount,
                  onEditingChanged: { (editing) in
                    if editing == true {
                        self.editAmountStarted = true
                }})
                    .focused($amountIsFocused)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)

                Text("\(eboFormatted(editStarted:editAmountStarted))")
                    .font(.subheadline)
                    .foregroundColor(resetAmountColor())
            }
        }
    }
    
    var textButtonsForCancelAndDoneRow: some View {
        HStack {
            Text("Cancel")
                .disabled(buttonsDisabled())
                .font(.subheadline)
                .foregroundColor(buttonsDisabled() ? .gray : .accentColor)
                .onTapGesture {
                    if buttonsDisabled() == false {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            Spacer()
            Text("Done")
                .disabled(buttonsDisabled())
                .font(.subheadline)
                .foregroundColor(buttonsDisabled() ? .gray : .accentColor)
                .onTapGesture {
                    if buttonsDisabled() == false {
                        self.myLease.earlyBuyOut = EarlyPurchaseOption(aExerciseDate: self.eboDate, aAmount: self.eboAmount, rentDue: self.rentDueIsPaid)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }
    
    //Mark: Functions
    func buttonsDisabled() -> Bool {
        if self.amountIsFocused == true {
            return true
        }
        if self.calculatedButtonPressed == false {
            return true
        }
        
        return false
    }
    
    func eboFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return self.eboAmount.toTruncDecimalString(decPlaces: 7)
        } else {
            return self.eboAmount.toDecimal().toCurrency(false)
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    
    func getMaxEBOAmount() -> Decimal {
        let maxAmount: Decimal = myLease.getEBOAmount(aLease: myLease, bpsPremium: maxEBOSpread, exerDate: self.eboDate, rentDueIsPaid: self.rentDueIsPaid).toDecimal()
        return maxAmount
    }
    
    func getStep() -> Int {
        switch self.myLease.paymentsPerYear {
        case .monthly:
            return 1
        case .quarterly:
            return 3
        case .semiannual:
            return 6
        default:
            return 12
        }
    }
    
    var rangeBaseTermMonths: ClosedRange<Int> {
        let starting: Int = 12
        let ending: Int = myLease.getBaseTermInMons() - 12
        
        return starting...ending
    }
    
    func resetAmountColor() -> Color {
        switch amountColor {
        case 0:
            return standard
        case 1:
            return defaultCalculated
        default:
            return defaultInactive
        }
    }
    
    func clearAllText() {
        if self.amountIsFocused == true {
            self.eboAmount = ""
        }
    }
    
    func copyToClipboard() {
        if self.amountIsFocused {
            pasteBoard.string = self.eboAmount
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.amountIsFocused {
                    self.eboAmount = string
                }
            }
        }
    }

    func updateForCancel() {
        if self.editAmountStarted == true {
            self.editAmountStarted = false
            self.eboAmount = self.parValue
        }
       updateForNewAmount()
    }
    
    func updateForSubmit() {
        if self.editAmountStarted == true {
            updateForNewAmount()
        }
    }
    
    func updateForNewAmount() {
        self.editAmountStarted = false
        if self.eboAmount.toDecimal() < 1.0 {
            self.eboAmount = (self.myLease.amount.toDecimal() * self.eboAmount.toDecimal()).toString(decPlaces: 7)
        }
        if isAmountValid(strAmount: eboAmount, decLow: self.parValue.toDecimal(), decHigh: getMaxEBOAmount(), inclusiveLow: false, inclusiveHigh: true) == false {
            self.eboAmount = self.parValue
            self.basisPoints = 0.0
            alertTitle = alertInvalidEBOAmount
            showAlert.toggle()
        } else {
            self.basisPoints = Double(self.myLease.getEBOPremium(aLease: self.myLease, exerDate: self.eboDate, aEBOAmount: self.eboAmount, rentDueIsPaid: rentDueIsPaid).toString().toInteger())
        }
        self.amountIsFocused = false
        
    }
    
    private func viewOnAppear() {
        //Determine if new or existing EBO
        //private vars eboDate, eboAmount, rentDueIsPaid
        //calculated are eboTerm, basisPoints, and premiumIsSpecified
        //set private vars to default EBO and saved EBO
        if self.myLease.earlyBuyOut!.exerciseDate == self.myLease.getMaturityDate() {
            self.eboDate = Calendar.current.date(byAdding: .month, value: -12, to: self.myLease.getMaturityDate())!
        } else {
            self.eboDate = self.myLease.earlyBuyOut!.exerciseDate
        }
        
        self.rentDueIsPaid = self.myLease.earlyBuyOut!.rentDueIsPaid
        if self.myLease.earlyBuyOut!.amount == "0.00" {
            self.eboAmount = self.myLease.getParValue(askDate: self.eboDate, rentDueIsPaid: self.rentDueIsPaid).toString(decPlaces: 2)
        } else {
            self.eboAmount = self.myLease.earlyBuyOut!.amount
            self.basisPoints = Double(self.myLease.getEBOPremium(aLease: self.myLease, exerDate: self.eboDate, aEBOAmount: self.eboAmount, rentDueIsPaid: self.rentDueIsPaid))
        }
        self.eboTerm = self.myLease.getEBOTerm(exerDate: self.eboDate)
        self.parValue = self.myLease.getParValue(askDate: self.eboDate, rentDueIsPaid: self.rentDueIsPaid).toString()
    }

    
}

struct EarlyBuyoutView_Previews: PreviewProvider {
    static var previews: some View {
        EarlyBuyoutView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
            .preferredColorScheme(.dark)
    }
}

let alertInvalidEBOAmount: String  = "The EBO amount must be equal to or greater than the par value of the lease on the exercise date and less than the lease amount!!"
