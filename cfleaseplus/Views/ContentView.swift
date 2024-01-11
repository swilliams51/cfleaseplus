//
//  ContentView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var myLease: Lease = Lease(aDate: today(),mode: .leasing)
   
    @State var isPad: Bool = false
    @State var level:Level = .basic
    @State var premiumPrice: Decimal = 1.00
    
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("isDarkMode") var isDark: Bool = false
    
    @State private var currentFile: String = "file is new"
    @State private var noOfSavedFiles: Int = 0
    @State private var fileWasSaved: Bool = false
    @State private var endingBalance: String = "0.0"
    
    @State private var showMenu: ShowMenu = .closed
    
    @State private var fileExported: Bool = false
    @State private var exportSuccessful: Bool = false
    @State private var fileImported: Bool = false
    @State private var importSuccessful: Bool = false

    @State private var selfIsNew: Bool = false //New file has been created
    @State private var editAmountStarted: Bool = false //edit of lease amount started
    @State private var editRateStarted: Bool = false // edit of interest rate started
    
    var body: some View {
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation {
                        self.showMenu = .closed
                    }
                }
            }
        return NavigationView {
            GeometryReader { geometry in
                VStack {
                    ZStack(alignment: .leading) {
                        HomeView(myLease: myLease, endingBalance: $endingBalance, showMenu: $showMenu, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, selfIsNew: $selfIsNew, editAmountStarted: $editAmountStarted, editRateStarted: $editRateStarted, isPad: $isPad, isDark: $isDark, fileWasSaved: $fileWasSaved)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .offset(x: self.showMenu == .open ? geometry.size.width/1.8 : 0, y: 0)
                            .disabled(self.showMenu == .open ? true : false)

                        if self.showMenu == .open {
                            SlideMenuView(myLease: myLease, endingBalance: $endingBalance, showMenu: $showMenu, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, noOfSavedFiles: $noOfSavedFiles, counterSavedFiles: $fileWasSaved, selfIsNew: $selfIsNew, isPad: $isPad, isDark: $isDark, level: $level)
                                .frame(width: geometry.size.width/1.8, height: geometry.size.height)
                                .transition(.move(edge: .leading))
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if self.showMenu == .open {
                        menuButtonClose
                    } else if self.showMenu == .closed {
                        menuButtonOpen
                    } else {
                        menuButtonRemoved
                    }
                    
                }
            }
            
        }
        .gesture(drag)
        .environment(\.colorScheme, isDark ? .dark : .light)
        .task {
//            if await PurchaseManager.shared.hasPurchased() == true {
//                level = .premium
//            }
        }
        .onAppear{
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.isPad = true
            }
        }

    }
    
    func isLeaseInBalance() -> Bool {
        if abs(self.myLease.getEndingBalance()) > toleranceZero || self.myLease.groups.hasNegativePayments() == true {
            return false
        } else {
            return true
        }
    }
    
    var menuButtonOpen:some View {
        Button {
            withAnimation {
                self.showMenu = .open
            }
        } label: {
            Image(systemName: "line.horizontal.3")
                .foregroundColor(Color.red)
        }.disabled(isLeaseInBalance() ? false : true )
        
    }
    
    var menuButtonClose:some View {
        Button {
            withAnimation {
                self.showMenu = .closed
            }
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.red)
        }.disabled(isLeaseInBalance() ? false : true )
    }
    
    var menuButtonRemoved: some View {
        Button {
            self.showMenu = .neither
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.clear)
        }.disabled(true)
    }
       
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}

