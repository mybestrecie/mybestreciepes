//
//  PantryChefViewModel.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//


import Foundation

@MainActor // Гарантирует, что изменения @Published будут происходить в главном потоке
class PantryChefViewModel: ObservableObject {
    
    @Published var userInput: String = ""
    @Published var suggestedRecipes: [RecipeAIService.AIGeneratedRecipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let aiService = RecipeAIService()
    
    func findRecipes() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter at least one product."
            return
        }
        
        isLoading = true
        errorMessage = nil
        suggestedRecipes = []
        
        Task {
            let result = await aiService.suggestRecipes(from: userInput)
            
            isLoading = false
            
            switch result {
            case .success(let recipes):
                self.suggestedRecipes = recipes
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
