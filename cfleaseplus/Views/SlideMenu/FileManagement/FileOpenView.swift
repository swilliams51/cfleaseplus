//
//  FileOpenView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct FileOpenView: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var fileExported: Bool
    @Binding var exportSuccessful: Bool
    @Binding var fileImported: Bool
    @Binding var importSuccessful: Bool
    @Binding var selfIsNew: Bool
    @Binding var noOfSavedFiles: Int
    @Binding var showMenu: ShowMenu
    @Binding var isDark: Bool
    var templateMode: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var alertTitle: String = ""
    @State private var exportIsOn: Bool = true
    @State private var exportHelp = exportFileHelp
    @State private var files: [String] = [String]()
    @State private var fm = LocalFileManager()
    @State private var folderIsEmpty: Bool = false
    @State private var importHelp = importFileHelp
    @State private var importExport = importExportHelp
    @State private var leaseDoc: LeaseDocument = LeaseDocument(myData: "")
    @State private var selectedFileIndex: Int = 0
    @State private var selectedFile: String = ""
    @State private var showAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showingExporter: Bool = false
    @State private var showingImporter = false
    @State private var showPopover1: Bool = false
    @State private var showPopover2: Bool = false //import help
    @State private var showPopover3: Bool = false //export help
    @State private var strTitle: String = "Files"
    @State private var textFileLabel: String = ""
    
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
   
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Open/Delete")) {
                    numberOfSavedFilesRow
                    pickerOfSavedFiles
                    deleteAndOpenTextButtonsRow
                }
                Section(header: Text("Export/Import")) {
                    exportIsActiveToggleRow
                    exportActionRow
                    importActionRow
                }
            }
            .navigationTitle("\(strTitle)").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        
        .fileExporter(
              isPresented: $showingExporter,
              document: leaseDoc,
              contentType: .plainText,
              defaultFilename: self.currentFile
          ) { result in
              self.fileExported = true
              if case .success = result {
                  // Handle success.
                  self.exportSuccessful = true
              } else {
                  // Handle failure.
                  self.exportSuccessful = false
              }
              self.presentationMode.wrappedValue.dismiss()
          }
        
          .fileImporter(
              isPresented: $showingImporter,
              allowedContentTypes: [.plainText],
              allowsMultipleSelection: false
          ) { result in
              self.fileImported = true
              if case .success = result {
                  do {
                      guard let selectedFile: URL = try result.get().first else { return }
                      if selectedFile.startAccessingSecurityScopedResource(){
                          guard let data = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                          defer { selectedFile.stopAccessingSecurityScopedResource() }
                          let fileName: String = selectedFile.deletingPathExtension().lastPathComponent
                          self.leaseDoc.leaseData = data
                          if self.leaseDoc.isValidFile() == true {
                              self.importSuccessful = true
                              self.myLease.readLeaseFromString(strFile: self.leaseDoc.leaseData)
                              self.currentFile = fileName
                              self.selfIsNew = true
                              self.showMenu = .closed
                              modificationDate = "01/01/1900"
                          } else {
                              self.importSuccessful = false
                          }
                      }
                  } catch {
                      let nsError = error as NSError
                      fatalError("File Import Error \(nsError), \(nsError.userInfo)")
                  }
              } else {
                  self.importSuccessful = false
              }
              self.presentationMode.wrappedValue.dismiss()
          }
        
        .onAppear{
            self.files = fm.listFiles(templateMode: templateMode)
            self.noOfSavedFiles = self.files.count
            if self.noOfSavedFiles == 0 {
                self.folderIsEmpty = true
            } else {
                self.selectedFile = self.files[0]
            }
            if templateMode == true {
                self.strTitle = "Templates"
            }
        }
    }
    
    var numberOfSavedFilesRow: some View {
        HStack {
            Text("number saved:")
                .font(.subheadline)
            Spacer()
            Text("\(self.noOfSavedFiles)")
                .font(.subheadline)
        }
    }
    
    var pickerOfSavedFiles: some View {
        Picker(selection: $selectedFileIndex, label:
                Text(textFileLabel)) {
            ForEach(0..<files.count, id: \.self) { i in
                Text(self.files[i])
                    .font(.subheadline)
            }
        }
        .font(.subheadline)
        .disabled(folderIsEmpty)
        .onChange(of: selectedFileIndex) { _ in
            self.selectedFile = String(self.files[selectedFileIndex])
        }
    }
    
    
    var deleteAndOpenTextButtonsRow: some View {
        HStack {
            Text("Delete")
            .alert(isPresented: $showDeleteAlert) {
                Alert (
                    title: Text("Are you sure you want to delete this file?"),
                    message: Text("There is no undo"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteFile()
                },
                       secondaryButton: .cancel()
                )}
            .disabled(folderIsEmpty)
            .font(.subheadline)
            .foregroundColor(folderIsEmpty ? .gray : .accentColor)
            .onTapGesture {
                if self.folderIsEmpty == false{
                    self.showDeleteAlert.toggle()
                }

            }
            Spacer()
            Text("Open")
                .disabled(folderIsEmpty)
                .font(.subheadline)
                .foregroundColor(folderIsEmpty ? .gray : .accentColor)
                .onTapGesture {
                    if folderIsEmpty == false {
                        openFile()
                    }
                }
        }
    }
    
    var exportIsActiveToggleRow: some View {
        HStack {
            Text(exportIsOn ? "export action:" : "import action:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover1 = true
                }
            Toggle("", isOn: $exportIsOn)
                .disabled(folderIsEmpty)
        }
        .popover(isPresented: $showPopover1) {
            PopoverView(myHelp: $importExport, isDark: $isDark)
        }
    }
    
    //Export Files
    var exportActionRow: some View {
        HStack {
            Text("above selected file:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover2 = true
                }
            Spacer()
            Button(action: {}) {
                Text("Export")
                    .font(.subheadline)
                    .foregroundColor(exportIsOn ? Color.theme.accent : Color.theme.inActive)
                    
            }.disabled(folderIsEmpty)
            .onTapGesture {
                if folderIsEmpty == false {
                    if self.exportIsOn == true {
                        self.leaseDoc.leaseData = fm.fileOpen(fileName: selectedFile)
                        self.currentFile = self.selectedFile
                        self.showingExporter = true
                    }
                }
            }
        }
        .popover(isPresented: $showPopover2) {
            PopoverView(myHelp: $exportHelp, isDark: $isDark)
        }
    }
    
    //Import Files
    var importActionRow: some View {
        HStack {
            Text("selected file:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover3 = true
                }
            Spacer()
            Button(action: {}) {
                Text("Import")
                    .font(.subheadline)
                    .foregroundColor(exportIsOn ? Color.theme.inActive : Color.theme.accent)
            }
            .disabled(folderIsEmpty)
            .onTapGesture {
                if folderIsEmpty == false {
                    if self.exportIsOn == false {
                        self.showingImporter = true
                    }
                }
            }
        }
        .popover(isPresented: $showPopover3) {
            PopoverView(myHelp: $importHelp, isDark: $isDark)
        }
    }
    
    func fileNameExists(strName: String) -> Bool {
        var fileExists: Bool = false
        if files.contains(strName) {
            fileExists = true
        }
        
        return fileExists
    }
    
    func deleteFile() {
        fm.deleteFile(fileName: self.selectedFile)
        self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease, mode: myLease.operatingMode)
        self.myLease.solveForRate3()
        self.myLease.resetLease()
        self.selfIsNew = true
        self.currentFile = "file is new"
        self.showMenu = .closed
        self.presentationMode.wrappedValue.dismiss()
    }

    
    func openFile() {
        self.selectedFile = files[selectedFileIndex]
        let strFileText: String = fm.fileOpen(fileName: selectedFile)
        if self.selectedFile.contains("_tmp") {
            self.myLease.openAsTemplate(strFile: strFileText)
        } else {
            self.myLease.readLeaseFromString(strFile: strFileText)
        }
        self.currentFile = self.selectedFile
        self.selfIsNew = true
        self.showMenu = .closed
        modificationDate = "01/01/1900"
    }
    
}
    

struct FileOpenView_Previews: PreviewProvider {
    static var previews: some View {
        FileOpenView(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), fileExported: .constant(false), exportSuccessful: .constant(false), fileImported: .constant(false), importSuccessful: .constant(false), selfIsNew: .constant(true), noOfSavedFiles: .constant(0), showMenu: .constant(.open), isDark: .constant(false), templateMode: false)
            .preferredColorScheme(.light)
    }
}

let alertNoFileExists: String = "No CFLease files exist. The file folder is empty!!!"
