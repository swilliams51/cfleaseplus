//
//  Color.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//
import SwiftUI
import Foundation

extension Color {
    static let theme = ColorTheme()
    static let launch = LaunchTheme()
    
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let inActive = Color("AccentInactive")
    let calculated = Color("AccentCalculated")
    let active = Color("AccentActive")
    let popOver = Color("PopoverBackground")
}

struct LaunchTheme {
    let accent = Color("LaunchAccentColor")
    let background = Color("LaunchBackgroundColor")
}
