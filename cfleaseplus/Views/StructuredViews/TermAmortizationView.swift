//
//  TermAmortizationView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct TermAmortizationView: View {
    @ObservedObject var myLease: Lease
//    @Binding var endingBalance: String
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
   
    @State var showPopover: Bool = false
    @State var helpTermAmort = termAmortHelp
    @State var amortTerm: Double = 120
    @State var startOfRange: Double = 60.0
  
    @State private var rangeOfMonths: ClosedRange<Double> = 60.0...360.0
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Input Amortizaion Term").font(.footnote),
                         footer: Text("Base Term: \(startOfRange.toInteger()) mons")) {
                    amortizationTermStepper
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                   textButtonsForCancelAndDone
                }
                
            }
            .navigationTitle("Structure Input")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .onAppear {
            self.startOfRange = myLease.getBaseTermInMons().toDouble()
            rangeOfMonths = self.startOfRange...360.0
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
    var amortizationTermStepper: some View {
        VStack {
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(Color.theme.accent)
                    .onTapGesture {
                        self.showPopover = true
                    }
                Text("amortization term in mons")
                    .font(.subheadline)
                
            }
            
            Slider(value: $amortTerm, in: rangeOfMonths, step: 1) {

            }
            .onChange(of: amortTerm) { newNumber in
                self.amortTerm = newNumber
            }
            
            HStack{
                Text("term: \(amortTerm.toInteger()) mons")
                    .font(.subheadline)
              
                Stepper("",onIncrement: {
                    if self.amortTerm < rangeOfMonths.upperBound {
                        self.amortTerm = self.amortTerm + 1.0
                    }
                },onDecrement: {
                    if self.amortTerm > rangeOfMonths.lowerBound {
                        self.amortTerm = self.amortTerm - 1.0
                    }
                })
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
            }
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $helpTermAmort, isDark: $isDark)
        }
    }
    
    var textButtonsForCancelAndDone: some View {
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
                    self.myLease.groups.termAmortization(aLease: self.myLease, amortTerm: Int(self.amortTerm))
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
    }
}

struct TermAmortizationView_Previews: PreviewProvider {
    static var previews: some View {
        TermAmortizationView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}


extension TermAmortizationView {
    func getMinTerm() -> Int {
        let minTerm: Int = myLease.getBaseTermInMons() + 12
        
        return minTerm
    }
}
