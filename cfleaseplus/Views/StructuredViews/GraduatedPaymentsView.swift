//
//  GraduatedPaymentsView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct GraduatedPaymentsView: View {
    @ObservedObject var myLease: Lease
    @Environment(\.presentationMode) var presentationMode
    @State private var escalator: String = "0.05"
    @State private var noOfAnnualStepPayments: Int = 5
    @State private var maximumStep: Int = 10
    @State private var maxValue: Double = 1200.00
    @State private var convertedValue: Double = 500.00
    @State private var selection = 1
    
    @State var showPopover: Bool = false
    @State var escalateHelp = graduationPaymentsHelp
    @Binding var isDark: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Graduation Inputs").font(.footnote)){
                    escaltionRateItem
                    numberOfAnnualStepsItem
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                    textButtonsForCancelAndDoneRow
                }
                
            }
            .navigationTitle("Graduation Payments")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .onAppear{
            self.maximumStep = (myLease.getBaseTermInMons() / 12) - 2
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
    
    var numberOfAnnualStepsItem: some View {
        VStack {
            HStack {
                Text("number of annual steps:")
                    .font(.subheadline)
                Spacer()
                Text("\(noOfAnnualStepPayments.toString())")
                    .font(.subheadline)
            }
            HStack {
                Spacer()
                Stepper("", onIncrement: {
                    if noOfAnnualStepPayments < maximumStep {
                        noOfAnnualStepPayments = noOfAnnualStepPayments + 1
                    }
                },onDecrement: {
                    if noOfAnnualStepPayments > 1 {
                        noOfAnnualStepPayments = noOfAnnualStepPayments - 1
                    }
                })
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
                    self.myLease.groups.graduatedPayments(aLease: myLease, escalationRate: escalator.toDecimal(), noOfAnnualGraduationPayments: noOfAnnualStepPayments)
                    self.myLease.resetLease()
                  
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

struct GraduatedPaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        GraduatedPaymentsView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
    }
}
