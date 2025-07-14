//
//  ShoppingListService.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

import Foundation
//  ShoppingListService.swift
import Foundation

// Этот сервис инкапсулирует всю работу с UserDefaults
class ShoppingListService {
    static let shared = ShoppingListService()
    private let userDefaultsKey = "shoppingListItems"

    private init() {}

    // Загрузка списка из UserDefaults
    func loadItems() -> [ShoppingItem] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return []
        }
        do {
            let items = try JSONDecoder().decode([ShoppingItem].self, from: data)
            return items
        } catch {
            print("Failed to decode shopping items: \(error)")
            return []
        }
    }

    // Сохранение списка в UserDefaults
    func saveItems(_ items: [ShoppingItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode shopping items: \(error)")
        }
    }
}
