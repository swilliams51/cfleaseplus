//
//  ChopView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct ChopView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var selfIsNew: Bool
    @Binding var showMenu: ShowMenu
    @State private var chopDate: Date = today()
    
    @State var showPopover: Bool = false
    @State var cutOff = cutOffHelp
    @Environment(\.presentationMode) var presentationMode
    @Binding var isDark: Bool
    
    var body: some View {
        NavigationView{
            Form{
                Section (header: Text("Effective Date").font(.footnote)) {
                  chopDatePickerItem
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                   textButtonsForCancelAndDoneRow
                }
            }
            .navigationTitle("Cut-Off").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .onAppear{
            self.chopDate = self.myLease.fundingDate
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
        
    var chopDatePickerItem: some View {
        HStack {
            Text("cut-off date")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            DatePicker("", selection: $chopDate, in: chopDates, displayedComponents:[.date])
                .onChange(of: chopDate, perform: { value in
                    
                })
            
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $cutOff, isDark: $isDark)
        }
            
    }
    
    var chopDates: ClosedRange<Date> {
        var startDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: myLease.fundingDate)!
        let endDate: Date = Calendar.current.date(byAdding: .month, value: -12, to: myLease.getMaturityDate())!
        
        if startDate > endDate {
            startDate = endDate
        }
        
        return startDate...endDate
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
                    self.myLease.resetLeaseToChop(modDate: self.chopDate)
                    self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 3)
                    if abs(self.myLease.getEndingBalance()) > toleranceAmounts {
                        for x in 0..<self.myLease.groups.items.count {
                            if self.myLease.groups.items[x].locked == true && self.myLease.groups.items[x].noOfPayments > 1 {
                                self.myLease.groups.items[x].locked = false
                            }
                        }
                        self.myLease.solveForUnlockedPayments3()
                    }
                    self.selfIsNew = true
                    self.showMenu = .closed
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
        
    }
    
}

struct ChopView_Previews: PreviewProvider {
    static var previews: some View {
        ChopView(myLease: Lease(aDate: today(), mode: .leasing),endingBalance: .constant("0.00"), selfIsNew: .constant(true), showMenu: .constant(.closed), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}
