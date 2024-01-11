//
//  FileSaveAsView.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/5/23.
//

import SwiftUI

struct FileSaveAsView: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var noOfSavedFiles: Int
    @Binding var fileWasSaved: Bool
    @Binding var showMenu: ShowMenu
    @Binding var isDark: Bool
    var templateMode: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var alertTitle: String = ""
    @State private var editNameStarted: Bool = false
    @State private var editRenameStarted: Bool = false
    @State private var fileNameOnEntry: String = ""
    @State private var fm = LocalFileManager()
    @State private var files: [String] = [String]()
    @State private var helpFileRename: Help = renameHelp
    @State private var helpFileSaveAs: Help = saveAsHelp
    @State private var newFileName: String = ""
    @State private var renameIsActive: Bool = false
    @State private var renameToggleInactive: Bool = false
    @State private var showAlert: Bool = false
    @State private var showPopover1: Bool = false
    @State private var showPopover2: Bool = false
    @State var strTitle: String = "Files"
    
    @AppStorage("maxNoFiles") var maximumNoOfFiles: Int = 20
    
    @FocusState private var saveAsNameIsFocused: Bool
    @FocusState private var renameIsFocused: Bool
    private let pasteBoard = UIPasteboard.general
    var defaultInactive: Color = Color.theme.inActive
    var activeButton: Color = Color.theme.accent
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Save As").font(.footnote)) {
                    saveAsFileRow
                    textButtonsForSaveAsRow
                }
                
                Section(header: Text("Rename Option").font(.footnote)){
                    inactiveRowItem
                }.disabled(renameToggleInactive)
                
                Section(header: Text("Rename Details").font(.footnote)) {
                    fromFileNameRowItem
                    toFileNameRowItem
                    textButtonsForRenameRow
                }

            }
            .navigationTitle("\(strTitle)").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    decimalPadButtonItems
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .alert(isPresented: $showAlert, content: getAlert)
        .onAppear{
           viewOnAppear()
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
    var decimalPadButtonItems: some View {
        HStack {
            cancelDecimalPadButton(cancel: {
                updateForCancel()
            }, isDark: $isDark)
            
            Spacer()
            helpDecimalPadItem(isDark: $isDark)
            
            copyDecimalPadButton(copy: {
                copyToClipboard()
            })

            pasteDecimalPadButton(paste: {
                paste()
            })
            
            clearDecimalPadButton(clear: {
                clearAllText()
            }, isDark: isDark)

            Spacer()
            enterDecimalPadButton(enter: {
                updateForSubmit()
            }, isDark: $isDark)
        }
    }
  
    // Save As TextField
    var saveAsFileRow: some View {
        HStack {
            Text("name:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover1.toggle()
                }
            Spacer()
            TextField("file name", text: $currentFile,
                      onEditingChanged: { (editing) in
                if editing == true {
                    editNameStarted = true
                }})
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($saveAsNameIsFocused)
                .disabled(maxNoOfFilesSavedExceeded())
                .keyboardType(.default)
                .disableAutocorrection(true)
        }
        .popover(isPresented: $showPopover1) {
            PopoverView(myHelp: $helpFileSaveAs, isDark: $isDark)
        }
    }
   
//Mark: Save as buttons
    var textButtonsForSaveAsRow: some View {
        HStack{
            Text("Cancel")
                .disabled(saveAsButtonsAreActive() ? false : true)
                .font(.subheadline)
                .foregroundColor(saveAsButtonsAreActive() ? .accentColor : .gray)
                .onTapGesture {
                    if saveAsButtonsAreActive() == true {
                        self.currentFile = self.fileNameOnEntry
                        self.showMenu = .closed
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            Spacer()
            Text("Save")
                .disabled(saveAsButtonsAreActive() ? false : true)
                .font(.subheadline)
                .foregroundColor(saveAsButtonsAreActive() ? .accentColor : .gray)
                .onTapGesture {
                    if saveAsButtonsAreActive() == true {
                        if isLeaseValid() == true {
                            if validFileName(strName: currentFile) == false {
                                self.alertTitle = alertInvalidName
                                self.showAlert.toggle()
                            } else {
                                let strLeaseData: String = writeLeaseAndClasses(aLease: myLease)
                                fm.fileSaveAs(strDataFile: strLeaseData, fileName: currentFile)
                                self.fileWasSaved = true
                                self.showMenu = .closed
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            self.alertTitle = alertInvalidLease
                            self.showAlert.toggle()
                            self.showMenu = .closed
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
    }
    
    //Mark Rename Buttons
    var textButtonsForRenameRow: some View {
        HStack{
            Text("Cancel")
                .disabled(renameButtonsAreActive() ? false : true)
                .font(.subheadline)
                .foregroundColor(renameButtonsAreActive() ? .accentColor : .gray)
                .onTapGesture {
                    self.showMenu = .closed
                    self.presentationMode.wrappedValue.dismiss()
                }
            Spacer()
            Text("Save")
                .disabled(renameButtonsAreActive() ? false : true)
                .font(.subheadline)
                .foregroundColor(renameButtonsAreActive() ? .accentColor : .gray)
                .onTapGesture {
                    if self.newFileName == self.currentFile {
                        self.alertTitle = alertFileNameIsSameAsCurrent
                        self.showAlert.toggle()
                    } else {
                        fm.renameFile(from: self.currentFile, to: self.newFileName)
                        self.currentFile = self.newFileName
                        self.showMenu = .closed
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
    }
    
    var inactiveRowItem: some View {
        Toggle(isOn: $renameIsActive) {
            Text(renameIsActive ? "active:" : "inactive:")
                .font(.subheadline)
                .onChange(of: renameIsActive) { value in

                }
        }
    }
    
    var fromFileNameRowItem: some View {
        HStack {
            Text("from:")
                .font(.subheadline)
            Spacer()
            Text(renameIsActive ? "\(currentFile)" : "current name")
                .font(.subheadline)
               
        }
    }
    
    //Rename TextField ///////////////////
    var toFileNameRowItem: some View {
        HStack {
            Text("to:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover2 = true
                }
            Spacer()
            TextField("", text: $newFileName,
            onEditingChanged: { (editing) in
                if editing == true {
                    editRenameStarted = true
                }
            })
                .font(.subheadline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.default)
                .focused($renameIsFocused)
                .disableAutocorrection(true)
                .disabled(renameIsActive ? false : true)
        }
        .popover(isPresented: $showPopover2) {
            PopoverView(myHelp: $helpFileRename, isDark: $isDark)
        }
    }
   
    private func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    private func fileNameExists(strName: String) -> Bool {
        var fileExists: Bool = false
        if files.contains(strName) {
            fileExists = true
        }
        
        return fileExists
    }
    
    private func fileNameForTemplates() {
        if currentFile.contains("_tmp") == false {
            self.currentFile = self.currentFile + "_tmp"
        }
    }
    
    private func maxNoOfFilesSavedExceeded() -> Bool {
        if noOfSavedFiles > maximumNoOfFiles {
            return true
        }
        return false
    }
    
    private func validFileName(strName: String) -> Bool {
        //is string empty
        if strName.count == 0 {
            return false
        }
        //is its length longer the limit
        if strName.count > maxFileNameLength {
            return false
        }
        if strName.contains("file is new") {
            return false
        }
        
        //contains illegal chars or punctuation chars
        let myIllegalChars = "!@#$%^&()<>?,|[]{}:;/+=*~"
        let charSet = CharacterSet(charactersIn: myIllegalChars)
        if (strName.rangeOfCharacter(from: charSet) != nil) {
            return false
        }
    
        return true
    }
    
    private func isLeaseValid() -> Bool {
        var leaseIsValid: Bool = true
        
        if self.myLease.amount.toDecimal() > maximumLeaseAmount.toDecimal() {
            leaseIsValid = false
        }
        
        if self.myLease.amount.toDecimal() < minimumLeaseAmount.toDecimal() {
            leaseIsValid = false
        }
        
        if self.myLease.interestRate.toDecimal() > maxInterestRate.toDecimal(){
            leaseIsValid = false
        }
        
        if self.myLease.interestRate.toDecimal() == 0.00 {
            leaseIsValid = false
        }
        
        if self.myLease.baseTerm > maxBaseTerm {
            leaseIsValid = false
        }
        
        if templateMode == true {
            if self.myLease.interimGroupExists() {
                leaseIsValid = false
            }
        }
        
        for x in 0..<myLease.groups.items.count{
            if myLease.groups.items[x].amount.toDecimal() < 0.0 {
                leaseIsValid = false
                break
            }
        }
        
        return leaseIsValid
    }
    
    private func saveAsButtonsAreActive() -> Bool {
        if renameIsActive == true {
            return false
        } else {
            if keyboardActive() == true {
                return false
            } else {
                return true
            }
        }
    }

    private func renameButtonsAreActive() -> Bool {
        if renameIsActive == true {
            if keyboardActive() == true {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    
    private func updateForCancel() {
        if self.saveAsNameIsFocused == true {
            self.currentFile = self.fileNameOnEntry
        } else {
            self.newFileName = self.fileNameOnEntry
        }
        self.saveAsNameIsFocused = false
        self.renameIsFocused = false
        self.renameToggleInactive = true
    }
    
    private func clearAllText() {
        if self.saveAsNameIsFocused == true {
            self.currentFile = ""
        } else {
            self.newFileName = ""
        }
    }
    
    private func copyToClipboard() {
        if self.saveAsNameIsFocused {
            pasteBoard.string = self.currentFile
        } else {
            pasteBoard.string = self.newFileName
        }
    }
    
    private func paste() {
        if let string = pasteBoard.string {
            if self.saveAsNameIsFocused {
                self.currentFile = string
            } else {
                self.newFileName = string
            }
        }
    }
    
    private func updateForSubmit() {
        if editNameStarted == true {
            nameFileProcedure()
        }
        if editRenameStarted == true {
            renameFileProcedure()
            
        }
        self.saveAsNameIsFocused = false
        self.renameIsFocused = false
        self.renameToggleInactive = true
    }
        
       
    private func nameFileProcedure() {
        editNameStarted = false
        if validFileName(strName: self.currentFile) == false {
            //alert invalid Filename
            self.alertTitle = alertInvalidName
            self.showAlert.toggle()
            self.currentFile = fileNameOnEntry
        } else {
            if fileNameExists(strName: self.currentFile) == true {
                self.alertTitle = alertFileNameAlreadyExists
                self.showAlert.toggle()
            } else {
                self.currentFile = checkFileNameSuffix(currFile: currentFile)
            }
        }
    }
    
    private func renameFileProcedure() {
        editRenameStarted = false
        if validFileName(strName: self.newFileName) == false {
            self.alertTitle = alertInvalidName
            self.showAlert.toggle()
            self.newFileName = self.currentFile
        } else {
            if fileNameExists(strName: self.newFileName) == true {
                self.alertTitle = alertFileNameAlreadyExists
                self.showAlert.toggle()
            } else {
                self.newFileName = checkFileNameSuffix(currFile: newFileName)
            }
        }
    }
    
    
    private func checkFileNameSuffix(currFile: String) -> String {
        var checkedName: String = currFile
        if self.templateMode {
            if checkedName.contains("_tmp") == false {
                checkedName = checkedName + "_tmp"
            }
        } else {
            if checkedName.contains("_tmp") {
                checkedName = checkedName.replaceFirst(of: "_tmp", with: "")
            }
        }
        
        return checkedName
    }
        
    private func keyboardActive() -> Bool {
        if saveAsNameIsFocused == true || renameIsFocused == true {
            return true
        } else {
            return false
        }
    }
    
    private func viewOnAppear() {
        self.files = fm.listFiles(templateMode: false)
        if noOfSavedFiles > maximumNoOfFiles {
            self.alertTitle = alertMaxFiles
            self.showAlert.toggle()
        }
        if templateMode == true {
            self.strTitle = "Templates"
            self.helpFileSaveAs = saveAsTemplateHelp
            fileNameForTemplates()
        } else {
            self.currentFile = checkFileNameSuffix(currFile: currentFile)
        }
        self.fileNameOnEntry = self.currentFile
        self.newFileName = self.currentFile
    }
    
}

struct FileSaveAs_Previews: PreviewProvider {
    static var previews: some View {
        FileSaveAsView(myLease: Lease(aDate: today(), mode: .leasing), currentFile: .constant("file is new"), noOfSavedFiles: .constant(0), fileWasSaved: .constant(false), showMenu: .constant(.open), isDark: .constant(false), templateMode: false)
            .preferredColorScheme(.light)
    }
}

let alertMaxFiles: String = "The number of saved files is approaching the maximum number. Consider deleting or exporting some older files."
let alertInvalidName: String = "A valid file name must contain only numbers and letters and be less than \(maxFileNameLength) characters long! The file name cannot be \"file is new.\""
let alertInvalidLease: String = "If certain parameters such amount, interest rate, or base term are not within the minimum or maximum allowable amounts, then the lease cannot be saved!!!"
let alertFileNameIsSameAsCurrent: String = "The new file name is same as the current file name."
let alertFileNameDoesNotExist: String = "The filename does not exist in the collection."
let alertFileNameAlreadyExists: String = "The file name already exists in the collection."

extension String {
    func containTemplateSuffix() -> Bool {
        if self.contains("_tmp") {
            return true
        }
        if self.contains("tmp") {
            return true
        }
        
        return false
    }
}
