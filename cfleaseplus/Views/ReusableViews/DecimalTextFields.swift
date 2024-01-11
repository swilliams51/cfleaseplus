//
//  DecimalTextFields.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct MyTextFieldModifier: ViewModifier {
    @FocusState var amountIsFocused: Bool
    let myColor: Color = .clear
    let myKey: UIKeyboardType = .decimalPad
    var isDisabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .disabled(isDisabled)
            .keyboardType(myKey).foregroundColor(myColor)
            .focused($amountIsFocused)
            .textFieldStyle(PlainTextFieldStyle())
            .disableAutocorrection(true)
            .accentColor(myColor)
    }
}

