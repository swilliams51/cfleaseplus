//
//  TValuesView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct TValuesView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var sliderThreeValue: Double = 0
    @State private var discountRateRent: String = "0.05"
    @State private var convertedValue: Double = 1000.00
    @State private var maxValue: Double = 200.00
    @State private var minValue: Double = 0.00
    @State private var discountRateResidual: String = "0.05"
    @State private var convertedValue2: Double = 1000.00
    @State private var additionalResidual: String = "0.00"
    @State private var factor: Decimal = 10000.00
    
    @State var showPopover: Bool = false
    @State var tvHelp = terminationHelp
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Inputs").font(.footnote), footer: Text("Is True Lease: \(myLease.isTrueLease().toString())")) {
                    discountRateRentItem
                    discountRateResidualItem
                    additionalResidualItem
                }
                Section(header: Text("Submit Form").font(.footnote)) {
                    textButtonsForCancelAndDoneRow
                }
                
            }
            .navigationTitle("Termination Values")
            .navigationBarTitleDisplayMode(.inline)
            navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            viewOnAppear()
        }
        .alert(isPresented: $showAlert, content: getAlert)
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    var discountRateRentItem: some View {
        VStack {
            HStack {
                Text("discount rate for rent:")
                    .font(.subheadline)
                Spacer()
                Text("\(discountRateRent.toDecimal().toPercent(2))")
                    .font(.subheadline)
            }
            Slider(value: $convertedValue, in: minValue...maxValue, step: 1) {
                
            }
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
            .onChange(of: convertedValue, perform: { newNumber in
                let newValue: Decimal = (Decimal(newNumber)) * 0.0001
                self.discountRateRent = newValue.toString(decPlaces: 5)
            })
        
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(Color.theme.accent)
                    .onTapGesture {
                        self.showPopover = true
                    }
                Spacer()
                HStack {
                    Spacer()
                    Stepper("", value: $convertedValue, in: minValue...maxValue, step: 1, onEditingChanged: { _ in
                        
                    }).labelsHidden()
                        .transformEffect(.init(scaleX: 1.0, y: 0.9))
                }
            }
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $tvHelp, isDark: $isDark)
        }
    }
    
    var discountRateResidualItem: some View {
        VStack {
            HStack {
                Text("discount rate for residual:")
                    .font(.subheadline)
                Spacer()
                Text("\(discountRateResidual.toDecimal().toPercent(2))")
                    .font(.subheadline)
            }
            Slider(value: $convertedValue2, in: minValue...maxValue, step: 1) {
                
            }
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
            .disabled(myLease.isTrueLease() ? false : true)
            .accentColor(myLease.isTrueLease() ? Color.blue : Color.gray)
            .onChange(of: convertedValue2, perform: { newNumber in
                let newValue: Decimal = (Decimal(newNumber)) * 0.0001
                self.discountRateResidual = newValue.toString(decPlaces: 5)
            })
            HStack {
                Spacer()
                Stepper("", value: $convertedValue2, in: minValue...maxValue, step: 1, onEditingChanged: { _ in
                    
                }).labelsHidden()
                    .transformEffect(.init(scaleX: 1.0, y: 0.9))
            }
            
        }
    }
    
    var additionalResidualItem: some View {
        VStack {
            HStack {
                Text("additional residual:")
                    .font((.subheadline))
                Spacer()
                Text("\(additionalResidual.toDecimal().toPercent(2))")
                    .font(.subheadline)
            }
            Slider(value: $sliderThreeValue, in: 0...20, step: 1) {
            }
            .disabled(myLease.isTrueLease() ? false : true )
            .onChange(of: sliderThreeValue, perform: { newNumber in
                additionalResidual = (newNumber / 100.0).toString()
            })
        }
    }
    
    var textButtonsForCancelAndDoneRow: some View {
        HStack {
            Text("Cancel")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                }
            Spacer()
            Text("Done")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    self.myLease.terminations!.discountRate_Rent = self.discountRateRent.toDecimal()
                    self.myLease.terminations!.discountRate_Residual = self.discountRateResidual.toDecimal()
                    self.myLease.terminations!.additionalResidual = self.additionalResidual.toDecimal()
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
        
    }
    
    private func viewOnAppear() {
        if self.myLease.terminationsExist() == true {
            self.discountRateRent = self.myLease.terminations!.discountRate_Rent.toString(decPlaces: 5)
            self.discountRateResidual = self.myLease.terminations!.discountRate_Residual.toString(decPlaces: 5)
            self.additionalResidual = self.myLease.terminations!.additionalResidual.toString(decPlaces: 5)
        } else {
            self.discountRateRent = myLease.interestRate
            self.discountRateResidual = myLease.interestRate
        }
        
        self.maxValue = self.myLease.interestRate.toDouble() / 0.0001
        self.minValue = (max(0.00, self.myLease.interestRate.toDouble() - 0.05)) / 0.0001
        
        
        self.convertedValue = self.discountRateRent.toDouble() / 0.0001
        self.convertedValue2 = self.discountRateResidual.toDouble() / 0.0001
        self.sliderThreeValue = self.additionalResidual.toDouble() * 100.0
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TValuesView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
            .preferredColorScheme(.dark)
            
    }
}

