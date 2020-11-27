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
    
    @State private var alertInput = ""
    
    var body: some View {
        if scanner.isInitialised {

            VStack( alignment: .leading, spacing: 10, content: {
//                Button(action: {
//                    withAnimation {
//                        self.alert()
//                    }
//                }) {
//                    Text(alertInput)
//                }
                HStack( alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10, content: {
                    Text("Amount Owing:")

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
                    Spacer()
                }).padding()
                if name.count > 0 {
                    HStack {
                        Text("Received from: ")
                        Text(scanner.name).font(.title)
                    }
                }
                Spacer()
            })
        } else {
            Text("❌ Scanning not supported on this iPhone")
        }
    }
    
    private func alert() {
        let alert = UIAlertController(title: "Enter Name", message: "...or pseudo", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter something"
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in })
        let textField = alert.textFields![0] as UITextField
        alertInput = textField.text ?? "Name"
        showAlert(alert: alert)
    }
        
    func showAlert(alert: UIAlertController) {
        if let controller = topMostViewController() {
            controller.present(alert, animated: true)
        }
    }
    
    private func keyWindow() -> UIWindow? {
            return UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .compactMap {$0 as? UIWindowScene}
            .first?.windows.filter {$0.isKeyWindow}.first
        }
    
    private func topMostViewController() -> UIViewController? {
           guard let rootController = keyWindow()?.rootViewController else {
               return nil
           }
           return topMostViewController(for: rootController)
       }
    
    private func topMostViewController(for controller: UIViewController) -> UIViewController {
            if let presentedController = controller.presentedViewController {
                return topMostViewController(for: presentedController)
            } else if let navigationController = controller as? UINavigationController {
                guard let topController = navigationController.topViewController else {
                    return navigationController
                }
                return topMostViewController(for: topController)
            } else if let tabController = controller as? UITabBarController {
                guard let topController = tabController.selectedViewController else {
                    return tabController
                }
                return topMostViewController(for: topController)
            }
            return controller
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
