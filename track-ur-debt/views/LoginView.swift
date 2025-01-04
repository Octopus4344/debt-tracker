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
        CustomTextField(label: "Email", placeholder: "email@example.com", text: $loginViewModel.email)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func PasswordInput() -> some View {
        CustomSecureTextField(label: "Password", placeholder: "password", text: $loginViewModel.password)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func LoginButton() -> some View {
        CustomButton(text: "Log in", action: {
            Task {
                await loginViewModel.signIn()
            }
        })
    }
    
    fileprivate func ToggleToSignUp() -> some View {
        Button(action: {
            loginViewModel.showSignupView = true
        }) {
            Text("Sign Up")
                .foregroundColor(.gray)
            
        }
    }
    
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack{
                Text("Log in")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                EmailInput()
                PasswordInput()
                Spacer()
                LoginButton()
                ToggleToSignUp()
            }
            .alert("Error", isPresented: $loginViewModel.hasError) {
            } message: {
                Text(loginViewModel.errorMessage)
            }
            .padding(.top, 100)
            .padding(.bottom, 30)
            .padding(.vertical, 25)
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}
