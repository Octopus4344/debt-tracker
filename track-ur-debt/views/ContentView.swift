//
//  ContentView.swift
//  track-ur-debt
//
//  Created by Apolonia Abramowicz on 29/10/2024.
//

import SwiftUI
import BottomSheet
import Charts


struct ContentView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    init() {
        
        UITabBar.appearance().backgroundColor = UIColor.black
        
        UITabBar.appearance().overrideUserInterfaceStyle = .dark
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }
    
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
        .preferredColorScheme(.dark)
        .onAppear {
            Task {
                if loginViewModel.isLoggedIn {
                    await loginViewModel.fetchDataAndCalculateBalance()
                }
            }
        }
    }
}

struct LayoutView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    @State private var showForm = false
    @State private var isTabBarHidden = false
    
    
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
                    NavigationLink(destination: AddDebdtFormView(loginViewModel: loginViewModel)
                    ) {
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
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.65)
    @State var searchText: String = ""
    @State private var fullDebt: Double = 0
    @State private var fullDebtToMe: Double = 0

    let words: [String] = ["birthday", "pancake", "expansion", "brick", "bushes", "coal", "calendar", "home", "pig", "bath", "reading", "cellar", "knot", "year", "ink"]
    
    var filteredWords: [String] {
        self.words.filter({ $0.contains(self.searchText.lowercased()) || self.searchText.isEmpty })
    }
    
    
    var body: some View {

        VStack {
            Text(loginViewModel.totalBalance < 0 ? "You owe your friends" : "Your friends owe you")
                .foregroundColor(.gray)
                .fontWeight(.bold)
                .padding(.bottom, 1)
            Text(String(format: "%.2f zł", loginViewModel.totalBalance))
                .font(.system(size: 50, weight: .bold))
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.large)
        .padding(.top, 130)
        
        .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
            .relativeBottom(0.14),
            .relative(0.4),
            .relativeTop(0.9)
        ]) {
            VStack(spacing: 10) {
                HStack {
                    Text("My total debt")
                        .bold()
                    Spacer()
                    Text(String(format: "%.2f zł", self.fullDebt))
                    .font(.system(size: 35, weight: .bold))
                }
                .padding(35)
                .background(Color("Secondary"))
                .cornerRadius(35)
                Spacer()
                HStack {
                    Text("Total debt to me")
                        .bold()
                    Spacer()
                    Text(String(format: "%.2f zł", self.fullDebtToMe))
                    .font(.system(size: 35, weight: .bold))
                }
                .padding(35)
                .background(Color("Secondary"))
                .cornerRadius(35)
                Spacer()
                HStack {
                    PieChart(fullDebt: self.fullDebt, fullDebtToMe: self.fullDebtToMe)
                }
                .padding(35)
                .background(Color("Secondary"))
                .cornerRadius(35)
            }
            .padding()

        }

        .enableAppleScrollBehavior()
        .customBackground(
            Color.darkerGreen
                .cornerRadius(30)
        )
        .onAppear {
            Task {
                await loginViewModel.fetchDataAndCalculateBalance()
                self.fullDebt = await loginViewModel.calculateFullDebt()
                self.fullDebtToMe = await loginViewModel.calculateFullDebtToMe()
            }
        }
    }

}
struct Debt: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
}


struct PieChart: View {
    @State private var debts: [Debt] = [
        .init(title: "Annual", amount: 0.7),
        .init(title: "Monthly", amount: 0.2),
    ]
    var fullDebt: Double
    var fullDebtToMe: Double
    var body: some View {
        Chart(debts) { debt in
            SectorMark(
                angle: .value(
                    Text(verbatim: debt.title),
                    debt.amount
                )
            )
            .foregroundStyle(
                by: .value(
                    Text(verbatim: debt.title),
                    debt.title
                )
                
            )
        }
        .frame(width: 300, height: 300)
        .onAppear {
                    self.debts = [
                        Debt(title: "My debt", amount: fullDebt),
                        Debt(title: "Debt to me", amount: fullDebtToMe)]
        }
//        .chartForegroundStyleScale(
//            ["My debt": .red, "Debt to me": .blue]
//        )
    }
}



#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}


