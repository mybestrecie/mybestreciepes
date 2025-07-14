//
//  CustomTabBarView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//


import Foundation
import SwiftUI


enum Tab: Int, CaseIterable, Identifiable {
    case home
    case catalog
    case pantry
    case myRecipes

    var id: Int { self.rawValue }

    var systemImageName: String {
        switch self {
        case .home:
            return "house.fill"
        case .catalog:
            return "book.fill"
        case .pantry:
            return "fork.knife"
        case .myRecipes:
            return "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home:
            return "Main"
        case .catalog:
            return "Recipes"
        case .pantry:
            return "AI Chef"
        case .myRecipes:
            return "My recipes"
        }
    }
}


import SwiftUI

struct CustomTabBarView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            ForEach(Tab.allCases) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack {
                        Spacer()
                        
                        Image(systemName: tab.systemImageName)
                            .font(.title2)
                            .frame(height: 10)
                        
                        Spacer()
                        
                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                        
                        Spacer()
                    }
                    .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                    .foregroundColor(selectedTab == tab ? .appAccent : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: 65)
        .background(
            .ultraThinMaterial
        )
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    init() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .catalog:
                        RecipeCatalogView()
                    case .pantry:
                        PantryChefView()
                    case .myRecipes:
                        MyRecipesView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBarView(selectedTab: $selectedTab)
                    .padding(.bottom, 8)
            }
            .ignoresSafeArea(.keyboard)
            .background(Color.appBackground.ignoresSafeArea())
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
