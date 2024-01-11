//
//  AnnualInterestReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct AnnualInterestReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var maxChars: Int = reportWidthSmall
    @State private var myFont: Font = reportFontSmall
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                Text("\(orientation.isLandscape.toString())")
                    .foregroundColor(.clear)
                Text(textForAnnualInterestExpense(aLease:myLease, currentFile:currentFile, isPad: isPad, isLandscape: orientation.isLandscape ))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .navigationTitle("Book Income Report")
        }
        .onRotate { newOrientation in
            self.orientation = newOrientation
        }
    }
}

struct AnnualInterestReport_Previews: PreviewProvider {
    static var previews: some View {
        AnnualInterestReport(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
    }
}
