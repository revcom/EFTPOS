//
//  NFCScan.swift
//  EFTPOS
//
//  Created by Robert Crago on 26/11/20.
//

import CoreNFC

protocol NFCReaderDelegate {
    func didReceive(payload: String)
}

class NFCScan: NFCReaderDelegate {
    func didReceive(payload: String) {
        print ("Received: \(payload)")
    }
    
    var nfcReader: NFCReader? = nil
    func scan() {
        if nfcReader == nil {
            nfcReader = NFCReader()
            nfcReader?.delegate = self
        }
        nfcReader?.begin()
    }
}


class NFCReader: NSObject {
    private var session: NFCNDEFReaderSession?
    var delegate: NFCReaderDelegate?
    
    func begin() {
        session = NFCNDEFReaderSession(delegate: self,
                                       queue: DispatchQueue.main,
                                       invalidateAfterFirstRead: false)
        session?.begin()
    }
}

extension NFCReader: NFCNDEFReaderSessionDelegate {
    
    func readerSession(
      _ session: NFCNDEFReaderSession,
      didDetect tags: [NFCNDEFTag]
    ) {
      guard
        let tag = tags.first,
        tags.count == 1
        else {
          session.alertMessage = """
            There are too many tags present. Remove all and then try again.
            """
          DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) {
            session.restartPolling()
          }
          return
      }
        tag.queryNDEFStatus { (status, _, error) in
            switch (status) {
            case .notSupported: print ("Unsupported tag")
            case .readOnly: print ("ReadOnly tag")
            case  .readWrite: print ("ReadWrite tag");
                session.invalidate()
            default: print ("Default tag")
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession,
                       didDetectNDEFs messages: [NFCNDEFMessage]) {
        messages.forEach { message in
            message.records.forEach { record in
                if let string = String(data: record.payload, encoding: .ascii) {
                    print ("Type: \(record.type) Payload: \(record.payload)")
                    delegate?.didReceive(payload: string)
                }
            }
        }
    }
    func readerSession(_ session: NFCNDEFReaderSession,
                       didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }
}

