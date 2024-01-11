//
//  PreferencesView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct PreferencesView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var currentFile: String
    @Binding var selfIsNew: Bool
    @Binding var isDark: Bool
    
    @AppStorage("maxNoFiles") var maximumNoOfFiles: Int = 20
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    
    @State var saveCurrentAsDefault: Bool = false
    @State var savedDefaultExists: Bool = true
    @State var showPopover: Bool = false
    @State var defaultHelp = defaultNewHelp
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @State var maxAmount: Int = 4
    @State var maxInterestRate: Int = 30
    @State var maxEBOPremium: Int = 150
    @State var maxFiles: Int = 20
    @State var maxBaseTerm: Int = 120
    @State var maxTermOnEntry: Int = 20
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Maximum Values").font(.footnote)) {
                    maxNoSavedFilesItems
                }
                Section(header: Text("Default Lease Parameters").font(.footnote)) {
                    defaultNewLeaseItem
                    saveCurrentAsDefaultItem
                }
                
                Section(header: Text("Color Scheme").font(.footnote)) {
                    colorSchemeItem
                }
                
                Section (header: Text("Sumbit Form").font(.footnote)) {
                    HStack {
                        buttonCancelItem
                        Spacer()
                        buttonDoneItem
                    }
                }
                .navigationTitle("Preferences")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            self.maxFiles = self.maximumNoOfFiles
            if self.savedDefaultLease == "No_Data" {
                self.savedDefaultExists = false
            }
        }
        .alert(isPresented: $showAlert, content: getAlert)
    }


    var maxNoSavedFilesItems: some View {
        Stepper("saved files: \(maxFiles)", value: $maxFiles, in: 10...50, step: 1)
            .font(.subheadline)
    }
    
    var defaultNewLeaseItem: some View {
        HStack {
            Text(useSavedAsDefault ? "use saved:" : "use default:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            Toggle("", isOn: $useSavedAsDefault)
                .disabled(savedDefaultExists ? false : true )
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $defaultHelp, isDark: $isDark)
        }
    }
    
    var saveCurrentAsDefaultItem: some View {
        HStack {
            Text("save current:")
                .font(.subheadline)
            Toggle("", isOn: $saveCurrentAsDefault)
        }
    }
    
    var colorSchemeItem: some View {
        Toggle(isOn: $isDark) {
            Text(isDark ? "dark mode is on:" : "light mode is on:")
                .font(.subheadline)
        }
    }
    
    var buttonCancelItem: some View {
        Button(action: {}) {
            Text("Cancel")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var buttonDoneItem: some View {
        Button(action: {}) {
            Text("Done")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.maximumNoOfFiles = self.maxFiles
            
            if self.saveCurrentAsDefault == true {
                resetCurrentDefaultNew()
            }
            self.presentationMode.wrappedValue.dismiss()
        }
        
    }
    
    private func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    private func resetCurrentDefaultNew() {
        if isLeaseSavable() {
            self.savedDefaultLease = writeLeaseAndClasses(aLease: myLease)
        } else {
            alertTitle = alertDefaultLease
            showAlert.toggle()
        }
    }
    
   
    
   
    
 
    
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(myLease: Lease(aDate: today(), mode: .leasing), endingBalance: .constant("0.00"), currentFile: .constant("file is new"), selfIsNew: .constant(false), isDark: .constant(true))
            .preferredColorScheme(.dark)
    }
}

extension PreferencesView {
    
    func isLeaseSavable () -> Bool {
        if self.myLease.interimGroupExists() == true {
            return false
        }
        
        return true
    }
    
}

let alertDefaultLease: String = "A default new lease cannot include an interim term, i.e., the base term commencement date must equal the funding date."
let alertMaxBaseTerm: String = "You have set the maximum base term to be equal or greater than 20 years.  The maximum interest will be reset to the lowest maximum rate."
let alertNewLimits: String = "One or more of the new maximum values are less than those of the current lease.  The current Lease will be reset the default new."
