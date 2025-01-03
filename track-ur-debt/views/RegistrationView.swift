//
//  RegistrationView.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 02/01/2025.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    fileprivate func EmailInput() -> some View {
        TextField("Email", text: $loginViewModel.email)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func PasswordInput() -> some View {
        SecureField("Password", text: $loginViewModel.password)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func SignUputton() -> some View {
        Button(action: {
            Task {
                await loginViewModel.signUp()
            }
        }) {
            Text("Sign Up")
                .foregroundColor(.blue)
            
        }
    }
    
    fileprivate func ToggleToSignIn() -> some View {
        Button(action: {
            loginViewModel.showSignupView = false
        }) {
            Text("Sign In")
                .foregroundColor(.gray)
            
        }
    }
    
    var body: some View {
        VStack {
            
            EmailInput()
            PasswordInput()
            SignUputton()
            ToggleToSignIn()
            
        }
        .alert("Error", isPresented: $loginViewModel.hasError) {
        } message: {
            Text(loginViewModel.errorMessage)
        }
        .padding()
    }
}
