//
//  EscalatorView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct EscalatorView: View {
    @ObservedObject var myLease: Lease
    @Environment(\.presentationMode) var presentationMode
    @State private var escalator: String = "0.05"
    @State private var maxValue: Double = 1000.00
    @State private var convertedValue: Double = 500.00
    
    @State private var selection = 1
    
    @State var showPopover: Bool = false
    @State var escalateHelp = escalationRateHelp
    @Binding var isDark: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Input Escalation Rate").font(.footnote)){
                    escaltionRateItem
                    frequencyPickerItem
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                    textButtonsForCancelAndDoneRow
                }
                
            }
            .navigationTitle("Escalation Structure")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
       
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
    
    var escaltionRateItem: some View {
        VStack {
            HStack {
                Text("annual escalator:")
                    .font(.subheadline)
                Image(systemName: "questionmark.circle")
                    .foregroundColor(Color.theme.accent)
                    .onTapGesture {
                        self.showPopover = true
                    }
                Spacer()
                Text("\(escalator.toDecimal().toPercent(2))")
                    .font(.subheadline)
            }
            Slider(value: $convertedValue, in: 0...maxValue, step: 1) {
                
            }
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
            .onChange(of: convertedValue, perform: { newNumber in
                let newValue: Decimal = (Decimal(newNumber)) * 0.0001
                self.escalator = newValue.toString(decPlaces: 5)
            })
        
            Stepper("",onIncrement: {
                convertedValue = convertedValue + 1
            },onDecrement: {
                convertedValue = convertedValue - 1
            })
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $escalateHelp, isDark: $isDark)
        }
    }
    
    var frequencyPickerItem: some View {
        Picker(selection: $selection, label: Text("frequency:").font(.subheadline)) {
            ForEach(getFactors(), id: \.self) { freq in
                Text(getfrequencyText(years: freq))
                    .font(.subheadline)
            }
                
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
                    self.myLease.groups.escalate(aLease: myLease, inflationRate: escalator.toDecimal(), steps: selection)
                    self.myLease.solveForRate3()
                    if abs(self.myLease.getEndingBalance()) > toleranceAmounts {
                        for x in 0..<self.myLease.groups.items.count {
                            if self.myLease.groups.items[x].locked == true && self.myLease.groups.items[x].noOfPayments > 1 {
                                self.myLease.groups.items[x].locked = false
                            }
                        }
                        self.myLease.solveForUnlockedPayments3()
                    }
                    self.myLease.resetLease()
                    //self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
    }
    
    func getFactors() -> [Int] {
        return factors(numberIn: myLease.getBaseTermInMons() / 12)
    }
    
    func getfrequencyText(years: Int) -> String {
        if years == 1 {
            return "every year"
        } else {
            return "every " + years.toString() + " years"
        }
    }
    
}

struct EscalatorView_Previews: PreviewProvider {
    static var previews: some View {
        EscalatorView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}
