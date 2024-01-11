//
//  SkipPaymentsView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct SkipPaymentsView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var skipMonths: [Int] = [Int]()
    
    @State private var janSkip: Bool = false
    @State private var febSkip: Bool = false
    @State private var marSkip: Bool = false
    @State private var aprSkip: Bool = false
    @State private var maySkip: Bool = false
    @State private var junSkip: Bool = false
    @State private var julSkip: Bool = false
    @State private var augSkip: Bool = false
    @State private var sepSkip: Bool = false
    @State private var octSkip: Bool = false
    @State private var novSkip: Bool = false
    @State private var decSkip: Bool = false
    
    
    var body: some View {
        NavigationView{
            Form {
                Section (header: Text("Months to Skip")){
                    
                    VStack {
                        HStack {
                            Toggle(isOn: $janSkip){
                                Text("Jan")
                            }
                            .font(.subheadline)
                            .frame(width: 100)
                            Spacer()
                            Toggle(isOn: $febSkip){
                                Text("Feb")
                            }.font(.subheadline)
                                .frame(width:100)
                        }
                        HStack {
                            Toggle(isOn: $marSkip){
                                Text("Mar")
                            }.font(.subheadline)
                                .frame(width: 100)
                            Spacer()
                            Toggle(isOn: $aprSkip){
                                Text("Apr")
                            }.font(.subheadline)
                                .frame(width:100)
                        }
                        HStack {
                            Toggle(isOn: $maySkip){
                                Text("May")
                            }.font(.subheadline)
                                .frame(width: 100)
                            Spacer()
                            Toggle(isOn: $junSkip){
                                Text("June")
                            }.font(.subheadline)
                                .frame(width:100)
                        }
                        HStack {
                            Toggle(isOn: $julSkip){
                                Text("Jul")
                            }.font(.subheadline)
                                .frame(width: 100)
                            Spacer()
                            Toggle(isOn: $augSkip){
                                Text("Aug")
                            }.font(.subheadline)
                                .frame(width:100)
                        }
                        HStack {
                            Toggle(isOn: $sepSkip){
                                Text("Sep")
                            }.font(.subheadline)
                                .frame(width: 100)
                            Spacer()
                            Toggle(isOn: $octSkip){
                                Text("Oct")
                            }.font(.subheadline)
                                .frame(width:100)
                        }
                        HStack {
                            Toggle(isOn: $novSkip){
                                Text("Nov")
                            }.font(.subheadline)
                                .frame(width: 100)
                            Spacer()
                            Toggle(isOn: $decSkip){
                                Text("Dec")
                            }.font(.subheadline)
                                .frame(width:100)
                        }
                    }
                }
                
                Section (header: Text("Submit Form")){
                   textButtonsForCancelAndDoneRow
                }
                
            }
            .navigationTitle("Skip Payments")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
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
                    self.addSkipMonths()
                    if skipMonths.count > 0 {
                        self.myLease.groups.skipPayments(aLease: myLease, skipMonths: skipMonths)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }
        
    var cancelButtonItem: some View {
        Button(action: {}) {
            Text("Cancel")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    var doneButtonItem: some View {
        Button(action: {}) {
            Text("Done")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.addSkipMonths()
            if skipMonths.count > 0 {
                self.myLease.groups.skipPayments(aLease: myLease, skipMonths: skipMonths)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func addSkipMonths() {
        if self.janSkip == true {
            self.skipMonths.append(1)
        }
        if self.febSkip == true {
            self.skipMonths.append(2)
        }
        if self.marSkip == true {
            self.skipMonths.append(3)
        }
        if self.aprSkip == true {
            self.skipMonths.append(4)
        }
        if self.maySkip == true {
            self.skipMonths.append(5)
        }
        if self.junSkip == true {
            self.skipMonths.append(6)
        }
        if self.julSkip == true {
            self.skipMonths.append(7)
        }
        if self.augSkip == true {
            self.skipMonths.append(8)
        }
        if self.sepSkip == true {
            self.skipMonths.append(9)
        }
        if self.octSkip == true {
            self.skipMonths.append(10)
        }
        if self.novSkip == true {
            self.skipMonths.append(11)
        }
        if self.decSkip == true {
            self.skipMonths.append(12)
        }
    }
    
}

struct SkipPaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        SkipPaymentsView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false))
    }
}
