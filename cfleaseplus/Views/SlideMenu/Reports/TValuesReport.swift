//
//  TValuesReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct TValuesReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var inLieuOfRentDue: Bool = true
    @State private var inLieuLabel: String = "In Lieu of Rent Due"
    @State private var inLieuImage: String = "square"
    
    @State private var includeParValues: Bool = true
    @State private var inclParValuesLabel: String = "Remove Par Values"
    @State private var inclParValueImage: String = "square"
    
    @State private var exportAmortLabel: String = "Export as CSV"
    @State private var exportAmortImage: String = "square.and.arrow.up"
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var exportCounter: Int = 0
    
    @State var myFont: Font = reportFontSmall
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("\(orientation.isLandscape.toString())")
                    .foregroundColor(.clear)
                Text(textForTerminationValues(aLease: myLease, inLieuRent: inLieuOfRentDue, includeParValues: includeParValues, currentFile: currentFile, isPad: isPad, isLandscape: orientation.isLandscape))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Termination Values")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            excludeParValuesOption
                            inLieuOfRentDueOption
                            exportTVsButtonItem
                        }
                    }
                label: {
                    Label("options", systemImage: "plus")
                        .labelStyle(.titleOnly)
                        .foregroundColor(.red)
                }
                .font(self.myFont)
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .alert(isPresented: $showAlert, content: getAlert)
        .onAppear{
            if self.isPad == true {
                self.myFont = reportFontTiny
            }
        }
        .onRotate { newOrientation in
            self.orientation = newOrientation
        }
        
    }
    var excludeParValuesOption: some View {
        Button(action: {
            if self.includeParValues == false {
                self.includeParValues = true
                self.inclParValueImage = "square"
            } else {
                self.includeParValues = false
                self.inclParValueImage = "checkmark.square"

            }
        }) {
            Label(inclParValuesLabel, systemImage: inclParValueImage)
        }
        .font(self.myFont)
    }
    
    
    var inLieuOfRentDueOption: some View {
        Button(action: {
            if self.inLieuOfRentDue == false {
                self.inLieuOfRentDue = true
                self.inLieuImage = "square"
            } else {
                self.inLieuOfRentDue = false
                self.inLieuImage = "checkmark.square"

            }
        }) {
            Label(inLieuLabel, systemImage: inLieuImage)
        }
        .font(self.myFont)
    }
    
    var exportTVsButtonItem: some View {
        Button(action: {
            exportCounter += 1
            let csvFile: String = csvForTerminationValues(aLease: myLease, inLieuRent: inLieuOfRentDue, includeParValues: includeParValues)
            let fileName: String = currentFile + exportCounter.toString() + ".csv"
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                    try csvFile.write(to: url, atomically: true, encoding: .utf8)
                    self.alertTitle = csvTValuesSuccess(strFileName: fileName)
                    self.showAlert.toggle()
                } catch {
                    print(error.localizedDescription)
                }
      }) {
          HStack {
              Text(exportAmortLabel)
              Image(systemName: exportAmortImage)
          }
          }
        
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func csvTValuesSuccess(strFileName: String) -> String {
        let alert: String = "The current termination values report for the file \(strFileName) was successfully exported to the user's Documents folder as a csv file.  It can be opened in Numbers or Excel."
        
        return alert
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    
}

struct TValuesInputsView_Previews: PreviewProvider {
    static var previews: some View {
        TValuesReport(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.dark)
    }
}
