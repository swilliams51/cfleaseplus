//
//  cfleaseplusApp.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import SwiftUI

@main
struct cfleaseplusApp: App {
    
    @State var showLaunchView: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                if showLaunchView == true {
                    if showLaunchView == true {
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition(.move(edge: .leading))
                    }
                }
                
            }
            .zIndex(2.0)
        }
        
    }
}
