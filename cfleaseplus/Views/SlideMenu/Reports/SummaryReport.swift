//
//  SummaryReport.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct SummaryReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @AppStorage("longPressTip") var longPress: Bool = true
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State var maxChars: Int = reportWidthSmall
    @State var myFont: Font = reportFontSmall
    @State private var longPressShow: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationView {
                    VStack {
                        if self.longPressShow == true {
                            instructionViewItem
                        }
                        ScrollView (.vertical, showsIndicators: false) {
                            Text("\(orientation.isLandscape.toString())")
                                .foregroundColor(.clear)
                            Text(textForInvestorReport(aLease: myLease, currentFile: currentFile, isLandscape: orientation.isLandscape))
                                .font(self.myFont)
                                .foregroundColor(self.isDark ? .white : .black)
                                .textSelection(.enabled)
                        }
                        .navigationViewStyle(.stack)
                        .toolbar(content: {
                             ToolbarItem(placement: .principal, content: {
                             Text("Investor Summary Report")
                                     .font(.subheadline)
                                     .foregroundColor(self.isDark ? .white : .black)
                         })})
                    }
                }
            }
            .environment(\.colorScheme, self.isDark ? .dark : .light)
            .onAppear {
                if self.isPad == true {
                    self.maxChars = reportWidthTiny
                    self.myFont = reportFontTiny
                }
                if longPress == false {
                    longPressShow = false
                }
            }
            .onRotate { newOrientation in
                self.orientation = newOrientation
            }
        }
    }
    var instructionViewItem: some View {
        VStack(alignment: .center, spacing: 0, content: {
            Text("")
                .frame(width: 175, height: 5, alignment: .center)
            Text("Long press any report screen to share the report via text or email.")
                .padding(.leading)
                .padding(.trailing)
                .frame(width: 190, height: 75, alignment: .center)
                .multilineTextAlignment(.center)
                .background(isDark ? Color.white : Color.black)
                .foregroundColor(isDark ? Color.black : Color.white)
                .font(.footnote)
                .border(Color.white, width: 1)
                
            Text("Got it!")
                .frame(width: 190, height: 40, alignment: .center)
                .multilineTextAlignment(.center)
                .background(Color.black)
                .foregroundColor(.blue)
                .font(.footnote)
                .onTapGesture {
                    self.longPressShow = false
                    self.longPress = false
                }
        })
        .navigationViewStyle(.stack)
    }

}

struct SummaryReportView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryReport(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}
