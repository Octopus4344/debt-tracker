//
//  FriendsView.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 02/01/2025.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var friendEmail: String = ""
    @State private var isFriendRequestBeingSent: Bool = false
    var body: some View{
        VStack {
            TextField("Send a request", text: $friendEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button(action: {
                Task {
                    isFriendRequestBeingSent = true
                    await loginViewModel.sendFriendRequest(toEmail: friendEmail)
                    isFriendRequestBeingSent = false
                    friendEmail = ""
                }
            }) {
                if isFriendRequestBeingSent {
                    ProgressView()
                }
                else {
                    Text("Send a request")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .disabled(friendEmail.isEmpty || isFriendRequestBeingSent)
            
            
        }
        .alert("Error", isPresented: $loginViewModel.hasError) {
        } message: {
            Text(loginViewModel.errorMessage)
        }
        .padding()
    }
}



struct AddDebdtFormView: View {
    @State private var pays: String = ""
    @State private var indebted: String = ""
    @State private var amount: String = ""
    @State private var currency: String = ""
    
    var body: some View {
        Form {
            TextField("Pays", text: $pays)
            TextField("Indebted", text: $indebted)
            TextField("Amount", text: $amount)
            TextField("Currency", text: $currency)
        }
    }
}
