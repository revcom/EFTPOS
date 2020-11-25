//
//  ContentView.swift
//  EFTPOS
//
//  Created by Robert Crago on 26/11/20.
//

import SwiftUI

struct ContentView: View {
    @State var amount = 0.00

    var body: some View {
        VStack( alignment: .leading, spacing: 10, content: {
            HStack {
                Text("Pay BWAC:")

                TextField("Amount", value: $amount, formatter: NumberFormatter.currency,
                          onEditingChanged: {_ in },
                          onCommit: {
                            NFCScan().scan()
                          })
                    .keyboardType(.numbersAndPunctuation)
                    .font(.title)

            }
        })
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
