//
//  PantryChefView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//


import SwiftUI

struct PantryChefView: View {
    
    @StateObject private var viewModel = PantryChefViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    HStack {
                        Text("What to cook?")
                            .font(.largeTitle).bold()
                            .foregroundColor(.appPrimaryText)
                            .padding()
                        Spacer()
                    }
                    
                    // Основной контент
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            InputSectionView(userInput: $viewModel.userInput) {
                                viewModel.findRecipes()
                            }
                            
                            Divider().background(Color.appCardBackground)
                            
                            ResultsSectionView(
                                recipes: viewModel.suggestedRecipes,
                                isLoading: viewModel.isLoading,
                                errorMessage: viewModel.errorMessage
                            )
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}

// --- КОМПОНЕНТЫ VIEW ---

// Секция для ввода продуктов
struct InputSectionView: View {
    @Binding var userInput: String
    var onFindButtonTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter the products you have, separated by commas:")
                .font(.headline)
                .foregroundColor(.appPrimaryText)
            
            TextEditor(text: $userInput)
                .frame(height: 100)
                .padding(8)
                .background(Color.appCardBackground)
                .cornerRadius(12)
                .tint(.appAccent)
                .foregroundColor(.appPrimaryText)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appSecondaryText, lineWidth: 1)
                )
                .scrollContentBackground(.hidden)
            
            Button(action: onFindButtonTapped) {
                HStack {
                    Spacer()
                    Text("Find recipes")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(Color.appAccent)
                .foregroundColor(.black)
                .cornerRadius(12)
            }
        }
    }
}

// Секция для отображения результатов
struct ResultsSectionView: View {
    let recipes: [RecipeAIService.AIGeneratedRecipe]
    let isLoading: Bool
    let errorMessage: String?
    
    var body: some View {
        ZStack {
            if isLoading {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .appAccent))
                            .scaleEffect(1.5)
                        Text("AI-Chief thinks...")
                            .foregroundColor(.appSecondaryText)
                    }
                    Spacer()
                }
            } else if let _ = errorMessage {
                HStack {
                    Spacer()
                    Text("Oops, something went wrong. Try again.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else if recipes.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                        Text("Recipes suggested by our AI chef will appear here.")
                    }
                    .font(.headline)
                    .foregroundColor(.appSecondaryText)
                    .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Here's what you can cook:")
                        .font(.title2).bold()
                        .foregroundColor(.appPrimaryText)
                    
                    ForEach(recipes) { recipe in
                        RecipeSuggestionCardView(recipe: recipe)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}


// Карточка для одного предложенного рецепта
struct RecipeSuggestionCardView: View {
    let recipe: RecipeAIService.AIGeneratedRecipe
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.title3.bold())
                    Label(recipe.cookingTime, systemImage: "timer")
                        .font(.caption)
                        .foregroundColor(.appSecondaryText)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .contentShape(Rectangle()) // Делает всю область HStack кликабельной
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                    
                    Text(recipe.description)
                        .font(.body)
                    
                    SectionView(title: "Ingredients") {
                        ForEach(recipe.ingredients, id: \.self) {
                            Text("• \($0)")
                        }
                    }
                    
                    SectionView(title: "Instructions") {
                        ForEach(recipe.instructions.indices, id: \.self) { index in
                            StepView(index: index + 1, text: recipe.instructions[index])
                        }
                    }
                }
                .foregroundColor(.appPrimaryText)
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
}


struct PantryChefView_Previews: PreviewProvider {
    static var previews: some View {
        PantryChefView()
    }
}
