//
//  LoginView.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 01/01/2025.
//
import SwiftUI

struct LoginView: View {
    
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
    
    fileprivate func LoginButton() -> some View {
        Button(action: {
            Task {
                await loginViewModel.signIn()
            }
        }) {
            Text("Sign In")
                .foregroundColor(.blue)
            
        }
    }
    fileprivate func LogoutButton() -> some View {
        Button(action: {
            Task {
                await loginViewModel.signOut()
            }
        }) {
            Text("Log Out")
        }
    }
    
    fileprivate func UserInfo() -> some View {
        VStack{
            Text("UID: \(loginViewModel.currentUser.uid)")
            Text("Email: \(loginViewModel.currentUser.email)")
            LogoutButton()
        }
        
    }
    
    var body: some View {
        VStack {

                EmailInput()
                PasswordInput()
                LoginButton()
            
        }
        .alert("Error", isPresented: $loginViewModel.hasError) {
        } message: {
            Text(loginViewModel.errorMessage)
        }
        .padding()
    }
}
