//
//  TargetingView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 8/12/23.
//

import SwiftUI

struct TargetingView: View {
    @ObservedObject var myLease: Lease
    @Binding var selfIsNew: Bool
    @Binding var isDark: Bool
    @Binding var showMenu: ShowMenu
    
    @State var mySet: TargetType = .amount
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            Form {
                Section("Inputs") {
                    setRowItem
                    toValueRowItem
                    byChangingRowItem
                }
                Section("Submit Form") {
                    textButtonsForCancelAndDoneRow
                }
            }
            .navigationTitle("Targeting")
        }
       
        
    }
    
    var setRowItem: some View {
        HStack{
            Picker(selection: $mySet, label: Text("Set Parameter:").font(.body)) {
                ForEach(TargetType.allCases, id: \.self) { targetType in
                    Text(targetType.toString())
                }
                .onChange(of: mySet, perform: { value in
                    //self.resetForPaymentTypeChange()
                })
                .font(.body)
            }
            
        }
    }
    
    var toValueRowItem: some View {
        HStack{
            Text("To Value:")
            Spacer()
            
        }
    }
    
    var byChangingRowItem: some View {
        HStack{
            Text("By Changing:")
            Spacer()
            
        }
    }
    
    var textButtonsForCancelAndDoneRow: some View {
        HStack {
            Text("Cancel")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                }
            Spacer()
            Text("Done")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    
                    self.selfIsNew = true
                    self.showMenu = .closed
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
        
    }
        
}

struct TargetingView_Previews: PreviewProvider {
    static var previews: some View {
        TargetingView(myLease: Lease(aDate: today(), mode: .leasing),selfIsNew: .constant(false), isDark: .constant(false), showMenu: .constant(.closed))
    }
}
