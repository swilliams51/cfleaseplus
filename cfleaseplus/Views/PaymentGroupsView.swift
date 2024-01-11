//
//  PaymentGroupsView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI
import UIKit

struct GroupsView: View {
    @Binding var myGroups: Groups
    @ObservedObject var myLease: Lease
    @Binding var selfIsNew: Bool
    @Binding var isDark: Bool
    @Binding var showMenu: ShowMenu
    @Binding var paymentsViewed: Bool
    
    //@Environment(\.presentationMode) var presentationMode
    
    @State private var netAmount: Decimal = 0.0
    @State private var selectedGroup:Group? = nil
    @State private var isPresented: Bool = false
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var showActionSheet1: Bool = false
    @State private var showActionSheet2: Bool = false
    @State private var showActionSheet3: Bool = false
    @State private var showActionSheet4: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payment Groups")) {
                   fundingGroupRow
                    ForEach(myGroups.items) { group in
                        VStack {
                            HStack {
                                groupTextRowOne(group: group)
                            }
                            HStack {
                                groupTextRowTwo(group: group)
                            }
                        }
                    }
                }
                Section(header: Text("Totals")) {
                    totalsHeader
                    totalAmounts
                }
            }

        .toolbar {
            structureContent()
            newGroupContent()
        }
        .navigationTitle("Payment Schedule")
        .navigationBarTitleDisplayMode(.large)
        .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        
        .fullScreenCover(item: $selectedGroup) { myGroup in
            OneGroupView(myGroup: myGroup, myGroups: myGroups, myLease: myLease, isDark: $isDark)
        }
        .onAppear{
            netAmount = myLease.getNetAmount()
            paymentsViewed = true
        }

       
        .sheet(isPresented: $showActionSheet1, content:  { TermAmortizationView(myLease: myLease, isDark: $isDark) })
        .sheet(isPresented: $showActionSheet2, content:  { EscalatorView(myLease: myLease, isDark: $isDark) })
        .sheet(isPresented: $showActionSheet3, content:  { SkipPaymentsView(myLease: myLease, isDark: $isDark) })
        .sheet(isPresented: $showActionSheet4, content:  { GraduatedPaymentsView(myLease: myLease, isDark: $isDark) })
        .alert(isPresented: $showAlert, content: getAlert)
    }
    
    
    
    var fundingGroupRow: some View {
        VStack {
            HStack {
                Text(fundingAmountToText())
                    .font(.subheadline)
                Spacer()
            }
            
            HStack {
                Text(fundingDateToText())
                    .font(.subheadline)
                Spacer()
            }
        }
    }
    
    @ViewBuilder func groupTextRowOne(group: Group) -> some View {
        Text(groupToFirstText(aGroup: group))
            .font(.subheadline)
        Spacer()
        Button(action: {
            self.selectedGroup = group
        }) {
           Text("Edit")
            .font(.subheadline)
        } .disabled(selfIsNew ? true : false )
    }
    
    @ViewBuilder func groupTextRowTwo(group: Group) -> some View {
        Text(groupToSecondText(aGroup: group))
            .font(.subheadline)
        Spacer()
        Text("place")
            .foregroundColor(.clear)
    }
    
    @ToolbarContentBuilder
    func newGroupContent() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Menu {
                Section {
                    if self.myLease.operatingMode == .leasing {
                        addDuplicateGroup
                        addBalloonGroup
                        addResidualGroup
                    } else {
                        addDuplicateGroup
                        addBalloonGroup
                    }
                }
            }
        label: {
            Label("new group", systemImage: "plus")
        }
            .font(.subheadline)
            .labelStyle(.titleOnly)
            .disabled(selfIsNew ? true : false )
        }
    }
    
    
    @ToolbarContentBuilder
    func structureContent() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Menu {
                Section {
                    if self.myLease.operatingMode == .leasing {
                        firstAndLast
                        firstAndLastTwo
                        lowHigh
                        highLow
                        escalation
                        skipPaymentsItem
                    } else {
                        termAmortization
                        skipPaymentsItem
                        graduatedPaymentsItem
                    }
                }
            }
        label: {
            Label("structure", systemImage: "gearshape")
                .labelStyle(.titleOnly)
        }
            .font(.subheadline)
            .disabled(selfIsNew ? true : false )
        }
    }
    
    private func fundingAmountToText() -> String {
        let strAmount = "1 @ -\(myLease.amount.toDecimal().toCurrency(false))"
        let strFunding = strAmount + " Funding "
        return strFunding
    }
    
    private func fundingDateToText() -> String {
        let strFundingDate: String = "\(myLease.fundingDate.toStringDateShort(yrDigits: 2))"
        let strFundingDateRow: String = strFundingDate + " to " + strFundingDate
        let strFundingType: String = " Equals Unlocked"
        return strFundingDateRow + strFundingType
    }

    private var totalsHeader: some View {
        HStack {
            Text("Number:")
                .font(.subheadline)
            Spacer()
            Text("Net Amount:")
                .font(.subheadline)
        }
    }
    
    private var totalAmounts: some View {
        HStack {
            Text("\(myGroups.getTotalNoOfPayments() + 1)")
                .font(.subheadline)
            Spacer()
            Text("\(netAmount.toCurrency(false))")
                .font(.subheadline)
        }
    }
    
    private var firstAndLast: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false || balanceIsZero() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.myLease.groups.firstAndLast(freq: myLease.paymentsPerYear, baseCommence: myLease.baseTermCommenceDate, EOMRule: myLease.endOfMonthRule)
                solveForRate()
            }
        }) {
            Label("1stAndLast", systemImage: "arrowshape.turn.up.backward")
                .font(.caption2)
        }
    }
    
    private var firstAndLastTwo: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false || balanceIsZero() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.myLease.groups.firstAndLastTwo(freq: myLease.paymentsPerYear, baseCommence: myLease.baseTermCommenceDate, EOMRule: myLease.endOfMonthRule)
               solveForRate()
            }
        }) {
            Label("1stAndLastTwo", systemImage: "arrowshape.turn.up.backward.2")
                .font(.caption2)
        }
    }
    
    private var lowHigh: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false || balanceIsZero() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.myLease.groups.unevenPayments(lowHigh: true, freq: myLease.paymentsPerYear, baseCommence: myLease.baseTermCommenceDate, EOMRule: myLease.endOfMonthRule)
                self.netAmount = myLease.getNetAmount()
                self.myLease.solveForUnlockedPayments3()
            }
        }) {
            Label("Low-High", systemImage: "arrow.up.right")
                .font(.caption2)
        }
    }
    
    private var highLow: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false || balanceIsZero() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.myLease.groups.unevenPayments(lowHigh: false, freq: myLease.paymentsPerYear, baseCommence: myLease.baseTermCommenceDate, EOMRule: myLease.endOfMonthRule)
                self.netAmount = myLease.getNetAmount()
                self.myLease.solveForUnlockedPayments3()
            }
        }) {
            Label("High-Low", systemImage: "arrow.down.right")
                .font(.caption2)
        }
    }
    
    private var termAmortization: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false || balanceIsZero() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.showActionSheet1 = true
            }
               
        }) {
            Label("Term-Amortization", systemImage: "arrow.forward.to.line")
                .font(.caption2)
        }
    }
    
    private var escalation: some View {
        Button(action: {
            if escalationCanBeApplied() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.showActionSheet2 = true
            }
               
        }) {
            Label("Annual Escalator", systemImage: "arrow.up.right")
                .font(.caption2)
        }
    }
    
    private var skipPaymentsItem: some View {
        Button(action: {
            if skipPaymentsCanBeApplied() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.showActionSheet3 = true
            }
               
        }) {
            Label("Skip Payments", systemImage: "slider.vertical.3")
                .font(.caption2)
        }
    }
    
    private var graduatedPaymentsItem: some View {
        Button(action: {
            if graduatedPaymentsCanBeApplied() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.showActionSheet4 = true
            }
               
        }) {
            Label("Graduated Payments", systemImage: "stairs")
                .font(.caption2)
        }
    }
    
    private var addDuplicateGroup: some View {
        Button(action: {
            if myGroups.residualGroupExists() == false {
                let lastIdx: Int = myGroups.items.count - 1
                var numberOfPayments = myGroups.items[lastIdx].noOfPayments
                let maxRemaining: Int = myLease.getMaxRemainNumberPayments(maxBaseTerm: maxBaseTerm, freq: self.myLease.paymentsPerYear, eom: self.myLease.endOfMonthRule, aRefer: self.myLease.firstAnniversaryDate)
                if maxRemaining > 0 {
                    if numberOfPayments > maxRemaining {
                        numberOfPayments = maxRemaining
                    }
                    self.myGroups.addDuplicateGroup(groupToCopy: myGroups.items[lastIdx], numberPayments: numberOfPayments)
                    self.myLease.resetRemainderOfGroups(startGrp: lastIdx + 1)
                } else {
                    alertTitle = alertDuplicate2
                    showAlert.toggle()
                }
            } else {
                alertTitle = alertDuplicate
                showAlert.toggle()
            }
        }) {
            HStack {
                Image(systemName: "doc.on.doc")
                Text("Copy (Last)")
            }
        }
    }
    
    private var addResidualGroup: some View {
        Button(action: {
            if myGroups.residualGroupExists() == false {
                let lastIdx: Int = self.myGroups.items.count - 1
                self.myGroups.addResidualGroup(leaseAmount: myLease.amount)
                self.myLease.resetRemainderOfGroups(startGrp: lastIdx + 1)
            } else {
                alertTitle = alertResidual
                showAlert.toggle()
            }
        }) {
            HStack {
                Image(systemName: "plus.forwardslash.minus")
                Text("Residual")
            }
        }
    }
    
    private var addBalloonGroup: some View {
        Button(action: {
            if myGroups.residualGroupExists() == false {
                let lastIdx: Int = self.myGroups.items.count - 1
                self.myGroups.addBalloonGroup(leaseAmount: myLease.amount)
                self.myLease.resetRemainderOfGroups(startGrp: lastIdx + 1)
            } else {
                alertTitle = alertResidual
                showAlert.toggle()
            }
        }) {
            HStack {
                Image(systemName: "balloon")
                Text("Balloon")
            }
        }
    }
    
}

struct GroupsView_Previews: PreviewProvider {
    static var myLease: Lease = Lease(aDate: today(), mode: .leasing)
    
    static var previews: some View {
        GroupsView(myGroups: .constant(myLease.groups), myLease: Lease(aDate: today(), mode: .leasing), selfIsNew: .constant(false), isDark: .constant(false), showMenu: .constant(.neither),paymentsViewed: .constant(false))
            .preferredColorScheme(.light)
    }
}

extension GroupsView {
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func alertForStructureWarning() -> String {
        let strAlert = altertStructure
        return strAlert
    }
    
    func balanceIsZero() -> Bool {
        var isZero: Bool = false
        
        let balance: Decimal = myLease.getEndingBalance()
        //menuIsActive = false
        if abs(balance) < 0.075 {
            isZero = true
        }
        return isZero
    }
    
    func escalationCanBeApplied () -> Bool {
        if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false {
            return false
        }
        
        if balanceIsZero() == false {
           return false
        }
        
        if myLease.baseTermIsInWholeYears() == false {
            return false
        }
        
        return true
    }
    
    func groupToFirstText(aGroup: Group) -> String {
        var strAmount: String = "Calculated"
        if aGroup.amount != "CALCULATED" {
            strAmount = aGroup.amount.toDecimal().toCurrency(false)
        }
       
        let strOne: String = "\(aGroup.noOfPayments) @ " + strAmount + " \(aGroup.type.toString()) "
        
        return strOne
    }
    
    func graduatedPaymentsCanBeApplied() -> Bool {
        if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false {
            return false
        }
        
        if myLease.groups.items.count > 1 {
            return false
        }
        if myLease.paymentsPerYear != .monthly {
            return false
        }
        if myLease.groups.items[0].type != .payment {
            return false
        }
        if myLease.groups.items[0].noOfPayments < 120 {
            return false
        }
        if myLease.groups.items[0].timing != .arrears {
            return false
        }
        if myLease.getBaseTermInMons() % 12 != 0 {
            return false
        }
        
        return true
    }

    func groupToSecondText (aGroup: Group) -> String {
        var strTiming: String = "Equals"
        if aGroup.timing == .advance {
            strTiming = "Advance"
        } else if aGroup.timing == .arrears {
            strTiming = "Arrears"
        }
        
        var strLocked: String = "Locked"
        if aGroup.locked == false {
            strLocked = "Unlocked"
        }
        
        let strStart: String = "\(aGroup.startDate.toStringDateShort(yrDigits: 2))"
        let strEnd: String = "\(aGroup.endDate.toStringDateShort(yrDigits: 2))"
        let strDate: String = strStart + " to " + strEnd
        
        
        let strTwo: String =   strDate + " " + strTiming + " " + strLocked
        return strTwo
    }
    
    func removeGroup(at offsets: IndexSet) {
        self.myGroups.items.remove(atOffsets: offsets)
        self.myLease.resetRemainderOfGroups(startGrp: 1)
    }
    
    func skipPaymentsCanBeApplied() -> Bool {
        if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false {
            return false
        }
        
        if balanceIsZero() == false {
           return false
        }
        
        if myLease.paymentsPerYear != .monthly {
            return false
        }
        
        if myLease.baseTermIsInWholeYears() == false {
            return false
        }
        return true
    }
    
    func solveForRate() {
        self.myLease.solveForRate3()
        if abs(self.myLease.getEndingBalance()) > toleranceAmounts {
            for x in 0..<self.myLease.groups.items.count {
                if self.myLease.groups.items[x].locked == true && self.myLease.groups.items[x].noOfPayments > 1 {
                    self.myLease.groups.items[x].locked = false
                }
            }
            self.myLease.solveForUnlockedPayments3()
        }
        self.myLease.resetTerminations()
        self.netAmount = myLease.getNetAmount()
    }

}


let altertStructure: String = "A payment structure cannot be applied to a Lease with more than one payment group or when the ending balance is not equal to 0.00.  There maybe additional restrictions depending on the structure.  See Glossary."
let alertResidual: String = "A payment group cannot be added after a residual or balloon payment!!"
let alertDuplicate: String = "Only one residual or balloon payment group can exist in the collection!!"
let alertDuplicate2: String = "Maximum number of payments exceeded.  The group will not be added!!"
