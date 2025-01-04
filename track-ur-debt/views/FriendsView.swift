//
//  FriendsView.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 02/01/2025.
//

import SwiftUI
import BottomSheet


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
                    FriendListView(loginViewModel: loginViewModel, friendEmails: $friendEmails)

                case .requests:
                    FriendRequestsView(loginViewModel: loginViewModel, friendEmails: $friendEmails, onBack: {selectedTab = .friends})

                case .addFriend:
                    AddFriendView(friendEmail: $friendEmail, isFriendRequestBeingSent: $isFriendRequestBeingSent, loginViewModel: loginViewModel, onBack: {selectedTab = .friends})

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

struct FriendListView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @Binding var friendEmails: [String: String]
    var body: some View {
        VStack {
            if let friends = loginViewModel.currentStoredUser?.friends, !friends.isEmpty {
                List(friends, id: \.self) { friendUID in
                    NavigationLink(destination: FriendDetailsView(friendUID: friendUID, loginViewModel: loginViewModel, friendEmail: friendEmails[friendUID])) {
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
                            Text(String(format: "%.2f zł", loginViewModel.calculateBalance(withUID: friendUID)))
                            //                                    Button(action: {
                            //                                        Task {
                            //                                            await loginViewModel.addTransaction(withUID: friendUID, amount: 4.0, paidBy: friendUID)
                            //                                        }
                            //                                    }) {
                            //                                        Image(systemName: "rectangle.portrait.badge.plus.fill")
                            //                                    }
                            
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
    }
}

struct FriendRequestsView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @Binding var friendEmails: [String: String]
    let onBack: () -> Void
    var body: some View {
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
            onBack()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Friends")
            }
            .padding(.top,15)
        })
    }
}

struct AddFriendView: View {
    @Binding var friendEmail: String
    @Binding var isFriendRequestBeingSent: Bool
    @ObservedObject var loginViewModel: LoginViewModel
    let onBack: () -> Void
    var body: some View {
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
            onBack()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Friends")
            }
            .padding(.top,15)
        })
    }
}

struct FriendDetailsView: View {
    let friendUID: String
    @ObservedObject var loginViewModel: LoginViewModel
    var friendEmail: String?
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.65)
    @State private var transactions: [Transaction] = []
    @State private var balance: Double = 0
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    fileprivate func AddNew() -> some View {
        CustomButton(text: "Add", action: {
            Task {
                await loginViewModel.addTransaction(withUID: friendUID, amount: 4.0, paidBy: friendUID)
            }
        }
    )}
    
    
    var body: some View {
        VStack {
            Text(balance < 0 ? "You owe your friend" : "Your friend owe you")
                .foregroundColor(.gray)
                .fontWeight(.bold)
                .padding(.bottom, 1)
            Text(String(format: "%.2f zł", balance))
                .font(.system(size: 50, weight: .bold))
            AddNew()

        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .navigationTitle(friendEmail ?? "loading...")
        .navigationBarTitleDisplayMode(.large)
        
        .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
            .relativeBottom(0.14),
            .relative(0.4),
            .relativeTop(0.9)
        ]) {
            //The list of nouns that will be filtered by the searchText.
            VStack {
                Text("History")
                    .foregroundColor(.black)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)
                if transactions.isEmpty {
                    Text("No transactions found")
                        .foregroundColor(.black)
                        .font(.headline)
                } else {
                    VStack(spacing: 10) {
                        ForEach(transactions, id: \.self) { transaction in
                            HStack {
                                Text(formatDate(transaction.date))
                                    .bold()
                                Spacer()
                                Text(transaction.paidBy == loginViewModel.currentUser.uid ? String(format: "+ %.2f zł", transaction.amount)
                                     : String(format: "- %.2f zł", transaction.amount)
                                )
                                .font(.system(size: 35, weight: .bold))
                            }
                            .padding(35)
                            .background(Color("Secondary"))
                            .cornerRadius(35)
                        }
                    }
//                    .padding(.horizontal, 40)
//                    .padding(.vertical, 40)
                    .padding()
                }
            }
            .padding(.top, 35)
            .onAppear {
                Task {
                    self.transactions = await loginViewModel.fetchUserTransactions(withUID: friendUID)
                    self.balance = loginViewModel.calculateBalance(withUID: friendUID)
                }
            }

        }
        .enableAppleScrollBehavior()
        .customBackground(
            Color.darkerGreen
                .cornerRadius(30)
        )
    }
}


#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}
