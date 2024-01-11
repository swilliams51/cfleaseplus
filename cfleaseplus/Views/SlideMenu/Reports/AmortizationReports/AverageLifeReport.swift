//
//  AverageLifeReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct AverageLifeReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var myFont: Font = reportFontSmall
        
    var body: some View {
        NavigationView {
            ScrollView (.vertical, showsIndicators: false) {
                Text("\(orientation.isLandscape.toString())")
                    .foregroundColor(.clear)
                Text(textForAverageLife(aLease:myLease, currentFile:currentFile, isPad: isPad, isLandscape: orientation.isLandscape))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Average Life")
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

struct AverageLifeReport_Previews: PreviewProvider {
    static var previews: some View {
        AverageLifeReport(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
    }
}
