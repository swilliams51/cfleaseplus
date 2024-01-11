//
//  HomeView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/10/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var showMenu: ShowMenu
    @Binding var currentFile: String
    
    @Binding var fileExported: Bool
    @Binding var exportSuccessful: Bool
    @Binding var fileImported: Bool
    @Binding var importSuccessful: Bool
    
    @Binding var selfIsNew: Bool
    @Binding var editAmountStarted: Bool
    @Binding var editRateStarted: Bool
    @Binding var isPad: Bool
    @Binding var isDark: Bool
    @Binding var fileWasSaved: Bool
    
    @Environment(\.requestReview) var requestReview
    
    @State var myFees: Fees = Fees()
    @State var margin: CGFloat = 20
    @State private var showChangeModeAlert: Bool = false
    @State var showPopover3: Bool = false
    @State var modeHelp: Help = operatingModeHelp
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
    @AppStorage("totalFilesSaved") var runTotalSavedFiles: Int = 0
    
    
    var body: some View {
        NavigationView {
            VStack{
                summaryTabsItem
                Spacer()
                Form{
                    Section (header: Text("Links").font(.footnote), footer: Text("File Name: \(currentFile)")) {
                        leaseMainViewItem
                        feesViewItem
                    }
                }
                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(myNavTitleDisplayMode)
            .toolbar {
                ToolbarItem(placement: .bottomBar){
                    modeChangeButtonItem
                }
            }
        }
        .popover(isPresented: $showPopover3) {
            PopoverView(myHelp: $modeHelp, isDark: $isDark)
        }
    }
    
    var summaryTabsItem: some View {
        TabView {
            if myLease.operatingMode == .leasing {
                LeaseCashflowView(myLease: myLease, isDark: $isDark)
                    .tabItem {
                        Label("Cashflow", systemImage: "dollarsign.arrow.circlepath")
                
                    }
                LeaseStatisticsView(myLease: myLease)
                    .tabItem {
                        Label("Statistics", systemImage: "waveform.path.ecg")
                            .font(.headline)
                    }
                LeaseYieldsView(myLease: myLease, margin: $margin)
                    .tabItem {
                        Label("Yields", systemImage: "percent")
                            .font(.headline)
                    }
            } else {
                
            }
           
              
        }
        .accentColor(Color("AccentColor"))
//        .tabViewStyle(.page)
        .onAppear{
            UITabBar.appearance().backgroundColor = .lightText
            if self.fileWasSaved == true {
                self.runTotalSavedFiles = self.runTotalSavedFiles + 1
                self.fileWasSaved = false
            }
            
            if self.runTotalSavedFiles == 8 {
                requestReview()
                self.runTotalSavedFiles = 0
            }
        }
    }
    
    var leaseMainViewItem: some View {
        HStack {
            NavigationLink("Parameters", destination: LeaseMainView(myLease: myLease, endingBalance: $endingBalance, showMenu: $showMenu, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, selfIsNew: $selfIsNew, editAmountStarted: $editAmountStarted, editRateStarted: $editRateStarted, isPad: $isPad, isDark: $isDark, fileWasSaved: $fileWasSaved, savedDefaultLease: $savedDefaultLease, useSavedAsDefault: $useSavedAsDefault))
        }
    }
    
    var feesViewItem: some View {
        HStack {
            NavigationLink("Fees", destination: FeesView(myFees: $myLease.fees, myLease: myLease, selfIsNew: $selfIsNew, isDark: $isDark, showMenu: $showMenu))
        }
    }
    
    var modeChangeButtonItem: some View {
        HStack {
            Text("\(self.myLease.operatingMode.toString()) Mode")
                .font(.subheadline)
                .foregroundColor(self.myLease.operatingMode == .leasing ? Color.theme.accent : .red)
                .bold()
                //.disabled(showMenu)
                .alert(isPresented: $showChangeModeAlert) {
                    Alert (
                        title: Text("Are you sure you want change the mode?"),
                        message: Text("There is no undo"),
                        primaryButton: .destructive(Text("Change Mode")) {
                           changeMode()
                    },
                           secondaryButton: .cancel()
                    )}
                .onTapGesture {
                    self.showChangeModeAlert.toggle()
                }
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                //.disabled(showMenu)
                .onTapGesture {
                    self.showPopover3 = true
                }
        }
    }
    
    private func changeMode() {
        if self.myLease.operatingMode == .leasing {
            self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: currentFile, mode: .lending)
        } else {
            self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: currentFile, mode: .leasing)
        }
        self.currentFile = "file is new"
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(myLease: Lease(aDate: today(),mode: .leasing), endingBalance: .constant("0.00"), showMenu: .constant(.open), currentFile: .constant("file is new"), fileExported: .constant(false), exportSuccessful: .constant(false), fileImported: .constant(false), importSuccessful: .constant(false), selfIsNew: .constant(false), editAmountStarted: .constant(false), editRateStarted: .constant(false), isPad: .constant(false), isDark: .constant(false), fileWasSaved: .constant(false))
    }
}


