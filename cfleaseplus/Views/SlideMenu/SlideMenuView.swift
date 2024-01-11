//
//  SlideMenuView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct SlideMenuView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var showMenu: ShowMenu
    @Binding var currentFile: String
    @Binding var fileExported: Bool
    @Binding var exportSuccessful: Bool
    @Binding var fileImported: Bool
    @Binding var importSuccessful: Bool
    @Binding var noOfSavedFiles: Int
    @Binding var counterSavedFiles: Bool
    @Binding var selfIsNew: Bool
    @Binding var isPad: Bool
    @Binding var isDark: Bool
    @Binding var level: Level
    
    @State private var fontSize: CGFloat = 18
    @State private var padding: CGFloat = 10
    @State private var myBackColor:Color = Color.black
    @State private var myForeColor: Color = Color.white
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
   
    var body: some View {
        ZStack {
            self.myBackColor.ignoresSafeArea()
            VStack {
                fileMenuItem
                    .padding(.top, 40)
                dayCountMenuItem
                chopMenuItem
                calculationsMenuItem
                reportsMenuItem
                preferencesMenuItem
                aboutMenuItem
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear{
            if self.isDark == true {
                self.myBackColor = Color(UIColor.lightGray)
                self.myForeColor = Color.black
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .alert(isPresented: $showAlert, content: getAlert)
    }
    
    var fileMenuItem:some View {
        HStack {
            NavigationLink(destination: FileMenuView(myLease: myLease, showMenu: $showMenu, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, noOfSavedFiles: $noOfSavedFiles, counterSavedFiles: $counterSavedFiles, selfIsNew: $selfIsNew, isPad: $isPad, isDark: $isDark, level: $level)) {
                SlideMenuItemView(fontSize: fontSize, textMenu: "File", menuImage: "filemenu.and.selection", foreColor: myForeColor)
            }
            Spacer()
        }
    
    }
    
    var dayCountMenuItem: some View {
        HStack {
            NavigationLink(destination: DayCountView(myLease: myLease, endingBalance: $endingBalance, showMenu: $showMenu, isDark: $isDark) ) {
                SlideMenuItemView(fontSize: fontSize, textMenu: "Day Count", menuImage: "calendar", foreColor: myForeColor)
            }.disabled(self.selfIsNew ? true : false)
            Spacer()
        }
    }
    
    var chopMenuItem: some View {
        HStack {
            NavigationLink(destination: ChopView(myLease: myLease, endingBalance: $endingBalance, selfIsNew: $selfIsNew, showMenu: $showMenu, isDark: $isDark)){
                SlideMenuItemView(fontSize: fontSize, textMenu: "Cut-Off", menuImage: "scissors", foreColor: myForeColor)
            }.disabled(self.selfIsNew ? true : false)
            Spacer()
        }
    }
    
    var targetingMenuItem: some View {
        HStack{
            
        }
    }
    
    var spreadsMenuItem: some View {
        HStack{
            
        }
    }
    
    var calculationsMenuItem: some View {
        HStack {
            NavigationLink(destination: CalculationsView(myLease: myLease, isDark: $isDark, showMenu: $showMenu)) {
                SlideMenuItemView(fontSize: fontSize, textMenu: "Calculations", menuImage: "sum", foreColor: myForeColor)
            }
            Spacer()
        }
    }
    
    var reportsMenuItem: some View {
        HStack {
            NavigationLink(destination: ReportsView(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad, level: $level)) {
                SlideMenuItemView(fontSize: fontSize, textMenu: "Reports", menuImage: "doc.text", foreColor: myForeColor)
            }
            Spacer()
        }
    }
    
    var preferencesMenuItem: some View {
        HStack {
            NavigationLink (destination: PreferencesView(myLease: myLease,endingBalance: $endingBalance, currentFile: $currentFile, selfIsNew: $selfIsNew, isDark: $isDark)) {
                SlideMenuItemView(fontSize: fontSize, textMenu: "Preferences", menuImage: "gearshape", foreColor: myForeColor)
            }
            Spacer()
        }
    }
    
    var aboutMenuItem: some View {
        HStack {
            NavigationLink(destination: AboutView(isDark: $isDark, showMenu: $showMenu)) {
                SlideMenuItemView(fontSize: fontSize, textMenu: "About", menuImage: "questionmark.circle", foreColor: myForeColor)
            }
            Spacer()
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func balanceIsZero() -> Bool {
        let balance: Decimal = endingBalance.toDecimal()
        if abs(balance) < 0.075 {
            return true
        }
        return false
    }
}

struct SlideMenuView_Previews: PreviewProvider {

    static var previews: some View {
        SlideMenuView(myLease: Lease(aDate: today(), mode: .leasing), endingBalance: .constant("0.00"), showMenu: .constant(.open), currentFile: .constant("file is new"), fileExported: .constant(false), exportSuccessful: .constant(false), fileImported: .constant(false), importSuccessful: .constant(false), noOfSavedFiles: .constant(0), counterSavedFiles: .constant(false), selfIsNew: .constant(false), isPad: .constant(false), isDark: .constant(true), level: .constant(.basic))
    }
}

struct SlideMenuItemView: View {

    let fontSize: CGFloat
    let textMenu: String
    let menuImage: String
    let foreColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: menuImage)
                .imageScale(.medium)
                .foregroundColor(foreColor)
                .padding(.leading)
                .padding(.bottom)
            Text (textMenu)
                .foregroundColor(foreColor)
                .font(.subheadline)
                .padding(.leading)
                .padding(.bottom)
        }
    }
}
