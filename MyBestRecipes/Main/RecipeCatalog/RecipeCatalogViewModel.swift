//
//  RecipeCatalogViewModel.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

import Foundation
//  RecipeCatalogViewModel.swift
import Foundation
import Combine

// ViewModel управляет состоянием и логикой каталога рецептов
class RecipeCatalogViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"
    @Published var filteredRecipes: [Recipe] = []
    
    // MARK: - Private Properties
    private var allRecipes: [Recipe] = []
    private var cancellables = Set<AnyCancellable>()
    let categories: [String] = ["All", "cake", "apple", "choco", "raspberry", "lemon"]

    init() {
        loadRecipes()
        setupSubscribers()
    }
    
    // MARK: - Private Methods
    
    // Загружает рецепты из локального JSON файла
    private func loadRecipes() {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            print("Error: recipes.json file not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let recipes = try JSONDecoder().decode([Recipe].self, from: data)
            self.allRecipes = recipes
            self.filteredRecipes = recipes // Изначально показываем все
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
    // Настраивает подписчиков на изменения поиска и категории
    private func setupSubscribers() {
        // Объединяем изменения текста поиска и выбранной категории
        Publishers.CombineLatest($searchText, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // Задержка для плавности
            .map { [weak self] (searchText, selectedCategory) -> [Recipe] in
                self?.filterRecipes(searchText: searchText, category: selectedCategory) ?? []
            }
            .assign(to: \.filteredRecipes, on: self)
            .store(in: &cancellables)
    }
    
    // Основная функция фильтрации
    private func filterRecipes(searchText: String, category: String) -> [Recipe] {
        var recipes = allRecipes
        
        // 1. Фильтрация по категории
        if category != "All" {
            recipes = recipes.filter { $0.category.lowercased() == category.lowercased() }
        }
        
        // 2. Поиск по тексту (в уже отфильтрованных по категории)
        if !searchText.isEmpty {
            let lowercasedSearchText = searchText.lowercased()
            recipes = recipes.filter { recipe in
                recipe.name.lowercased().contains(lowercasedSearchText) ||
                recipe.description.lowercased().contains(lowercasedSearchText)
            }
        }
        
        return recipes
    }
}
