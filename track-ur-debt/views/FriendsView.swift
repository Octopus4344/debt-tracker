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
        NavigationView{
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
                            Spacer()
                            Text("No friends")
                            Spacer()
                        }
                    }
                case .requests:
                    VStack {
                        if let incomingRequests = loginViewModel.currentStoredUser?.incomingRequests, !incomingRequests.isEmpty {
                            List(incomingRequests, id: \.self) { friendUID in
                                HStack {
                                    Text(friendEmails[friendUID] ?? "loading...")
                                        .lineLimit(1)
                                        .font(.system(size: 20))
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
                                            .font(.system(size: 30))
                                    }
                                    Button(action: {
                                        Task {
                                            await loginViewModel.rejectFriendRequest(fromUID: friendUID)
                                        }
                                    }) {
                                        Image(systemName: "person.fill.xmark")
                                            .font(.system(size: 30))
                                    }
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 25)
                                .cornerRadius(100)
                                
                            }
                        }
                        else {
                            Text("No friends requests")
                        }
                    }
//                    .padding()
                    .navigationBarTitle("Friend requests")
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: Button(action: {
                        selectedTab = .friends
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Friends")
                        }
                        .padding(.top,15)
                    })
                case .addFriend:
                    VStack {
                        CustomTextField(label: "Enter friend's email", placeholder: "friend@email.com" , text: $friendEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        Spacer()
                        CustomButton(text: "Send an invitation", action: {
                            Task {
                                isFriendRequestBeingSent = true
                                await loginViewModel.sendFriendRequest(toEmail: friendEmail)
                                isFriendRequestBeingSent = false
                                friendEmail = ""
                            }
                        })
                        .padding(.horizontal)
                        .padding(.top, 50)
                        .disabled(friendEmail.isEmpty || isFriendRequestBeingSent)
                        Spacer()
                        
                    }
                    .padding(.top, 25)
                    .navigationBarTitle("Add a new friend")
                    .navigationBarItems(leading: Button(action: {
                        selectedTab = .friends
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Friends")
                        }
                        .padding(.top,15)
                    })
                }
                
            }
            
            .alert("Error", isPresented: $loginViewModel.hasError) {
            } message: {
                Text(loginViewModel.errorMessage)
            }
            .padding()
        }
    }
}



#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}
