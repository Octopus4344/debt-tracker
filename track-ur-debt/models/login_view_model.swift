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

struct Transaction: Hashable {
    let amount: Double
    let date: Date
    let paidBy: String
    
    init?(from data: [String: Any]) {
        guard let amount = data["amount"] as? Double,
              let date = data["date"] as? Timestamp,
              let paidBy = data["paidBy"] as? String else {
            return nil
        }
        self.amount = amount
        self.date = date.dateValue()
        self.paidBy = paidBy
    }
    
    func toDictionary() -> [String: Any] {
        return ["amount": amount, "date": Timestamp(date: date), "paidBy": paidBy]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(amount)
        hasher.combine(date)
        hasher.combine(paidBy)
    }
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.amount == rhs.amount && lhs.date == rhs.date && lhs.paidBy == rhs.paidBy
    }
}

struct FirestoreUser {
    let uid: String
    let email: String
    let name: String
    var friends: [String]
    var incomingRequests: [String]
    var outgoingRequests: [String]
    var transactions : [String : [Transaction]]
    
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
        
        if let rawTransactions = data["transactions"] as? [String : [[String : Any]]] {
            self.transactions = rawTransactions.compactMapValues { $0.compactMap { Transaction(from: $0)}}
        }
        else {
            self.transactions = [:]
        }
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = ["uid": uid, "email": email, "name": name, "friends": friends, "incomingRequests": incomingRequests, "outgoingRequests": outgoingRequests]
        dictionary["transactions"] = transactions.mapValues { $0.map { $0.toDictionary()}}
        return dictionary
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
                print(snapshot?.data())
                print(storedUser)
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
                                                 "friends":FieldValue.arrayUnion([friend.uid])
                                                ])
            
            try await friendUserRef.updateData(["outgoingRequests": FieldValue.arrayRemove([currentUser.uid]),
                                                "friends":FieldValue.arrayUnion([currentUser.uid])
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
    
    func fetchUserEmail(forUID uid: String) async -> String {
        let userRef = Firestore.firestore().collection("users").document(uid)
        do {
            let snapshot = try await userRef.getDocument()
            if let email = snapshot.data()?["email"] as? String {
                return email
            }
        }
        catch {
            print("Error fetching user email: \(error)")
        }
        return uid
    }
    
    func addTransaction(withUID friendUID: String, amount: Double, paidBy: String) async {
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        let friendRef = Firestore.firestore().collection("users").document(friendUID)
        let data: [String: Any] = ["amount": amount, "date": Timestamp(date: Date()), "paidBy": paidBy]
        print("QQQQQQ")
        guard let transaction = Transaction(from: data) else { return }
        print("XDDDDD")
        
        do{
            try await userRef.updateData([
                "transactions.\(friendUID)": FieldValue.arrayUnion([transaction.toDictionary()])
            ])
            try await friendRef.updateData([
                "transactions.\(currentUser.uid)": FieldValue.arrayUnion([transaction.toDictionary()])
            ])
            
            DispatchQueue.main.async {
                self.storedUser?.transactions[friendUID, default: []].append(transaction)
            }
        }
        catch {
            self.hasError = true
            self.errorMessage = error.localizedDescription
        }
    }
    
    func calculateBalance(withUID friendUID: String) -> Double  {
        guard let transactions = storedUser?.transactions[friendUID] else { return 0.0 }
        var balance: Double = 0
        
        print(storedUser?.toDictionary())
        
        for transaction in transactions {
            if transaction.paidBy == currentUser.uid {
                balance += transaction.amount
            }
            else {
                balance -= transaction.amount
            }
        }
        return balance
    }
    
    func fetchUserTransactions(withUID friendUID: String) async -> [Transaction] {
        guard let user = _currentUser else { return [] }
        let useRef = db.collection("users").document(user.uid)
        
        do {
            let snapshot = try await useRef.getDocument()
            if let data = snapshot.data(),
               let transactionsData = data["transactions"] as? [String: [[String: Any]]],
               let transactions = transactionsData[friendUID]?.compactMap({ Transaction(from: $0)}){
                return transactions
            }
        }
        catch {
            print("Error fetching transactions: \(error)")
        }
        return []
    }
    
    deinit{
        Auth.auth().removeStateDidChangeListener(handler)
    }
}

