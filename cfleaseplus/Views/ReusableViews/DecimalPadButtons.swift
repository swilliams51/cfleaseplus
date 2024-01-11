//
//  DecimalPadButtons.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct cancelDecimalPadButton: View {
    let cancel: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        Button {
            cancel()
        } label: {
            Label ("Cancel", systemImage: "escape")
        }
        .tint(isDark ? .white : .black)
    }
}

struct helpDecimalPadItem: View {
    @State var showPopover: Bool = false
    @Binding var isDark: Bool
    
    var body: some View {
        Image(systemName: "questionmark.circle")
            .foregroundColor(Color.theme.accent)
            .onTapGesture {
                showPopover.toggle()
            }
            .padding()
            .popover(isPresented: $showPopover) {
                PopoverDecimalPadView(isDark: $isDark)
            }
    }
    
}

struct copyDecimalPadButton: View {
    let copy: () -> Void
    var body: some View {
        Button {
           copy()
        } label: {
            Label("", systemImage: "clipboard")
        }
        .tint(.orange)
    }
}

struct pasteDecimalPadButton: View {
    let paste: () -> Void
    
    var body: some View {
        Button {
            paste()
        } label: {
            Label("", systemImage: "paintbrush")
                .foregroundColor(.purple)
        }.tint(.purple)
    }
}

struct clearDecimalPadButton: View {
    let clear: () -> Void
    var isDark: Bool
    
    var body: some View {
        Button {
            clear()
        } label: {
            Label("", systemImage: "clear")
        }.tint(isDark ? .white : .black)
    }
}

struct enterDecimalPadButton: View {
    let enter: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        Button {
            enter()
        } label: {
            Label("", systemImage: "return")
        }.tint(isDark ? .white : .black)
    }
    
}

