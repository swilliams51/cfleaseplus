//
//  DayCountView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct DayCountView: View {
    @ObservedObject var myLease: Lease
    @State private var interestCalcMethod: DayCountMethod = .Thirty_ThreeSixty_ConvUS
    @Binding var endingBalance: String
    @Binding var showMenu: ShowMenu
    @Binding var isDark: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @State private var endOfMonthRule: Bool = false
    @State var showPopover: Bool = false
    @State var myEOMRule = eomRuleHelp
   
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interest Calculation Options").font(.footnote)) {
                    pickerDayCountItem
                    eomRuleToggleItem
                    }
                Section(header: Text("Submit Form").font(.footnote)) {
                    textButtonsForCancelAndDoneRow
                }
                }
            
            .navigationTitle("Day Count Methods").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            interestCalcMethod = myLease.interestCalcMethod
            endOfMonthRule = myLease.endOfMonthRule
            }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $myEOMRule, isDark: $isDark)
        }
    }
    
    var pickerDayCountItem: some View {
        Picker(selection: $interestCalcMethod, label: Text("day count method:").font(.subheadline)) {
            ForEach(DayCountMethod.dayCountMethods, id: \.self) { dayCountMethod in
                Text(dayCountMethod.toString())
            }
            .font(.subheadline)
            .onChange(of: interestCalcMethod, perform: { value in
            })
        }
    }
    
    var eomRuleToggleItem: some View {
        HStack {
            Text("EOM rule")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            Toggle("", isOn: $endOfMonthRule)
        }
    }
    
    var textButtonsForCancelAndDoneRow: some View {
        HStack{
            Text("Cancel")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    self.showMenu = .closed
                    self.presentationMode.wrappedValue.dismiss()
                }
            Spacer()
            Text ("Done")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    self.myLease.interestCalcMethod = self.interestCalcMethod
                    self.myLease.endOfMonthRule = self.endOfMonthRule
                    self.showMenu = .closed
                    self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
    }
        
}

struct DayCountView_Previews: PreviewProvider {
    static var previews: some View {
        DayCountView(myLease: Lease(aDate: Date(), mode: .leasing), endingBalance: .constant("0.00"), showMenu: .constant(.open), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}
