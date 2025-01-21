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
            Section() {
                CustomTextField(label: "Enter an amount", placeholder: "0.00", text: $viewModel.amount)
                Spacer()
                Picker("Choose currency", selection: $viewModel.currency) {
                    ForEach(viewModel.availableCuurencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                Spacer()
                Picker("Who was paying?", selection: $viewModel.pays) {
                    if viewModel.friendsWithEmails.isEmpty {
                        Text("You have no friends added").tag("self")
                    } else {
                        ForEach(viewModel.friendsWithEmails, id: \.uid) { friend in
                            Text(friend.email).tag(friend.uid)
                        }
                    }
                    
                }
                Spacer()
                Picker("Who is in debt?", selection: $viewModel.indebted) {
                    if viewModel.friendsWithEmails.isEmpty {
                        Text("You have no friends added").tag("self")
                    } else {
                        ForEach(viewModel.friendsWithEmails, id: \.uid) { friend in
                            Text(friend.email).tag(friend.uid)
                        }
                    }
                    
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
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowBackground(Color.clear)

        }
        .onChange(of: viewModel.currency) {
            viewModel.fetchConversionRate()
        }
        .onAppear{
            viewModel.fetchConversionRate()
        }
        .navigationTitle("Add new transaction")
    }
        
}

#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}
