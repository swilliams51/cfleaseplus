//
//  MailData.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/6/23.
//

import Foundation

struct AttachmentData {
    let data: Data
    let mimeType: String
    let fileName: String
}

struct ComposeMailData {
    let subject: String
    let recipients: [String]?
    let message: String
    let attachments: [AttachmentData]?
}
