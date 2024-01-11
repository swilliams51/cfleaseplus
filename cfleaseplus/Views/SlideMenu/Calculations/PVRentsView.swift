//
//  PVRentsView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct PVRentsView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var useImplicitRate: Bool = true
    @State private var implicitRate: String = "0.05"
    @State private var specifiedRate: String = "0.05"
    @State private var discountRate: String = "0.05"
    @State private var editRateStarted: Bool = false
    @State private var editAmountStarted: Bool = false
    
    @State private var specifiedRateOnEntry: String = "0.00"
    @State private var residualIsGuaranteed: Bool = false
    @State private var residualGuarantyAmount: String = "0.00"
    @State private var residualGuarantyOnEntry: String = "0.00"
    @State private var calculateMaxGuaranty:Bool = false
    @State private var pctBookedResidual: Decimal = 0.00
    @State private var amtBookedResidual: String = "0.00"
    @State private var pctTotalPV: String = "100.00"

    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @State var showPopover: Bool = false
    @State var rateHelp = discountRateHelp
    
    @FocusState private var specifiedRateIsFocused: Bool
    @FocusState private var guarantyAmountIsFocused: Bool
    private let pasteBoard = UIPasteboard.general
    
    var defaultInactive: Color = Color.theme.inActive
    var defaultActive: Color = Color.theme.active
    var defaultCalculated: Color = Color.theme.calculated
    var activeButton: Color = Color.theme.accent

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Lease Discount rate").font(.footnote)) {
                    useImplicitRateOptionRow
                    implicitRateRow
                    discountRateRow
                }
                
                Section(header: Text("Lessee Residual Guaranty").font(.footnote), footer: Text("Booked Residual: " + pctBookedResidual.toPercent(2))) {
                    residualIsGuaranteedRow
                    calculateMaxGtyOptionRow
                        .disabled(residualIsGuaranteed ? false : true)
                    guaranteedAmountRow
                        .disabled(residualIsGuaranteed ? false : true)
                }
                
                Section(header: Text("results").font(.footnote)) {
                    resultsRow
                }
                
                Section(header: Text("submit form").font(.footnote)) {
                    textButtonsForCancelAndDoneRow
                }
            }
            .navigationTitle("PV of Lease Obligations")
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
    
    var useImplicitRateOptionRow: some View {
        Toggle(isOn: $useImplicitRate) {
            Text(useImplicitRate ? "use implicit rate:" : "use specified rate:")
                .font(.subheadline)
                .onChange(of: useImplicitRate) { value in
    
                    if self.residualIsGuaranteed == true {
                        if self.calculateMaxGuaranty == true {
                            recalculate()
                        } else {
                            if residualGuarantyAmount.toDecimal() > 0.0 {
                                residualGuarantyAmount = min(residualGuarantyAmount.toDecimal(),amtBookedResidual.toDecimal()).toString(decPlaces: 5)
                            }
                            pvOfTotalObligations()
                        }
                    } else {
                        residualGuarantyAmount = "0.00"
                        pvOfTotalObligations()
                    }
                }
        }
    }
    
    var implicitRateRow: some View {
        HStack {
            Text("implicit rate:")
                .font(.subheadline)
                .foregroundColor(useImplicitRate ? defaultActive : defaultInactive)
            Spacer()
            Text(implicitRate.toDecimal().toPercent(3))
                .font(.subheadline)
                .foregroundColor(useImplicitRate ? defaultActive : defaultInactive)
                .disabled(useImplicitRate ? false : true)
        }
        
    }
    
    var discountRateRow: some View {
        HStack{
            Text(useImplicitRate ? "specified rate:" : "specified rate: \(Image(systemName: "return"))")
                .font(.subheadline)
                .foregroundColor(useImplicitRate ? defaultInactive : defaultActive)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $specifiedRate,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editRateStarted = true
                }})
                    .disabled(useImplicitRate ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($specifiedRateIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\((rateFormatted(editStarted: editRateStarted)))")
                    .font(.subheadline)
                    .foregroundColor(useImplicitRate ? defaultInactive : defaultActive)
            }
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $rateHelp, isDark: $isDark)
        }
        
    }
    
    var residualIsGuaranteedRow: some View {
        Toggle(isOn: $residualIsGuaranteed) {
            Text(residualIsGuaranteed ? "residual is guaranteed:" : "no residual guaranty:")
                .font(.subheadline)
                .onChange(of: residualIsGuaranteed) { value in
                    if residualIsGuaranteed == false {
                        self.calculateMaxGuaranty = false
                        self.residualGuarantyAmount = "0.00"
                    } else {
                        self.residualGuarantyAmount = self.amtBookedResidual
                        self.residualGuarantyOnEntry = self.residualGuarantyAmount
                    }
                    pvOfTotalObligations()
                }
        }

    }

    var calculateMaxGtyOptionRow: some View {
        Toggle(isOn: $calculateMaxGuaranty) {
            Text(calculateMaxGuaranty ? "calc max guaranty (90% test):" : "specify guaranty amount:")
                .font(.subheadline)
                .onChange(of: calculateMaxGuaranty) { value in
                    if value == true {
                        recalculate()
                    } else {
                        if residualIsGuaranteed == true {
                            self.residualGuarantyAmount = self.amtBookedResidual
                        } else {
                            self.residualGuarantyAmount = "0.00"
                        }
                    }
                    pvOfTotalObligations()
                }
        }
    }
    
    var guaranteedAmountRow: some View {
        HStack{
            Text(enterSpecifiedAmount() ? "amount: \(Image(systemName: "return"))" : "amount:")
                .font(.subheadline)
                .foregroundColor(colorGuarantyAmount())
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $residualGuarantyAmount,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editAmountStarted = true
                }})
                    .disabled(calculateMaxGuaranty ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($guarantyAmountIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(guaranteedAmountFormatted(editStarted: editAmountStarted))")
                    .font(.subheadline)
                    .foregroundColor(colorGuarantyAmount())
            }
        }
    }
    
    var resultsRow: some View {
        HStack{
            Text("PV Obligations:")
                .font(.subheadline)
                .foregroundColor(defaultInactive)
            Spacer()
            Text("\(pctTotalPV)")
                .font(.subheadline)
                .foregroundColor(defaultInactive)
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
                        if self.useImplicitRate == true {
                            self.discountRate = self.implicitRate
                        } else {
                            self.discountRate = self.specifiedRate
                        }
                        self.myLease.leaseObligations = Obligations(aDiscountRate: self.discountRate, aResidualGuarantyAmount: self.residualGuarantyAmount)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }
    
    //Mark: functions
    func colorGuarantyAmount() -> Color {
        if residualIsGuaranteed == false {
            return defaultInactive
        } else if calculateMaxGuaranty == false {
            return defaultActive
        } else {
            return defaultCalculated
        }
    }
    
    func decimalpadIsActive() -> Bool {
        var padIsActive: Bool = false
        if specifiedRateIsFocused == true || guarantyAmountIsFocused == true {
            padIsActive = true
        }
        
        return padIsActive
    }
    
    func enterSpecifiedAmount() -> Bool {
        if residualIsGuaranteed == false {
            return false
        } else {
            if calculateMaxGuaranty == true {
                return false
            } else {
                return true
            }
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func guaranteedAmountFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return residualGuarantyAmount
        } else {
            return residualGuarantyAmount.toDecimal().toCurrency(false)
        }
    }
    
    func maxResidualGuaranty() -> Decimal {
        return myLease.getTotalResidual()
    }
    
    
    func rateFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return specifiedRate
        } else {
            return specifiedRate.toDecimal().toPercent(3)
        }
    }
    
    func recalculate() {
        var maxGuaranty: Decimal = self.amtBookedResidual.toDecimal()

        if self.calculateMaxGuaranty == true {
            if self.useImplicitRate == true {
                maxGuaranty = max(0.00,self.myLease.getMaxResidualGuaranty(discountRate: self.implicitRate.toDecimal()))
            } else {
                maxGuaranty = max(0.00,self.myLease.getMaxResidualGuaranty(discountRate: self.specifiedRate.toDecimal()))
            }
        }
        if maxGuaranty == 0.00 {
            self.residualIsGuaranteed = false
        }
        self.residualGuarantyAmount = maxGuaranty.toString(decPlaces: 5)
        pvOfTotalObligations()
    }
    
    func percentToAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * self.myLease.amount.toDecimal()
        return decAmount.toString(decPlaces: 3)
    }
    
    func pvOfTotalObligations() {
        var myDiscountRate: String = self.specifiedRate
        if self.useImplicitRate == true {
            myDiscountRate = self.implicitRate
        }
        let pvRents: Decimal = myLease.getPVOfRents(discountRate: myDiscountRate.toDecimal())
        let pvResidualGuaranty = myLease.getPVOfResidualGuaranty(discountRate: myDiscountRate.toDecimal(), residualGuaranty: residualGuarantyAmount.toDecimal())
        let lesseeFee: Decimal = myLease.fees?.totalCustomerPaidFees() ?? 0.0
        
        let totalPV: Decimal = pvRents + pvResidualGuaranty + lesseeFee
        let amount: Decimal = myLease.amount.toDecimal()
        
        
        pctTotalPV = (totalPV / amount).toPercent(3)
    }
    
    func clearAllText() {
        if self.specifiedRateIsFocused {
            self.specifiedRate = ""
        } else {
            self.residualGuarantyAmount = ""
        }
    }
    
    func copyToClipboard() {
        if self.specifiedRateIsFocused {
            pasteBoard.string = self.specifiedRate
        } else {
            pasteBoard.string = self.residualGuarantyAmount
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.specifiedRateIsFocused {
                    self.specifiedRate = string
                } else {
                    self.residualGuarantyAmount = string
                }
            }
        }
    }
    
    func updateForCancel() {
        if editRateStarted == true {
            self.specifiedRate = self.specifiedRateOnEntry
            updateForDiscountRate()
        }
        if editAmountStarted == true {
            self.residualGuarantyAmount = self.residualGuarantyOnEntry
            updateForGuaranteedResidual()
        }
        self.specifiedRateIsFocused = false
        self.guarantyAmountIsFocused = false
    }
    
    func updateForDiscountRate() {
        self.editRateStarted = false
        if isInterestRateValid(strRate: specifiedRate, decLow: 0.0, decHigh: 0.50, inclusiveLow: true, inclusiveHigh: true) == false {
            specifiedRate = specifiedRateOnEntry
            self.alertTitle = alertInvalidSpecifiedRate
            self.showAlert.toggle()
        } else {
            if calculateMaxGuaranty == true {
                recalculate()
            }
        }
        pvOfTotalObligations()
    }
    
    func updateForGuaranteedResidual() {
        self.editAmountStarted = false
        if self.residualGuarantyAmount.toDecimal() < 1.0 {
            residualGuarantyAmount = percentToAmount(percent: residualGuarantyAmount)
        }
        if isAmountValid(strAmount: residualGuarantyAmount, decLow: 0.00, decHigh: amtBookedResidual.toDecimal(), inclusiveLow: false, inclusiveHigh: true) == false {
            self.residualGuarantyAmount = self.amtBookedResidual
            self.alertTitle = alertInvalidGuarantyAmount
            self.showAlert.toggle()
        }
        pvOfTotalObligations()
    }
    
    func updateForSubmit() {
        if editRateStarted == true {
            updateForDiscountRate()
        }
        if editAmountStarted == true {
            updateForGuaranteedResidual()
        }
        self.specifiedRateIsFocused = false
        self.guarantyAmountIsFocused = false
    }
    
    private func viewOnAppear() {
        self.implicitRate = self.myLease.implicitRate().toString(decPlaces: 5)
        self.specifiedRate = self.myLease.leaseObligations?.discountRate ?? "0.00"
        self.specifiedRateOnEntry = self.specifiedRate
        self.residualGuarantyAmount = self.myLease.leaseObligations!.residualGuarantyAmount
        if self.residualGuarantyAmount.toDecimal() > 0.0 {
            self.residualIsGuaranteed = true
            self.residualGuarantyOnEntry = self.residualGuarantyAmount
        }
        
        if amountsAreEqual(aAmt1: self.implicitRate.toDecimal(), aAmt2: self.specifiedRate.toDecimal(), aLamda: 0.0005) == false {
            useImplicitRate = false
        }
        
        self.amtBookedResidual = myLease.getTotalResidual().toString(decPlaces: 5)
        let residualPercent: Decimal = myLease.getTotalResidual() / myLease.amount.toDecimal()
        self.pctBookedResidual = residualPercent
        
        pvOfTotalObligations()
    }
    
}

struct PVRentsView_Previews: PreviewProvider {
    static var previews: some View {
        PVRentsView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
            .preferredColorScheme(.dark)
    }
}

let alertInvalidGuarantyAmount: String = "The amount of the lessee's residual guaranty must be equal to or greater than zero but cannot exceed the residual amount!!"
let alertInvalidCalculatedGuarantyAmount: String = "The calculated amount of the residual guaranty is less then zero. Therefore, the lessee residual guaranty will be set to no residual guaranty!!"
let alertInvalidSpecifiedRate: String = "The discount rate must equal to or greater than 0.00% and less than the maximum allowable rate!!"
