//
//  ProfileView.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 02/01/2025.
//
import SwiftUI
import BottomSheet

struct ProfileView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    var body: some View{
        VStack {
            Text("Your profile")
            Button(action: {
                Task {
                    await loginViewModel.signOut()
                }
            }) {
                Text("Log Out")
            }
        }
    }
}
