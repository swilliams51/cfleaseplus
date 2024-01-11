//
//  CancelAndDoneButtons.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/27/23.
//

import SwiftUI

struct CancelAndDoneButtons: View {
    @State var isDark: Bool = false
    
    var body: some View {
        Form{
            CancelButton(cancel: {
                
            }, done: {
                
            }, isDark: $isDark)
        }
        
    }
}

struct CancelAndDoneButtons_Previews: PreviewProvider {
    static var previews: some View {
        CancelAndDoneButtons()
    }
}


struct CancelButton: View {
    let cancel: () -> Void
    let done: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        HStack {
            Button {
                cancel()
            } label: {
                Label ("Cancel", systemImage: "escape")
            }
            .tint(isDark ? .yellow : .orange)
            .padding([.leading, .trailing], 20)
            .padding ([.bottom, .top], 10)
            .background(.blue)
            .cornerRadius(15)
            
            Spacer()
            
            Button {
                done()
            } label: {
                Label ("Done", systemImage: "return")
            }
            .tint(isDark ? .yellow : .white)
            .tint(isDark ? .yellow : .orange)
            .padding([.leading, .trailing], 20)
            .padding ([.bottom, .top], 10)
            .background(.blue)
            .cornerRadius(15)
        }
        
    }
    
}
    

