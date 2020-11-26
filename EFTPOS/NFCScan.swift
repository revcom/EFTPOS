//
//  NFCScan.swift
//  EFTPOS
//
//  Created by Robert Crago on 26/11/20.
//

import UIKit
import CoreNFC

class NFCScan: ObservableObject {
    @Published var alertMessage = "Alert me!"
    @Published var showAlert = false

    func nfcAvailable() -> Bool {
        guard NFCNDEFReaderSession.readingAvailable else {
            alertMessage = "This device doesn't support tag scanning"
            showAlert = true
            return false
        }
        return false
    }
}

