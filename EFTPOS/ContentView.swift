//
//  ContentView.swift
//  EFTPOS
//
//  Created by Robert Crago on 26/11/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var scanner = NFCScan()

    @State var amount = 0.00
    @State var name = ""
    
    var body: some View {
        if scanner.isInitialised {
            VStack( alignment: .leading, spacing: 10, content: {
                HStack {
                    Text("Pay BWAC:")

                    TextField("Amount", value: $amount, formatter: NumberFormatter.currency,
                              onEditingChanged: {_ in },
                              onCommit: {
                                name = scanner.scan()
                              })
                        .keyboardType(.numbersAndPunctuation)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 50)
                        .font(.title)
                        .alert(isPresented: $scanner.showAlert) {
                            Alert(title: Text("Sorry"), message: Text(scanner.alertMessage), dismissButton: .default(Text("OK")))
                        }
                    if name.count > 0 { Text("Thanks \(name)") }
                    Spacer()
                }
            })
        } else {
            Text("❌ Scanning not supported on this iPhone")
        }
    }
}

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
