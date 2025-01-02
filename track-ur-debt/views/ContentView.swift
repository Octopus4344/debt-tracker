//
//  ContentView.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 29/10/2024.
//

import SwiftUI
import BottomSheet


struct ContentView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    var body: some View {
        Group {
            if loginViewModel.isLoggedIn {
                LayoutView()
            } else {
                if loginViewModel.showSignupView {
                    SignUpView()
                }
                else {
                    LoginView()
                }
            }
        }
    }
}

struct LayoutView: View {
    
    @State private var showForm = false
    init() {
        
        UITabBar.appearance().backgroundColor = UIColor.black
        
        UITabBar.appearance().overrideUserInterfaceStyle = .dark
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }
    
    
    var body: some View {
        NavigationView{
            ZStack{
                TabView {
                    HomeView()
                        .tabItem{
                            Label("Home", systemImage: "house.fill")
                        }
                    Spacer()
                    FriendsView()
                        .tabItem{
                            Label("Friends", systemImage:"person.2.fill")
                        }
                    
                }
                .preferredColorScheme(.dark)
                .tint(.white)
                .toolbarColorScheme(.dark)
                
                VStack {
                    Spacer()
                    Button(action: {
                        showForm.toggle()
                    }) {
                        ZStack {
                            Image("Image")
                            Image(systemName: "plus")
                                .font(.system(size: 40))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 45)
                        .padding(.leading, 25)
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(destination: ProfileView()){
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                            .padding(.trailing, 25)
                    }
                }
            }
            
        }
    }
    
}

struct HomeView: View {
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.65)
    @State var searchText: String = ""
    
    let words: [String] = ["birthday", "pancake", "expansion", "brick", "bushes", "coal", "calendar", "home", "pig", "bath", "reading", "cellar", "knot", "year", "ink"]
    
    var filteredWords: [String] {
        self.words.filter({ $0.contains(self.searchText.lowercased()) || self.searchText.isEmpty })
    }
    
    
    var body: some View {
        //A green gradient as a background that ignores the safe area.
        VStack {
            Text("Home")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        
        .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
            .relativeBottom(0.14),
            .relative(0.4),
            .relativeTop(0.9)
        ]) {
            //The list of nouns that will be filtered by the searchText.
            ForEach(self.filteredWords, id: \.self) { word in
                Text(word)
                    .font(.title)
                    .padding([.leading, .bottom])
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .enableAppleScrollBehavior()
        .customBackground(
            Color.darkerGreen
                .cornerRadius(30)
        )
    }
}


struct FriendsView: View {
    var body: some View{
        VStack {
            Text("You friends list")
        }
    }
}



struct AddDebdtFormView: View {
    @State private var pays: String = ""
    @State private var indebted: String = ""
    @State private var amount: String = ""
    @State private var currency: String = ""
    
    var body: some View {
        Form {
            TextField("Pays", text: $pays)
            TextField("Indebted", text: $indebted)
            TextField("Amount", text: $amount)
            TextField("Currency", text: $currency)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}