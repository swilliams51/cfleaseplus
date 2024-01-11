//
//  PVOfRentsReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct PVOfRentsProof: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var acctgType: String = "Lessor"
    @State private var acctgImage: String = "checkmark.square"
    @State private var acctgForLessor: Bool = false
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var myFont: Font = reportFontSmall
    @State private var maxChars: Int = reportWidthSmall
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("\(orientation.isLandscape.toString())")
                    .foregroundColor(.clear)
                Text(textForPVOfRentProof(aLease: myLease, currentFile: currentFile, isLessor: acctgForLessor, isPad: isPad, isLandscape: orientation.isLandscape))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("PV of Minimum Rents")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar{
                Menu("options") {
                    acctgForLessorButtonItem
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            if self.isPad == true {
                self.myFont = reportFontTiny
                self.maxChars = reportWidthTiny
            }
        }
        .onRotate { newOrientation in
            self.orientation = newOrientation
        }
    }
    
    var acctgForLessorButtonItem: some View {
        Button(action: {
            if self.acctgForLessor == false {
                setAcctgForLessee()
            } else {
                setAcctgForLessor()
            }
        }) {
            HStack {
                Text(acctgType)
                Image(systemName: acctgImage)
            }
        }
    }
    
    func setAcctgForLessee() {
        self.acctgType = "Lessee"
        self.acctgForLessor = true
    }
    
    func setAcctgForLessor() {
        self.acctgType = "Lessor"
        self.acctgForLessor = false
    }
    
}

struct PVOfRentsProof_Previews: PreviewProvider {
    static var previews: some View {
        PVOfRentsProof(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}
