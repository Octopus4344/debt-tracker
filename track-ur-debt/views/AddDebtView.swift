//
//  AddDebtView.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 16/01/2025.
//

import SwiftUI

struct AddDebdtFormView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var viewModel: AddDebtViewModel
    
    init(loginViewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: AddDebtViewModel(loginViewModel: loginViewModel))
    }
    
//    var body: some View {
//        Text("Hello, World!")
//    }
    

    
    var body: some View {
        Form {
            Section(header: Text("Add new transaction")) {
                CustomTextField(label: "Enter an amount", placeholder: "0.00", text: $viewModel.amount)
                Picker("Choose currency", selection: $viewModel.currency) {
                    ForEach(viewModel.availableCuurencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                CustomTextField(label: "Enter a currency", placeholder: "USD", text: $viewModel.currency)
            }
            CustomButton(text: "Add", action: {viewModel.addTransaction()})
                .alert("Error", isPresented: $viewModel.hasError) {
                } message: {
                    Text(viewModel.errorMessage)
                }
                .padding()
            
                .alert(isPresented: Binding<Bool>(
                    get: { !viewModel.successMessage.isEmpty },
                    set: { _ in viewModel.successMessage = "" }
                    
                )) {
                    Alert(title: Text("Succes"), message: Text(viewModel.successMessage) )
                }
                .padding()
        }
        .padding()
        .onChange(of: viewModel.currency) {
            viewModel.fetchConversionRate()
        }
        .onAppear{
            viewModel.fetchConversionRate()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}
