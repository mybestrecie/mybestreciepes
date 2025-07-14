//
//  MyRecipesView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//


import SwiftUI
import RealmSwift

#Preview {
    MyRecipesView()
}


struct MyRecipesView: View {
    
    init() {
           let appearance = UINavigationBarAppearance()
           appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.init(named: "bgColor")
           appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // обычный заголовок
           appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // крупный заголовок

           UINavigationBar.appearance().standardAppearance = appearance
           UINavigationBar.appearance().scrollEdgeAppearance = appearance
       }
    
    // Получаем все рецепты из Realm
    @ObservedResults(RealmRecipe.self) var realmRecipes
    // Состояние для отображения модального окна добавления
    @State private var isShowingAddSheet = false

    // Фильтруем рецепты, чтобы показать только пользовательские
    private var userRecipes: Results<RealmRecipe> {
        realmRecipes.where { $0.recipeId == "" }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if userRecipes.isEmpty {
                    EmptyStateView { isShowingAddSheet = true }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(userRecipes) { recipe in
                                NavigationLink(destination: MyRecipeDetailView(recipe: recipe)) {
                                    UserRecipeCardView(recipe: recipe)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My recipes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.appAccent)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddMyRecipeView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Компоненты UserRecipeCardView и EmptyStateView остаются теми же,
// что и в версии SwiftData. Просто скопируйте их сюда.
// Я приложу их ниже для удобства.

struct UserRecipeCardView: View {
    // @ObservedRealmObject нужен, чтобы View обновлялся при изменении объекта
    @ObservedRealmObject var recipe: RealmRecipe
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(height: 200).clipped()
            } else {
                Rectangle().fill(Color.appCardBackground)
                    .frame(height: 200)
                    .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.appSecondaryText))
            }
            
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                           startPoint: .center, endPoint: .bottom)
            
            Text(recipe.name).font(.title2.bold()).foregroundColor(.white).padding()
        }
        .cornerRadius(16).shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

struct EmptyStateView: View {
    var onAddButtonTapped: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle").font(.system(size: 80)).foregroundColor(.appSecondaryText)
            Text("You don't have any recipes yet.").font(.title2.bold()).foregroundColor(.appPrimaryText)
            Text("Click + to add your first culinary masterpiece!").font(.body).foregroundColor(.appSecondaryText).multilineTextAlignment(.center).padding(.horizontal)
            
            Button(action: onAddButtonTapped) {
                Label("Add recipe", systemImage: "plus").fontWeight(.bold)
            }.padding().background(Color.appAccent).foregroundColor(.black).cornerRadius(12).padding(.top)
        }
    }
}
