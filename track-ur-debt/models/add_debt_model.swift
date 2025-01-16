//
//  add_debt_model.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 16/01/2025.
//

import Foundation

class AddDebtViewModel: ObservableObject {
    @Published var pays: String = "DdrN3UcMpZUvlxfZ8AIrBrMZ5mx"
    @Published var indebted: String = "OQR8alOp5GWf2Ax16ThR4EkjLvi1"
    @Published var amount: String = ""
    @Published var currency: String = "PLN"
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    @Published var conversionRate: Double = 1.0
    
    public let availableCuurencies = ["PLN", "USD", "EUR", "GBP", "CZK"]
    private let apiKey: String = "fca_live_9r3DTzOKWo8YyvDndrpNu9Rl2rELohMD3VuxJBOj"
    
    private let loginViewModel: LoginViewModel
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
    }
    
    func fetchConversionRate() {
        let endpoint: String = "https://api.freecurrencyapi.com/v1/latest"
        let params = [
            "apikey": apiKey,
            "base_currency": currency,
            "currencies": "PLN"
        ]
        
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async {
                self.hasError = true
                self.errorMessage = "Couldn't fetch any data"
                print(self.errorMessage)
            }
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let rate = data["PLN"] as? Double {
                    DispatchQueue.main.async {
                        self.conversionRate = rate
                    }
                }
                else {
                    DispatchQueue.main.async{
                        self.hasError = true
                        self.errorMessage = "Couldn't parse rate"
                    }
                }
            } catch {
                self.hasError = true
                self.errorMessage = "Couldn't fetch any data"
                print(self.errorMessage)
            }
        }
    }
        
        func addTransaction() {
            
            guard let amount = Double(amount) else {
                hasError = true
                errorMessage = "Invalid amount entered"
                return
            }
            
            guard !pays.isEmpty, !indebted.isEmpty else {
                hasError = true
                errorMessage = "Please select a person"
                return
            }
            
            let amountInPLN = amount * conversionRate
            
            Task {
                await loginViewModel.addTransaction(withUID: indebted, amount: amountInPLN, paidBy: pays)
                if loginViewModel.hasError {
                    DispatchQueue.main.async {
                        self.hasError = true
                        self.errorMessage = self.loginViewModel.errorMessage
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.successMessage = "Transaction added successfully!"
                    }
                }
            }
            
        }
        
    }
    
    
    
    
    

