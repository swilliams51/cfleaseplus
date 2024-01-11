//
//  FormatFx.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation
import SwiftUI

let mySixColumns: [Int] = [3, 9, 6, 7, 9, 8]
let myFiveColumns: [Int] = [5, 12, 11, 11, 12]
let myFourColumns: [Int] = [4, 10, 15, 15]
let reportFontLarge: Font = Font.system(.subheadline, design: .monospaced)
let reportFontSmall: Font = Font.system(.caption, design: .monospaced)
let reportFontTiny: Font = Font.system(.caption2, design: .monospaced)
let reportWidthLarge: Int = 46
let reportWidthSmall: Int = 76
// 42
let reportWidthTiny: Int = 38



func justifyColumn(cellData: String, leftJustify: Bool, cellWidth: Int) -> String {
    var adder = 0
    if cellData.count < cellWidth {
        adder = cellWidth - cellData.count
    }
    
    var justified: String = buffer(spaces: adder) + cellData
    if leftJustify == true {
        justified = cellData + buffer(spaces: adder)
    }
    return justified
}


func buffer(spaces: Int) -> String {
    let chr: String = " "
    var strOut: String = ""
    var x: Int = 1
    
    if spaces > 0 {
        while x <= spaces {
            strOut = strOut + chr
            x = x + 1
        }
    }
    return strOut
}

func formatAsTotal(decAmount: Decimal, deNominator: Decimal) -> String {
    let decPercent = decAmount / deNominator
    var strPercent = decPercent.toPercent(2)
    strPercent = formatToLength(aAmount: strPercent, length: 7)
    let strAmount = decAmount.toCurrency(false)
    return strAmount + " " + strPercent
}

func formatToLength(aAmount: String, length: Int) -> String {
    var strToLength = aAmount
    
    if strToLength.count < length {
        let diff = length - strToLength.count
        strToLength = buffer(spaces: diff) + strToLength
    }
    
    return strToLength
}

func getFileNameAndDateLead(fileName: String, maxCharsInLine: Int, spaces: Int) -> [String] {
    var arry = [String]()
    let emptyLine = "\n"
    let maxOneLineLength = maxCharsInLine - 20
    
    if fileName.count < maxOneLineLength {
        let strFileName: String = fileName
        let adjFileName: String = buffer(spaces: spaces) + "file name:"
        let str_Line_FileName: String = justifyText(strA: adjFileName, strB: strFileName, maxLength: maxCharsInLine)
        arry.append(str_Line_FileName)
    } else {
        let myWords: [String] = fileName.components(separatedBy: " ")
        let nameOne: String = wordListToString(words: myWords, maxOneLineLength: maxOneLineLength).0
        let nameTwo: String = wordListToString(words: myWords, maxOneLineLength: maxOneLineLength).1
        let lineOne: String = justifyText(strA: "file name:", strB: nameOne, maxLength: maxCharsInLine)
        arry.append(lineOne)
        let stringA: String = buffer(spaces: 5) + nameTwo
        let stringB: String = ""
        let lineTwo = justifyText(strA: stringA, strB: stringB, maxLength: maxCharsInLine)
        arry.append(lineTwo)
    }
    
    let strDate: String = today().toStringDateLong()
    let adjDate: String = buffer(spaces: spaces) + "date:"
    let str_Line_Date: String = justifyText(strA: adjDate, strB: strDate, maxLength: maxCharsInLine)
    arry.append(str_Line_Date)
    arry.append(emptyLine)
    
    return arry
}

func getMaxCharsInLine(isPad: Bool, isLandscape: Bool) -> Int {
    var maxChars: Int = 42
    
    if isPad == true {
        maxChars = 38
    } else {
        if isLandscape == true {
            maxChars = 74
        }
    }
    
    return maxChars
}

func wordListToString(words: [String], maxOneLineLength: Int) -> (String, String) {
    var strOne: String = ""
    var wordCount: Int = 0
    for x in 0..<words.count {
        let strWord: String = words[x] + " "
        if strOne.count + strWord.count > maxOneLineLength {
            break
        } else {
            strOne = strOne + strWord
            wordCount += 1
        }
    }
    
    var strTwo: String = ""
    for y in wordCount..<words.count {
        strTwo = strTwo + words[y] + " "
    }
    
    return (strOne, strTwo)
}

func justifyText(strA: String, strB: String, maxLength: Int, strOdd: String = ".") -> String {
    var a = strA + " "
    var b = " " + strB
    let strEven: String = " "
    var targetLength = maxLength - (a.count + b.count)
    
    if targetLength < 4 {
        let adjMax: Int = maxLength - a.count - 3
        b = compactString(strIn: b, maxLength: adjMax)
        targetLength = maxLength - (a.count + b.count)
    }
    
    for x in 0..<targetLength {
        if x % 2 == 0 {
            a = a + strEven
        } else {
            a = a + strOdd
        }
    }
    return a + b
}

func compactString(strIn: String, maxLength: Int) -> String {
    let strOut = strIn.prefix(maxLength)
    return String(strOut)
}

func sectionTitle (strTitle: String, aLeadFollow: String, maxChars: Int) -> String {
    var strTitle = " " + strTitle + " "
    var len: Int = strTitle.count
    while len < maxChars {
        strTitle = aLeadFollow + strTitle + aLeadFollow
        len = strTitle.count
    }
    if strTitle.count > maxChars {
        strTitle = String(strTitle.dropLast())
    }
    return strTitle
}

func totalsLine (maxChars: Int, lenOfTotalsLine: Int, lenOfPctLine: Int = 0) -> String {
    var strA = buffer(spaces: maxChars - lenOfTotalsLine)
    if lenOfPctLine > 0 {
        let newLength = maxChars - lenOfTotalsLine - lenOfPctLine - 1
        strA = buffer(spaces: newLength)
    }
    var strB = ""
    var x = 1
    while x <= lenOfTotalsLine {
        strB = strB + "-"
        x = x + 1
    }
    var strC = ""
    if lenOfPctLine > 0 {
        x = 1
        while x <= lenOfPctLine {
            strC = strC + "-"
            x = x + 1
        }
        strC = " " + strC
    }
    var strTotalsLine = strA + strB
    if lenOfPctLine > 0 {
        strTotalsLine = strTotalsLine + strC
    }
    
    return strTotalsLine
}


func wordsToSentence(aWords: [String], aMax: Int) -> String {
    var newWords: [String] = aWords
    var sentence: String = ""
     
    while getLengthOfWords(aWords: newWords) < aMax {
        for i in 0...newWords.count - 1 {
            newWords[i]  = newWords[i] + " "
            if getLengthOfWords(aWords: newWords) == aMax {
                break
                }
            }
        }
    
    for word in newWords {
        sentence = sentence + word
    }
    return sentence
}


func getLengthOfWords(aWords: [String]) -> Int {
    var runTotalLength = 0
    
    for word in aWords {
        runTotalLength = runTotalLength + word.count
    }
    return runTotalLength
}
