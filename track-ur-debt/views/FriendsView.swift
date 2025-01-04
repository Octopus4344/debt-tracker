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
    @State private var friendEmails: [String: String] = [:]
    @State private var selectedTab: Tab = .friends
    
    enum Tab {
        case friends
        case requests
        case addFriend
    }
    
    var body: some View{
        VStack {
            if selectedTab == .friends {
                HStack {
                    Button(action: {
                        selectedTab = .addFriend
                    }){
                        HStack {
                            Image(systemName: "person.fill.badge.plus")
                            Text("Add a friend")
                        }
                        .padding(.horizontal,30)
                        .padding(.vertical,10)
                        .background(Color("Secondary"))
                        .foregroundColor(Color.white)
                        .cornerRadius(25)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        selectedTab = .requests
                    }){
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Invitations")
                        }
                        .padding(.horizontal,30)
                        .padding(.vertical,10)
                        .background(Color("Secondary"))
                        .foregroundColor(Color.white)
                        .cornerRadius(25)
                        
                    }
                    .buttonStyle(PlainButtonStyle())

                }
                .padding(.top,10)
            }
            
            Divider()
            
            switch selectedTab {
            case .friends:
                VStack {
                    if let friends = loginViewModel.currentStoredUser?.friends, !friends.isEmpty {
                        List(friends, id: \.self) { friendUID in
                            HStack {
                                Text(friendEmails[friendUID] ?? "loading...")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .onAppear {
                                        Task {
                                            if friendEmails[friendUID] == nil {
                                                let email = await loginViewModel.fetchUserEmail(forUID: friendUID)
                                                DispatchQueue.main.async {
                                                    friendEmails[friendUID] = email
                                                }
                                            }
                                        }
                                    }
                                Button(action: {
                                    Task {
                                        await loginViewModel.addTransaction(withUID: friendUID, amount: 4.0, paidBy: friendUID)
                                    }
                                }) {
                                    Image(systemName: "rectangle.portrait.badge.plus.fill")
                                }
                                
                            }
                        }
                    }
                    else {
                        Text("No friends")
                    }
                }
            case .requests:
                VStack {
                    if let incomingRequests = loginViewModel.currentStoredUser?.incomingRequests, !incomingRequests.isEmpty {
                        List(incomingRequests, id: \.self) { friendUID in
                            HStack {
                                Text(friendEmails[friendUID] ?? "loading...")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .onAppear {
                                        Task {
                                            if friendEmails[friendUID] == nil {
                                                let email = await loginViewModel.fetchUserEmail(forUID: friendUID)
                                                DispatchQueue.main.async {
                                                    friendEmails[friendUID] = email
                                                }
                                            }
                                        }
                                    }
                                Spacer()
                                Button(action: {
                                    Task {
                                        await loginViewModel.acceptFriendRequest(fromUID: friendUID)
                                    }
                                }) {
                                    Image(systemName: "person.fill.checkmark")
                                }
                                Button(action: {
                                    Task {
                                        await loginViewModel.rejectFriendRequest(fromUID: friendUID)
                                    }
                                }) {
                                    Image(systemName: "person.fill.xmark")
                                }
                            }
                        }
                    }
                    else {
                        Text("No friends requests")
                    }
                }
            case .addFriend:
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
            }

        }
        
        .alert("Error", isPresented: $loginViewModel.hasError) {
        } message: {
            Text(loginViewModel.errorMessage)
        }
        .padding()
    }
}



#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}
