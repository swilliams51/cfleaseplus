//
//  LaunchView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct LaunchView: View {
    private let phrase: String = "Lease pricing for the next generation!!"
    private let timer = Timer.publish(every: 0.075, on: .main, in: .common).autoconnect()
    @State private var counter: Int = 0
    @State private var banner: String = ""
    @State private var hasTimeElasped: Bool = false
    @Binding var showLaunchView: Bool
    
    
    var body: some View {
        ZStack {
            Color.launch.background
                .ignoresSafeArea()
            HStack {
                Text("CFLease+")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .offset(y: -80)
            
            Image("cfleaseLogo")
                .resizable()
                .frame(width: 100, height: 100)
            
            HStack {
                Text(banner)
                    .font(.headline)
                    .foregroundColor(.white)
                    .onReceive(timer) { _ in
                        if counter <= phrase.count + 1 {
                            banner = String(phrase.prefix(counter))
                        } else if counter == phrase.count + 10 {
                            timer.upstream.connect().cancel()
                            self.showLaunchView = false
                        } else {
                            
                        }
                        counter += 1
                    }
            }
            .offset(y: 80)
        }
        .transition(AnyTransition.scale.animation(.easeIn))
    }
    
   
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(showLaunchView: .constant(true))
    }
}

