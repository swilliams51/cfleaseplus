//
//  ReportsListView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct ReportsView: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    @Binding var level: Level
    
    @State var investorLinkIsActive: Bool = false
    @State var amortizationLinkIsActive: Bool = false
    @State var averageLifeLinkIsActive: Bool = false
    @State var cashFlowLinkIsActive: Bool = false
    @State var dayCountLinkIsActive: Bool = false
    @State var customerLinkIsActive: Bool = false
    @State var pvProofLinkIsActive: Bool = false
    @State var terminationValuesLinkIsActive: Bool = false
    @State var leaseBalanceLinkIsActive: Bool = false
    
    var body: some View {
        NavigationView{
                List {
                    investorSummaryFull
                    amortizationReportsFull
                    averageLifeReportFull
                    cashflowReportFull
                    dayCountReportFull
                    customerSummaryReportFull
                    presentValueRentReportFull
                    terminationValuesReportFull
                    leaseBalanceReportFull
                }
                .navigationTitle("Reports")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
                //.analyticsScreen(name: "\(ReportsView.self)")
            }
        
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
    var investorSummaryBasic: some View {
        NavigationLink(destination: SummaryReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("\(Image(systemName: "lock")) Investor Summary")
                    .font(.subheadline)
        }.disabled(true)
    }
    
    var investorSummaryFull: some View {
        NavigationLink(destination: SummaryReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("Investor Summary")
                    .font(.subheadline)
        }
    }
    
    var amortizationReportsBasic: some View {
        NavigationLink(destination: AmortizationReportsView(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("\(Image(systemName: "lock")) Amortization Reports")
                    .font(.subheadline)
        }.disabled(true)
    }
    
    var amortizationReportsFull: some View {
        NavigationLink(destination: AmortizationReportsView(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("Amortization Reports")
                    .font(.subheadline)
        }
    }
    
    var averageLifeReportBasic: some View {
        NavigationLink(destination: AverageLifeReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("\(Image(systemName: "lock")) Average Life")
                    .font(.subheadline)
            
        }.disabled(averageLifeLinkIsActive ? false : true)
    }
    
    var averageLifeReportFull: some View {
        NavigationLink(destination: AverageLifeReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("Average Life")
                    .font(.subheadline)
        }
    }
    
    var averageLifeReportItem: some View {
        NavigationLink(destination: AverageLifeReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            if averageLifeLinkIsActive == false {
                Text("\(Image(systemName: "lock")) Average Life")
                    .font(.subheadline)
            } else {
                Text("Average Life")
                    .font(.subheadline)
            }
        }.disabled(averageLifeLinkIsActive ? false : true)
    }
    
    
    var cashflowReportBasic: some View {
        NavigationLink(destination: CashflowReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            if cashFlowLinkIsActive == false {
                Text("\(Image(systemName: "lock")) Cashflow")
                    .font(.subheadline)
            }
        }.disabled(true)
    }
    
    var cashflowReportFull: some View {
        NavigationLink(destination: CashflowReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("Cashflow")
                    .font(.subheadline)
        }
    }
    
    var dayCountReportBasic: some View {
        NavigationLink(destination: DayCountReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("\(Image(systemName: "lock")) Day Count")
                    .font(.subheadline)
        }.disabled(true)
    }
    
    var dayCountReportFull: some View {
        NavigationLink(destination: DayCountReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
                Text("Day Count")
                    .font(.subheadline)
        }
    }
    
    var daycountReportItem: some View {
        NavigationLink(destination: DayCountReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            if dayCountLinkIsActive == false {
                Text("\(Image(systemName: "lock")) Day Count")
                    .font(.subheadline)
            } else {
                Text("Day Count")
                    .font(.subheadline)
            }
        }.disabled(dayCountLinkIsActive ? false : true)
    }
    
    var customerSummaryReportBasic: some View {
        NavigationLink(destination: CustomerReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("\(Image(systemName: "lock")) Customer Summary")
                .font(.subheadline)
        }.disabled(true)
    }
    
    var customerSummaryReportFull: some View {
        NavigationLink(destination: CustomerReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Customer Summary")
                .font(.subheadline)
        }
    }
    
    var presentValueRentReportBasic: some View {
        NavigationLink(destination: PVOfRentsProof(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("\(Image(systemName: "lock")) PV Proof of Minimum Rents")
                .font(.subheadline)
        }.disabled(true)
    }
    
    var presentValueRentReportFull: some View {
        NavigationLink(destination: PVOfRentsProof(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("PV Proof of Minimum Rents")
                .font(.subheadline)
        }.disabled(myLease.isTrueLease() ? false : true )
        
    }
    
    var terminationValuesReportBasic: some View {
        NavigationLink(destination: TValuesReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("\(Image(systemName: "lock")) Termination Values")
                .font(.subheadline)
        }.disabled(true)
    }
    
    var terminationValuesReportFull: some View {
        NavigationLink(destination: TValuesReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Termination Values")
                .font(.subheadline)
        }.disabled(myLease.terminationsExist() ? false : true)
    }
    
    
    var leaseBalanceReportBasic: some View {
        NavigationLink(destination: LeaseBalanceReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("\(Image(systemName: "lock")) Outstanding Balance Report")
                .font(.subheadline)
        }.disabled(true)
        
    }
    
    var leaseBalanceReportFull: some View {
        NavigationLink(destination: LeaseBalanceReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Outstanding Balance Report")
                .font(.subheadline)
        }.disabled(modificationDate != "01/01/1900" ? false : true )
    }

    
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false), level: .constant(.basic))
            .preferredColorScheme(.light)
    }
}

struct ReportMenuItemView: View {

    let fontSize: CGFloat
    let textMenu: String
    let menuImage: String
    
    var body: some View {
            HStack {
                Image(systemName: menuImage)
                    .imageScale(.medium)
                    .foregroundColor(.white)
                Text (textMenu)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
        }
}

