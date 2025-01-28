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
            CustomButton(text: "Log Out", action: {
                Task {
                    await loginViewModel.signOut()
                }
            })
        }
        .navigationTitle("You profile")
    }
}
