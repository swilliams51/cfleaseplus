//
//  LeaseBalanceReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct LeaseBalanceReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State var myFont: Font = reportFontSmall
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        NavigationView {
            ScrollView (.vertical, showsIndicators: false) {
                Text("\(orientation.isLandscape.toString())")
                    .foregroundColor(.clear)
                Text(textForLeaseBalance(aLease: myLease, currentFile: currentFile, isPad: isPad, isLandscape: orientation.isLandscape))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Outstanding Balance")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
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

struct LeaseBalanceReport_Previews: PreviewProvider {
    static var previews: some View {
        LeaseBalanceReport(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
    }
}
