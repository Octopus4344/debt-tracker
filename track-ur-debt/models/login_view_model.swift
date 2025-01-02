//
//  login_view_model.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 01/01/2025.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore


struct User {
    let uid: String
    let email: String
}

struct FirestoreUser {
    let uid: String
    let email: String
    let name: String
    var friends: [String]
    var incomingRequests: [String]
    var outgoingRequests: [String]
    
    init?(from data: [String: Any]) {
        guard let uid = data["uid"] as? String,
              let email = data["email"] as? String,
              let name = data["name"] as? String else {
            return nil
        }
        self.uid = uid
        self.email = email
        self.name = name
        self.friends = data["friends"] as? [String] ?? []
        self.incomingRequests = data["incomingRequests"] as? [String] ?? []
        self.outgoingRequests = data["outgoingRequests"] as? [String] ?? []
    }
    
    func toDictionary() -> [String: Any] {
        return ["uid": uid, "email": email, "name": name, "friends": friends, "incomingRequests": incomingRequests, "outgoingRequests": outgoingRequests]
    }
}

class LoginViewModel: ObservableObject{
    
    @Published var email = "email@p1.pl"
    @Published var password = "123456"
    @Published private var _currentUser : User? = nil
    @Published private var storedUser : FirestoreUser? = nil
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    @Published var showSignupView = false
    
    private var handler = Auth.auth().addStateDidChangeListener{_,_ in }
    private let db = Firestore.firestore()
    
    var currentStoredUser: FirestoreUser? {
        return storedUser
    }
    
    var currentUser: User {
        return _currentUser ?? User(uid: "", email: "")
    }
    
    init(){
        handler = Auth.auth().addStateDidChangeListener{ auth,user in
            if let user = user {
                self._currentUser = User(uid: user.uid, email: user.email!)
                self.isLoggedIn = true
                self.fetchUser()
            } else {
                self._currentUser = nil
                self.storedUser = nil
                self.isLoggedIn = false
            }
        }
    }
    
    func signIn() async {
        hasError = false
        do{
            try await Auth.auth().signIn(withEmail: email, password: password)
        }catch{
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() async {
        hasError = false
        do{
            try Auth.auth().signOut()
            
        }catch{
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func signUp() async {
        hasError = false
        do{
            try await Auth.auth().createUser(withEmail: email, password: password)
            createUserInFirestore()
        }catch{
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    
    private func fetchUser(){
        guard let user = _currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { (snapshot, error) in
            if let error = error{
                self.hasError = true
                self.errorMessage = error.localizedDescription
                return
            }
            guard let data = snapshot?.data(), let storedUser = FirestoreUser(from: data) else {
                self.hasError = true
                self.errorMessage = "Could not fetch user data"
                return
            }
            DispatchQueue.main.async {
                self.storedUser = storedUser
            }
        }
    }
    
    private func createUserInFirestore(){
        guard let user = _currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        let data: [String: Any] = [
            "uid": user.uid,
            "email": user.email,
            "name": ""
        ]
        print("Q")
        guard let newUser = FirestoreUser(from: data) else { return }
        userRef.setData(newUser.toDictionary()) { error in
            if let error = error{
                self.hasError = true
                self.errorMessage = error.localizedDescription
                print(self.errorMessage)
                return
            }
        }
        
    }
    
    func sendFriendRequest(toEmail friendEmail: String) async{
        let userRef = db.collection("users")
        do {
            let querySnapshot = try await userRef.whereField("email", isEqualTo: friendEmail).getDocuments()
            
            guard let friendDocument = querySnapshot.documents.first else {
                self.hasError = true
                self.errorMessage = "No user found with that email"
                return
            }
            
            let friendData = friendDocument.data()
            guard let friend = FirestoreUser(from: friendData) else {
                self.hasError = true
                self.errorMessage = "Friend request already sent"
                return
            }
            
            let currentUserRef = db.collection("users").document(currentUser.uid)
            let friendUserRef = db.collection("users").document(friend.uid)
            
            try await currentUserRef.updateData([
                "outgoingRequests": FieldValue.arrayUnion([friend.uid])
            ])
            
            try await friendUserRef.updateData([
                "incomingRequests": FieldValue.arrayUnion([currentUser.uid])
            ])
            
            DispatchQueue.main.async {
                self.storedUser?.outgoingRequests.append(friend.uid)
            }
        }
        catch {
            self.hasError = true
            self.errorMessage = error.localizedDescription
        }
    }
    
    func rejectFriendRequest(fromUID friendUID: String) async {
        let userRef = db.collection("users")
        
        do {
            let currentUserRef = db.collection("users").document(currentUser.uid)
            let friendUserRef = db.collection("users").document(friendUID)
            
            try await currentUserRef.updateData(["incomingRequests": FieldValue.arrayRemove([friendUID])])
            try await friendUserRef.updateData(["outgoingRequests": FieldValue.arrayRemove([currentUser.uid])])
            
            DispatchQueue.main.async {
                self.storedUser?.incomingRequests.removeAll { $0 == friendUID }
            }
        }
        catch {
            self.hasError = true
            self.errorMessage = error.localizedDescription
        }
        
    }
    
    func acceptFriendRequest(fromUID friendUID: String) async {
        let userRef = db.collection("users")
        
        do {
            let currentUserRef = db.collection("users").document(currentUser.uid)
            let friendUserRef = db.collection("users").document(friendUID)
            let friendSnapshot = try await friendUserRef.getDocument()
            
            guard let friendData = friendSnapshot.data(), let friend = FirestoreUser(from: friendData) else {
                self.hasError = true
                self.errorMessage = "Couldn't retrieve friend data"
                return
            }
            
            try await currentUserRef.updateData(["incomingRequests": FieldValue.arrayRemove([friendUID]),
                                                 "Friends":FieldValue.arrayUnion([friend.uid])
                                                 ])
            
            try await friendUserRef.updateData(["outgoingRequests": FieldValue.arrayRemove([currentUser.uid]),
                                                "Friends":FieldValue.arrayUnion([currentUser.uid])
                                               ])
            DispatchQueue.main.async {
                self.storedUser?.friends.append(friend.uid)
                self.storedUser?.incomingRequests.removeAll { $0 == friendUID }
            }
        }
        catch {
            self.hasError = true
            self.errorMessage = error.localizedDescription
        }
    }
    
    
    deinit{
        Auth.auth().removeStateDidChangeListener(handler)
    }
}
