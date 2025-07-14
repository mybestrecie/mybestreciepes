//
//  RecipeCatalogView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

import Foundation
//  RecipeCatalogView.swift
import SwiftUI

struct RecipeCatalogView: View {
    
    @StateObject private var viewModel = RecipeCatalogViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
       // NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        
                        // Заголовок
                        Text("Recipe Catalog")
                            .font(.largeTitle).bold()
                            .foregroundColor(.appPrimaryText)
                            .padding(.horizontal)
                        
                        // Поиск
                        SearchBarView(searchText: $viewModel.searchText)
                            .padding(.horizontal)
                        
                        // Фильтры по категориям
                        CategoryFilterView(categories: viewModel.categories,
                                           selectedCategory: $viewModel.selectedCategory)
                        
                        // Сетка с рецептами
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.filteredRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCardView(recipe: recipe)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 150)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        //}
        .preferredColorScheme(.dark)
    }
}


// --- КОМПОНЕНТЫ ДЛЯ RecipeCatalogView ---

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appSecondaryText)
            
            TextField("Find recipe...", text: $searchText)
                .foregroundColor(.appPrimaryText)
                .tint(.appAccent) // Цвет курсора
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

struct CategoryFilterView: View {
    let categories: [String]
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category.capitalized)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedCategory == category ? Color.appAccent : Color.appCardBackground)
                            .foregroundColor(selectedCategory == category ? .black : .appPrimaryText)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // **ВАЖНО**: твои картинки должны быть в Assets
            Image(recipe.id)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipped()
            
            // Затемняющий градиент
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                           startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading) {
                Spacer()
                Text(recipe.name)
                    .font(.system(size: 14, weight: .black))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            
        }
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)

    }
}


struct RecipeCatalogView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCatalogView()
    }
}
