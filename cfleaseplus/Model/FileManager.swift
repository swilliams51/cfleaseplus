//
//  FileManager.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation
import SwiftUI


class LocalFileManager {
    
    static let instance = LocalFileManager()
    let appFolder: String = "My_Leases_Data"
    
    init() {
        createLeaseDataFolder()
    }
    
    func createLeaseDataFolder() {
        let path = getDocumentDirectory()
        let folderPath = path.appendingPathComponent(appFolder)
        
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            do {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    
    func saveCSVFile(strDataFile: String, fileName: String) {
        let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        
        do {
            try strDataFile.write(to: driveURL!, atomically: true, encoding: .utf8)
        } catch let error {
            print("\(error.localizedDescription)")
        }
        
    }
    
    
    func fileSaveAs(strDataFile: String, fileName: String) {
        let fileURL = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
        
        do {
            try strDataFile.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }

    func getDocumentDirectory() -> URL {
        let path = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? nil)!
        return path
    }
    
    func getCacheDirectory() -> URL {
        let path = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? nil)!
        return path
    }
    
    func getTempDirectory() -> URL {
        let path = FileManager.default.temporaryDirectory
        return path
    }
    
    func fileOpen(fileName: String) -> String {
        var classRoomText: String = ""
        let fileURL = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
       
        do {
            classRoomText = try String(contentsOf: fileURL, encoding: .utf8)
        } catch let error {
            print ("\(error.localizedDescription)")
        }

        return classRoomText
    }
    
    func getFileURL(fileName: String) -> URL {
        return getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
    }
    
    func deleteFile(fileName: String) {
        let fileURL = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
        let fm = FileManager.default
        
        do {
            try fm.removeItem(at: fileURL)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    func fileExists(fileName: String) -> Bool {
        let myList:[String] = listFiles(templateMode: false)
        
        for x in 0..<myList.count {
            if myList[x] == fileName {
                return true
            }
        }
         return false
    }
    
    func renameFile(from: String, to: String) {
        let fm = FileManager.default
        
        let oldFilePath = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(from)
        //print("\(oldFilePath.relativeString)")
        let newFilePath = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(to)
        //print("\(newFilePath.relativeString)")
        
        do {
            try fm.moveItem(at: oldFilePath, to: newFilePath)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    func listFiles(templateMode: Bool) -> [String] {
        let fm = FileManager.default
        var items: [String] = []
        
        do {
            items = try fm.contentsOfDirectory(atPath: getDocumentDirectory().appendingPathComponent(appFolder).path)
            items = getList(aList: items, templateMode: templateMode)
        } catch let error {
            print("\(error.localizedDescription)")
        }
        
        return items.sorted()
    }
    
    func getList(aList: [String], templateMode: Bool) -> [String] {
        let end = aList.count
        var myList:[String] = aList
        for x in (0..<end).reversed(){
            if myList[x].contains("_tmp") != templateMode {
                myList.remove(at: x)
            }
        }
      return myList
    }
    
}
