//
//  NFCScan.swift
//  EFTPOS
//
//  Created by Robert Crago on 26/11/20.
//

import UIKit
import CoreNFC

class NFCScan: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    
    @Published var alertMessage = "Alert me!"
    @Published var showAlert = false
    @Published var isInitialised = false
    @Published var name = ""
    @Published var amount = ""
    
    var session: NFCNDEFReaderSession?
    
    override init() {
        super.init()
        isInitialised = initialise()
    }

    func initialise() -> Bool {
        guard NFCNDEFReaderSession.readingAvailable else {
            alertMessage = "This device doesn't support tag scanning"
            showAlert = true
            return false
        }
        
        return true
    }
    
    func scan() {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Swipe your BWAC card over top of phone. Genuine Credit Cards ignored"
        session?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("Session activated")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                print ("Invalidate error \(readerError)")
            }
        }

        // To read new tags, a new session instance is required.
        self.session = nil
    }

    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print ("Did detect NDEFs")
        
//        DispatchQueue.main.async {
//            // Process detected NFCNDEFMessage objects.
//        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        print ("Detected tag(s)")
        if tags.count > 1 {
            // Restart polling in 500ms
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and perform NDEF message reading
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.alertMessage = "Tag is not NDEF compliant"
                    session.invalidate()
                    return
                } else if nil != error {
                    session.alertMessage = "Unable to query NDEF status of tag"
                    session.invalidate()
                    return
                }
                
                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    var statusMessage: String
                    if nil != error || nil == message {
                        statusMessage = "Bad read - TRY AGAIN"
                    } else {
                        guard let payload = message?.records[0].payload else { print ("No messages"); return }
                        let payloadText = payload.dropFirst(3)
                        guard let payloadStr = String(bytes: payloadText, encoding: .utf16) else { print ("No payload"); return }
                        statusMessage = "APPROVED"
                        DispatchQueue.main.async {
                            self.name = payloadStr
//                            self.amount = ""
                        }
                    }
                    
                    session.alertMessage = statusMessage
                    session.invalidate()
                })
            })
        })
    }
}

