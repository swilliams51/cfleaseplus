//
//  CalculationsView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct CalculationsView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Binding var showMenu: ShowMenu
    
    var body: some View {
        NavigationView {
            List {
                presentValueOfRentsLink
                earlyBuyoutLink
                terminationsLink
                leaseBalanceLink
            }
            .navigationTitle("Calculations").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
    var presentValueOfRentsLink: some View {
        NavigationLink(destination: PVRentsView(myLease: myLease, isDark: $isDark).navigationBarBackButtonHidden(true)) {
            Text("\(Image(systemName: "sum"))  Present Value of Rents")
                .font(.subheadline)
        }.disabled(myLease.isTrueLease() ? false : true )
    }
    
    var earlyBuyoutLink: some View {
        NavigationLink(destination: EarlyBuyoutView(myLease: myLease, isDark: $isDark).navigationBarBackButtonHidden(true)) {
            Text("\(Image(systemName: "option"))  Early Buyout Option")
                .font(.subheadline)
        }.disabled(myLease.isTrueLease() ? false : true)
    }
    
    var terminationsLink: some View {
        NavigationLink(destination: TValuesView(myLease: myLease, isDark: $isDark).navigationBarBackButtonHidden(true)) {
            Text("\(Image(systemName: "tablecells"))  Termination Values")
                .font(.subheadline)
        }
    }
    
    var leaseBalanceLink: some View {
        NavigationLink(destination: LeaseBalanceView(myLease: myLease, isDark: $isDark).navigationBarBackButtonHidden(true)) {
            Text("\(Image(systemName: "hourglass"))  Outstanding Balance")
                .font(.subheadline)
        }
    }
}

struct CalculationsView_Previews: PreviewProvider {
    static var previews: some View {
        CalculationsView(myLease: Lease(aDate: today(), mode: .leasing), isDark: .constant(false), showMenu: .constant(.closed))
            .preferredColorScheme(.light)
    }
}

