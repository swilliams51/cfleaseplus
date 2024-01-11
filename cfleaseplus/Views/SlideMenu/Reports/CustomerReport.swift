//
//  CustomerReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct CustomerReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var includeInterestRate: Bool = true
    @State private var inclInterestRateLabel: String = "Exclude Interest Rate"
    @State private var inclInterestRateImage: String = "square"
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State var myFont: Font = reportFontSmall
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("\(orientation.isLandscape.toString())")
                    .foregroundColor(.clear)
                Text(textForCustomerReport(aLease: myLease, currentFile: currentFile, includeRate: includeInterestRate, isLandscape: orientation.isLandscape))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Customer Report")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                Menu("options") {
                    Button(action: {
                        if self.includeInterestRate == false {
                            self.includeInterestRate = true
                            self.inclInterestRateImage = "square"
                        } else {
                            self.includeInterestRate = false
                            self.inclInterestRateImage = "checkmark.square"
                          
                        }
                    
                    }) {
                        Label(inclInterestRateLabel, systemImage: inclInterestRateImage)
                    }
                }
            }//
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            if self.isPad == true {
                self.myFont = reportFontTiny
            }
        }
        .onRotate { newOrientation in
            self.orientation = newOrientation
        }
    }
}

struct CustomerReport_Previews: PreviewProvider {
    static var previews: some View {
        CustomerReport(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}
