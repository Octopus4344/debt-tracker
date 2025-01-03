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
            
            Divider()
                .padding(.vertical)
            
            Text("Your friend requests")
                .font(.headline)
            
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
            
            
            Divider()
                .padding(.vertical)
            
            Text("Your friends")
                .font(.headline)
            
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
