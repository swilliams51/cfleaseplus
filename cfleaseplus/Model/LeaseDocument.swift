//
//  LeaseDocument.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

//import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct LeaseDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var leaseData: String
    
    init(myData: String) {
        self.leaseData = myData
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        leaseData = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: leaseData.data(using: .utf8)!)
    }
    
    func hasIllegalChars() -> Bool {
        let myIllegalChars = "!@$%^&|"
        let charSet = CharacterSet(charactersIn: myIllegalChars)
        if (leaseData.rangeOfCharacter(from: charSet) != nil) {
            return true
        } else {
            return false
        }
    }
    
    func charCount(myChar: Character) -> Int {
        let charCount: Int = leaseData.filter {$0 == myChar}.count
        
        return charCount
    }
    
    func isValidFile() -> Bool {
        if leaseData.contains("#") == false {
            return false
        }
         
        if leaseData.contains("<") == false {
            return false
        }
        
        if leaseData.contains("*") == false {
            return false
        }
        
        if hasIllegalChars() == true {
            return false
        }
        
        if leaseData.contains("True") == false && leaseData.contains("False") == false {
            return false
        }
        
        if charCount(myChar: "/") < 9 {
            return false
        }
        
        if charCount(myChar: ",") < 15 {
            return false
        }
            
          return true
    }
}
