//
//  FileMenuView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct FileMenuView: View {
    @ObservedObject var myLease: Lease
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showMenu: ShowMenu
    @Binding var currentFile: String
    @Binding var fileExported: Bool
    @Binding var exportSuccessful: Bool
    @Binding var fileImported: Bool
    @Binding var importSuccessful: Bool
    @Binding var noOfSavedFiles: Int
    @Binding var counterSavedFiles: Bool
    @Binding var selfIsNew: Bool
    @Binding var isPad: Bool
    @Binding var isDark: Bool
    @Binding var level: Level
    
    var templateMode: Bool = false
    
    @State private var fontSize: CGFloat = 18
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                newFileMenuItem
                saveFileMenuItem
                saveAsFileMenuItem
                openFileMenuItem
                saveAsTemplateMenuItem
                openTemplateMenuItem
            }
            .navigationTitle("File Management").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .alert(isPresented: $showAlert, content: getAlert)
    }
    
    var newFileMenuItem: some View {
        HStack {
           Image(systemName: "doc")
                .imageScale(.medium)
                .foregroundColor(isDark ? .white : .black)
                .padding(.top, 5)
                .padding(.bottom, 5)
           Button(action: {
               self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease, mode: myLease.operatingMode)
               self.myLease.solveForRate3()
               self.myLease.resetLease()
               self.selfIsNew = true
               self.currentFile = "file is new"
               self.showMenu = .closed
               self.presentationMode.wrappedValue.dismiss()
           }) {
               Text("New")
                   .foregroundColor(isDark ? .white : .black)
                   .font(.subheadline)
           }
           .padding(.top, 5)
           .padding(.bottom, 5)
        Spacer()
       }
    }
    
    var saveFileMenuItem: some View {
        HStack {
           Image(systemName: "square.and.arrow.down")
                .imageScale(.medium)
                .foregroundColor(isDark ? .white : .black)
                .padding(.top, 5)
                .padding(.bottom, 5)
            Button(action: {
                if self.currentFile == "file is new" {
                    self.alertTitle = alertFileSave
                    self.showAlert.toggle()
                } else {
                    let fm = LocalFileManager()
                    if fm.fileExists(fileName: currentFile) == true {
                        let strLeaseData: String = writeLeaseAndClasses(aLease: myLease)
                        fm.fileSaveAs(strDataFile: strLeaseData, fileName: currentFile)
                    } else {
                        self.alertTitle = alertFileSave
                        self.showAlert.toggle()
                    }
                    self.showMenu = .closed
                    self.presentationMode.wrappedValue.dismiss()
                }
              
           }) {
               Text("Save")
                   .foregroundColor(isDark ? .white : .black)
                   .font(.subheadline)
           }
           .padding(.top, 5)
           .padding(.bottom, 5)
            
        Spacer()
       }
    }
    
    var saveAsFileMenuItem: some View {
        HStack {
            NavigationLink(destination: FileSaveAsView(myLease: myLease, currentFile: $currentFile, noOfSavedFiles: $noOfSavedFiles, fileWasSaved: $counterSavedFiles, showMenu: $showMenu, isDark: $isDark, templateMode: false)) {
                Text("\(Image(systemName: "square.and.arrow.down.on.square"))  Save As")
                    .font(.subheadline)
            }
        }
    }
    
    
    var openFileMenuItem: some View {
        HStack {
            NavigationLink(destination: FileOpenView(myLease: myLease, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, selfIsNew: $selfIsNew, noOfSavedFiles: $noOfSavedFiles, showMenu: $showMenu, isDark: $isDark, templateMode: false) ) {
                Text("\(Image(systemName: "envelope.open"))  Open")
                    .font(.subheadline)
            }
        }
    }
    
    var saveAsTemplateMenuItem: some View {
        HStack {
            NavigationLink(destination: FileSaveAsView(myLease: myLease, currentFile: $currentFile, noOfSavedFiles: $noOfSavedFiles, fileWasSaved: $counterSavedFiles, showMenu: $showMenu, isDark: $isDark, templateMode: true)) {
                Text("\(Image(systemName: "square.and.arrow.down.on.square"))  Save As Template")
                    .font(.subheadline)
            }
        }
    }
    
    var openTemplateMenuItem: some View {
        HStack {
            NavigationLink(destination: FileOpenView(myLease: myLease, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, selfIsNew: $selfIsNew, noOfSavedFiles: $noOfSavedFiles, showMenu: $showMenu, isDark: $isDark, templateMode: true) ) {
                Text("\(Image(systemName: "envelope.open"))  Open Template")
                    .font(.subheadline)
            }
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
}

struct FileMenuView_Previews: PreviewProvider {
    static var previews: some View {
        FileMenuView(myLease: Lease(aDate: today(), mode: .leasing), showMenu: .constant(.closed), currentFile: .constant("file is new"), fileExported: .constant(false), exportSuccessful: .constant(false), fileImported: .constant(false), importSuccessful: .constant(false), noOfSavedFiles: .constant(0), counterSavedFiles: .constant(false), selfIsNew: .constant(false), isPad: .constant(false), isDark: .constant(false), level: .constant(.basic))
    }
}


let alertFileSave: String = "The file name must exist in the collection before the Save option can be used. Templates can only be saved by selecting the Save As Template menu option. Select Save As and enter a valid name first.  Then the Save option can be used!"
