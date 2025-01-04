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
        CustomTextField(label:"Email", placeholder: "example@email.com", text: $loginViewModel.email)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func PasswordInput() -> some View {
        CustomSecureTextField(label: "Password", placeholder:"Password", text: $loginViewModel.password)
    }
    
    fileprivate func SignUputton() -> some View {
        CustomButton(text: "Sign up", action: {
            Task {
                await loginViewModel.signUp()
            }
        })
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
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack{
                Text("Sign up")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                EmailInput()
                PasswordInput()
                Spacer()
                SignUputton()
                ToggleToSignIn()
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
