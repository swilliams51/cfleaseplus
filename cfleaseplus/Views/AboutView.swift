//
//  AboutView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI
import MessageUI

struct AboutView: View {
    @Binding var isDark: Bool
    @Binding var showMenu: ShowMenu
    @ScaledMetric var scale: CGFloat = 1
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false

    @State private var mailData: ComposeMailData = ComposeMailData(subject: "Suggestions", recipients: ["info@cfsoftwaresolutions.com"], message: "My suggestions are below:", attachments: [AttachmentData]())
    
    var body: some View {
            NavigationView{
                Form{
                    logoItem
                    thankYouItem
                    companyDetailsItem
                    sendSuggestionsItem
                }
                .navigationTitle("CFLease+")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
            }
            .environment(\.colorScheme, isDark ? .dark : .light)
            .sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: self.$isShowingMailView, result: self.$result, data: $mailData)
            }
            .onAppear{
                showMenu = .neither
            }
            .onDisappear{
                showMenu = .closed
            }
    }
    
    var thankYouItem: some View {
        HStack{
            Spacer()
            Text("Thank you for downloading CFLease+!")
                .font(.subheadline)
            Spacer()
    
        }
    }
    
    var logoItem: some View {
            VStack{
                HStack {
                    Spacer()
                    Image("cfleaseLogo")
                        .resizable()
                        .frame(width: scale * 100, height: scale * 100 , alignment: .center)
                        .padding()
                    Spacer()
                }
                HStack{
                    Text(getVersion())
                        .font(.footnote)
                }
            }
    }
    
    var companyDetailsItem: some View {
        VStack{
            HStack {
                Spacer()
                Text("CF Software Solutions, LLC")
                    .font(.subheadline)
                .padding()
                Spacer()
            }
            Link("Home Page", destination: URL(string: "https:/www.cfsoftwaresolutions.com")!)
                .font(.subheadline)
        }
    }
    
    var sendSuggestionsItem: some View {
        VStack {
            Text("Questions or comments")
                .font(.subheadline)
                .padding()
            if MFMailComposeViewController.canSendMail() {
                HStack {
                    Spacer()
                    Button {
                        self.isShowingMailView.toggle()
                    } label: {
                        Text("Send email")
                            .font(.subheadline)
                    }
                    Spacer()
                }
            } else {
                HStack {
                    Spacer()
                    Text("Can't send emails from this device")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
    }
    
    private func getVersion() -> String {
        var myVersion: String = "V."
        let myDictionary = Bundle.main.infoDictionary
        let version = myDictionary?["CFBundleShortVersionString"] as? String
        myVersion = myVersion + version!
        
        return myVersion
    }
}



struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(isDark: .constant(false), showMenu: .constant(.neither))
    }
}
