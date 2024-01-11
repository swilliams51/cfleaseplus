//
//  DayCountReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct DayCountReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool

    @State private var myFont: Font = reportFontSmall
    @State private var maxChars: Int = reportWidthSmall
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("\(orientation.isLandscape.toString())")
                    .foregroundColor(.clear)
                Text(textForDayCount(aLease: myLease, currentFile: currentFile, isPad: isPad, isLandscape: orientation.isLandscape))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Day Count")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
           
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
}

struct DayCountReport_Previews: PreviewProvider {
    static var previews: some View {
        DayCountReport(myLease: Lease(aDate: Date(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}
