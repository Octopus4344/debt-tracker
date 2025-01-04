//
//  CustomTextField.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 04/01/2025.
//
import SwiftUI

struct CustomTextField: View {
    let label: String
    let placeholder: String
    @Binding var text : String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !label.isEmpty {
                Text(label)
//                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.horizontal,25)
            }
            TextField(placeholder, text: $text)
                .padding(.horizontal,25)
                .padding(.vertical,25)
                .background(Color("Secondary"))
                .cornerRadius(45)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
                .textInputAutocapitalization(.never)
            
            
        }
        .padding(.vertical,5)
    }
    
    
}

struct CustomSecureTextField: View {
    let label: String
    let placeholder: String
    @Binding var text : String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !label.isEmpty {
                Text(label)
//                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.horizontal,25)
            }
            SecureField(placeholder, text: $text)
                .padding(.horizontal,25)
                .padding(.vertical,25)
                .background(Color("Secondary"))
                .cornerRadius(45)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
                .textInputAutocapitalization(.never)
            
            
        }
        .padding(.vertical,5)
    }
    
    
}
