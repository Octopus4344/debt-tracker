//
//  Button.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 04/01/2025.
//
import SwiftUI

struct CustomButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            HStack{
                Text(text)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("Secondary"))
            }
            .padding(.horizontal,30)
            .padding(.vertical,25)
            .background(Color("Primary"))
            .foregroundColor(Color.white)
            .cornerRadius(50)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(30)
    }
    
}
